import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/app/bootstrap.dart';
import 'package:laratik_schools_mobile/auth/session.dart';
import 'package:laratik_schools_mobile/core/clock.dart';
import 'package:laratik_schools_mobile/core/logging.dart';
import 'package:laratik_schools_mobile/platform/transport.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('bootstrap()', () {
    test('returns a wired AppDependencies graph', () async {
      SharedPreferences.setMockInitialValues(const {});
      final transport = _RecordingTransport();
      final clock = FixedClock(DateTime.utc(2026, 7, 27, 12, 0));
      final session = SessionStore.inMemory(clock: clock, logger: RedactingLogger(clock: clock));

      final deps = await bootstrap(
        env: const BootstrapEnvironment(siteBaseUrl: 'https://example.test'),
        transportFactory: (baseUrl, logger, c) async => transport,
        sessionFactory: (logger, c) async => session,
      );

      expect(deps.api, isA<LaratikSchoolsApiClient>());
      expect(deps.transport, same(transport));
      expect(deps.session, same(session));
      expect(deps.clock, isA<Clock>());
      expect(deps.logger, isA<RedactingLogger>());
      expect(deps.router.configuration.routes, isNotEmpty);
      expect(deps.session.hasToken, isFalse);
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
        env: const BootstrapEnvironment(siteBaseUrl: 'https://example.test'),
        transportFactory: (_, __, ___) async => transport,
        sessionFactory: (_, __) async => session,
      );

      expect(deps.session.hasToken, isFalse);
      expect(deps.session.installationId, 'install-test');
      expect(deps.session.currentToken, isNull);
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
