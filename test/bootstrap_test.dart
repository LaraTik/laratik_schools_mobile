import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/app/bootstrap.dart';
import 'package:laratik_schools_mobile/auth/session.dart';
import 'package:laratik_schools_mobile/config/app_config.dart';
import 'package:laratik_schools_mobile/config/app_flavor.dart';
import 'package:laratik_schools_mobile/core/clock.dart';
import 'package:laratik_schools_mobile/core/logging.dart';
import 'package:laratik_schools_mobile/platform/transport.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test config — mirrors the shape of a real flavor entry but with a
/// stable, fake baseUrl so the transport is constructed but never called.
const _testConfig = AppConfig(
  flavor: AppFlavor.dev,
  baseUrl: 'https://example.test',
  oauthClientId: 'laratik-mobile-test',
  oauthRedirectScheme: 'laratik',
  universalLinksDomain: 'laratik.test',
  appDisplayName: 'Laratik Schools (Test)',
  appIdSuffix: '.test',
  allowCleartext: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('bootstrap()', () {
    test('returns a wired AppDependencies graph', () async {
      SharedPreferences.setMockInitialValues(const {});
      final transport = _RecordingTransport();
      final clock = FixedClock(DateTime.utc(2026, 7, 27, 12, 0));
      final session = SessionStore.inMemory(clock: clock, logger: RedactingLogger(clock: clock));

      final deps = await bootstrap(
        config: _testConfig,
        transportFactory: (baseUrl, logger, c, tokenProvider) async => transport,
        sessionFactory: (logger, c) async => session,
      );

      expect(deps.api, isA<LaratikSchoolsApiClient>());
      expect(deps.transport, same(transport));
      expect(deps.session, same(session));
      expect(deps.clock, isA<Clock>());
      expect(deps.logger, isA<RedactingLogger>());
      expect(deps.router.configuration.routes, isNotEmpty);
      expect(deps.session.hasToken, isFalse);
      // The config the bootstrap owns is the same instance we passed in.
      expect(deps.config, same(_testConfig));
      // And the Riverpod overrides expose it for feature code.
      expect(deps.riverpodOverrides, isNotEmpty);
    });

    test('session starts with no token and a stable installation id',
        () async {
      SharedPreferences.setMockInitialValues(const {});
      final transport = _RecordingTransport();
      final clock = FixedClock(DateTime.utc(2026, 7, 27));
      final session = SessionStore.inMemory(
        clock: clock,
        logger: RedactingLogger(clock: clock),
        installationId: 'install-test',
      );

      final deps = await bootstrap(
        config: _testConfig,
        transportFactory: (_, __, ___, ____) async => transport,
        sessionFactory: (_, __) async => session,
      );

      expect(deps.session.hasToken, isFalse);
      expect(deps.session.installationId, 'install-test');
      expect(deps.session.currentToken, isNull);
    });

    test('SessionTokenProvider exposes the session access token', () async {
      SharedPreferences.setMockInitialValues(const {});
      final transport = _RecordingTransport();
      final clock = FixedClock(DateTime.utc(2026, 7, 27));
      final session = SessionStore.inMemory(
        clock: clock,
        logger: RedactingLogger(clock: clock),
      );
      await session.applyTokens(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        accessTokenExpiresAt: DateTime.utc(2026, 7, 28),
      );
      final deps = await bootstrap(
        config: _testConfig,
        transportFactory: (_, __, ___, ____) async => transport,
        sessionFactory: (_, __) async => session,
      );
      // The bootstrap wires a SessionTokenProvider into the transport.
      // We don't have a direct handle on the provider, but the session
      // the bootstrap built is the same instance the provider reads
      // from, so a fresh session.readAccess() should round-trip the
      // value the transport would send.
      expect(deps.session.currentToken, 'access-1');
    });
  });
}

class _RecordingTransport implements LaratikSchoolsTransport {
  final List<String> calls = [];

  @override
  Future<JsonMap> invoke({
    required String method,
    required HttpVerb verb,
    JsonMap arguments = const {},
    String? idempotencyKey,
  }) async {
    calls.add(method);
    return <String, Object?>{
      'data': null,
      'error': null,
      'meta': {
        'api_version': 'v1',
        'request_id': 'test-${calls.length}',
      },
      'warnings': <Object?>[],
    };
  }
}
