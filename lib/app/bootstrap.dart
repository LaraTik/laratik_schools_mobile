import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../auth/session.dart';
import '../core/clock.dart';
import '../core/logging.dart';
import '../core/result.dart';
import '../features/people/data/person_providers.dart';
import '../platform/transport.dart';
import 'login_screen.dart';
import 'router.dart';

/// Composition root. The async factory constructs the immutable graph of
/// dependencies the app needs; nothing else should be a top-level singleton.
///
/// Bootstrap is testable: pass a custom [BootstrapEnvironment] (e.g. a
/// fake clock, an in-memory transport) and assert the resulting graph.
class AppDependencies {
  const AppDependencies({
    required this.router,
    required this.api,
    required this.transport,
    required this.session,
    required this.clock,
    required this.logger,
  });

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
  /// layer and the People providers can pull the same objects from
  /// either the graph or a ProviderScope.
  List<Override> get riverpodOverrides => [
        apiClientProvider.overrideWithValue(api),
        sessionProvider.overrideWithValue(session),
        clockProvider.overrideWithValue(clock),
        loggerProvider.overrideWithValue(logger),
      ];
}

class BootstrapEnvironment {
  const BootstrapEnvironment({
    this.siteBaseUrl = 'https://laratik.localhost',
    this.now,
  });

  /// Site origin; consumed by the transport for the request base URL and the
  /// OAuth redirect.
  final String siteBaseUrl;

  /// Optional clock override; defaults to the system clock.
  final DateTime Function()? now;
}

Future<AppDependencies> bootstrap({
  BootstrapEnvironment env = const BootstrapEnvironment(),
  Future<LaratikSchoolsTransport> Function(
    String baseUrl,
    RedactingLogger logger,
    Clock clock,
  )? transportFactory,
  Future<SessionStore> Function(RedactingLogger logger, Clock clock)? sessionFactory,
}) async {
  final clock = SystemClock(env.now);
  final logger = RedactingLogger(clock: clock);
  final transport = await (transportFactory ?? _defaultTransportFactory)(
    env.siteBaseUrl,
    logger,
    clock,
  );
  // Default session: in-memory. Production wires flutter_secure_storage
  // via [SessionStore.restore] from the persisted SharedPreferences +
  // secure-storage keys; that lands in Phase 2.1 alongside the OAuth
  // wire (see docs/adr/0004).
  final session = await (sessionFactory ?? _defaultSessionFactory)(logger, clock);
  final api = LaratikSchoolsApiClient(transport);
  final router = buildRouter(
    api: api,
    session: session,
    logger: logger,
    clock: clock,
  );
  return AppDependencies(
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
) async {
  return HttpLaratikApiTransport(
    baseUrl: baseUrl,
    logger: logger,
    clock: clock,
    // The transport reads the bearer token from the session on every
    // call so refresh + sign-out work without rebuilding the transport.
    tokenProvider: null,
  );
}

Future<SessionStore> _defaultSessionFactory(
  RedactingLogger logger,
  Clock clock,
) async {
  return InMemorySessionStore(clock: clock, logger: logger);
}
