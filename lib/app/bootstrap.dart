import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/session.dart';
import '../config/app_config.dart';
import '../config/flavor_loader.dart';
import '../core/clock.dart';
import '../core/logging.dart';
import '../features/people/data/person_providers.dart';
import '../platform/transport.dart';
import 'login_screen.dart';
import 'router.dart';

/// Composition root. The async factory constructs the immutable graph of
/// dependencies the app needs; nothing else should be a top-level singleton.
///
/// Bootstrap is testable: pass a custom [AppConfig] (e.g. an in-test
/// stub with a fake baseUrl) and optional `transportFactory` /
/// `sessionFactory` overrides and assert the resulting graph.
class AppDependencies {
  const AppDependencies({
    required this.config,
    required this.router,
    required this.api,
    required this.transport,
    required this.session,
    required this.clock,
    required this.logger,
  });

  /// The active environment configuration. Threaded into
  /// [appConfigProvider] via [riverpodOverrides] so any feature can read
  /// it without re-passing it through constructors.
  final AppConfig config;

  final GoRouter router;

  /// Typed v1 contract client. Feature code uses this; it never sees the
  /// raw [LaratikSchoolsTransport] or JSON shapes.
  final LaratikSchoolsApiClient api;

  /// Raw transport — exposed for tests and tooling only. Feature code must
  /// not call [LaratikSchoolsTransport.invoke] directly.
  final LaratikSchoolsTransport transport;

  final SessionStore session;
  final Clock clock;
  final RedactingLogger logger;

  /// The list of Riverpod overrides `main.dart` applies so the auth
  /// layer, the People providers, and the config can pull the same objects
  /// from either the graph or a ProviderScope.
  List<Override> get riverpodOverrides => [
        appConfigProvider.overrideWithValue(config),
        apiClientProvider.overrideWithValue(api),
        sessionProvider.overrideWithValue(session),
        clockProvider.overrideWithValue(clock),
        loggerProvider.overrideWithValue(logger),
      ];
}

/// Build the app's dependency graph.
///
/// [config] is the source of truth for every environment-specific value
/// (base URL, OAuth client, redirect scheme, app name). It is required —
/// callers (production `main.dart`, tests) must construct it explicitly
/// so the source of the value is always visible at the call site.
///
/// `now` is an optional clock override (defaults to the system clock);
/// useful for tests that need a deterministic timestamp.
Future<AppDependencies> bootstrap({
  required AppConfig config,
  DateTime Function()? now,
  Future<LaratikSchoolsTransport> Function(
    String baseUrl,
    RedactingLogger logger,
    Clock clock,
    TokenProvider tokenProvider,
  )? transportFactory,
  Future<SessionStore> Function(RedactingLogger logger, Clock clock)?
      sessionFactory,
}) async {
  final clock = SystemClock(now);
  final logger = RedactingLogger(clock: clock);
  // Default session: persisted. Tokens live in flutter_secure_storage
  // (Android Keystore / iOS Keychain); non-secret session metadata
  // (installation id, roles, scopes, expires_at) lives in plain
  // SharedPreferences. Tests can still pass a custom [sessionFactory]
  // to skip persistence (see [SessionStore.inMemory]).
  final session =
      await (sessionFactory ?? _defaultSessionFactory)(logger, clock);
  final tokenProvider = SessionTokenProvider(session: session);
  final transport = await (transportFactory ?? _defaultTransportFactory)(
    config.baseUrl,
    logger,
    clock,
    tokenProvider,
  );
  final api = LaratikSchoolsApiClient(transport);
  final router = buildRouter(
    api: api,
    session: session,
    logger: logger,
    clock: clock,
  );
  return AppDependencies(
    config: config,
    router: router,
    api: api,
    transport: transport,
    session: session,
    clock: clock,
    logger: logger,
  );
}

Future<LaratikSchoolsTransport> _defaultTransportFactory(
  String baseUrl,
  RedactingLogger logger,
  Clock clock,
  TokenProvider tokenProvider,
) async {
  // The transport reads the bearer token from the session on every call
  // so refresh + sign-out work without rebuilding the transport. The
  // session is built before the transport so the provider can read the
  // current access token synchronously on each invoke.
  return HttpLaratikApiTransport(
    baseUrl: baseUrl,
    logger: logger,
    clock: clock,
    tokenProvider: tokenProvider,
  );
}

Future<SessionStore> _defaultSessionFactory(
  RedactingLogger logger,
  Clock clock,
) async {
  final prefs = await SharedPreferences.getInstance();
  return SessionStore.restore(
    prefs: prefs,
    // Dev flavor: persist tokens in plain SharedPreferences. The prod
    // shell should swap this for [SecureTokenStore.flutter()] (Android
    // Keystore + AES) or a production-grade Keystore wrapper. See
    // [SecureTokenStore] for the trade-off.
    secureTokens: SecureTokenStore.prefs(prefs: prefs),
    clock: clock,
    logger: logger,
  );
}

/// Pulls the current access token from a [SessionStore] on every
/// `currentToken` read. Wired into the [HttpLaratikApiTransport] so
/// the Authorization header is always in sync with the session
/// (sign-in populates, sign-out clears, refresh swaps) without
/// rebuilding the transport graph.
class SessionTokenProvider implements TokenProvider {
  SessionTokenProvider({required this.session});

  final SessionStore session;

  @override
  String? get currentToken => session.currentToken;
}
