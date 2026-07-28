import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/auth/oauth_flow.dart';
import 'package:laratik_schools_mobile/auth/session.dart';
import 'package:laratik_schools_mobile/core/clock.dart';
import 'package:laratik_schools_mobile/core/logging.dart';

class _StubLauncher implements OauthBrowserLauncher {
  _StubLauncher({this.redirect, this.injectState});
  Uri? redirect;
  final String? injectState;
  Uri? lastUrl;

  @override
  Future<Uri?> open(Uri authorizeUrl) async {
    lastUrl = authorizeUrl;
    if (redirect == null) return null;
    if (injectState != null) {
      // Replace the state with our injected value to exercise mismatch paths.
      final replaced = redirect!.replace(
        queryParameters: <String, String>{
          ...redirect!.queryParameters,
          'state': injectState!,
        },
      );
      return replaced;
    }
    return redirect;
  }
}

class _TokenClient extends http.BaseClient {
  _TokenClient({this.body = _okBody, this.status = 200});
  final String body;
  final int status;
  static const _okBody =
      '{"message": {"access_token": "at-1", "refresh_token": "rt-1", "expires_in": 1800, "scope": "openid all", "roles": ["registrar"]}}';

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value(body.codeUnits),
      status,
      headers: const {'content-type': 'application/json'},
    );
  }
}

OauthFlow _buildFlow({
  required SessionStore session,
  required Clock clock,
  required RedactingLogger logger,
  required OauthBrowserLauncher launcher,
  http.Client? httpClient,
}) {
  return OauthFlow(
    authorizeUrl: Uri.parse('https://example.test/api/method/oauth.authorize'),
    tokenUrl: Uri.parse('https://example.test/api/method/oauth.get_token'),
    clientId: 'test-client',
    redirectUri: Uri.parse('laratik://oauth/callback'),
    scope: 'openid',
    session: session,
    clock: clock,
    logger: logger,
    launcher: launcher,
    httpClient: httpClient,
  );
}

void main() {
  group('OauthFlow', () {
    test('returns USER_CANCELLED when the launcher returns null', () async {
      final clock = FixedClock(DateTime.utc(2026, 7, 27));
      final logger = RedactingLogger(clock: clock);
      final session = SessionStore.inMemory(clock: clock, logger: logger);
      final flow = _buildFlow(
        session: session,
        clock: clock,
        logger: logger,
        launcher: _StubLauncher(redirect: null),
      );
      final result = await flow.run();
      expect(result, isA<OauthFailure>());
      expect((result as OauthFailure).code, 'USER_CANCELLED');
      expect(session.hasToken, isFalse);
    });

    test('parses a successful code, exchanges, and stores the tokens',
        () async {
      final clock = FixedClock(DateTime.utc(2026, 7, 27));
      final logger = RedactingLogger(clock: clock);
      final session = SessionStore.inMemory(clock: clock, logger: logger);
      final launcher = _StubLauncher(redirect: Uri.parse(
        'laratik://oauth/callback?code=auth-code-1&state=PLACEHOLDER',
      ));
      // Replace PLACEHOLDER with the actual state at open() time so the
      // parser accepts the redirect.
      launcher.injectState = '__placeholder__';
      final flow = _buildFlow(
        session: session,
        clock: clock,
        logger: logger,
        launcher: _StubWithStateCapture(launcher: launcher),
        httpClient: _TokenClient(),
      );
      final result = await flow.run();
      expect(result, isA<OauthSuccess>());
      final success = result as OauthSuccess;
      expect(success.accessToken, 'at-1');
      expect(success.refreshToken, 'rt-1');
      expect(success.expiresAt.isAfter(clock.nowUtc()), isTrue);
      expect(success.roles, contains('registrar'));
      expect(session.hasToken, isTrue);
      expect(session.currentToken, 'at-1');
      expect(session.currentRoles, contains('registrar'));
    });

    test('rejects a state mismatch', () async {
      final clock = FixedClock(DateTime.utc(2026, 7, 27));
      final logger = RedactingLogger(clock: clock);
      final session = SessionStore.inMemory(clock: clock, logger: logger);
      final flow = _buildFlow(
        session: session,
        clock: clock,
        logger: logger,
        launcher: _StubLauncher(
          redirect: Uri.parse(
            'laratik://oauth/callback?code=auth-code-1&state=wrong-state',
          ),
        ),
      );
      final result = await flow.run();
      expect(result, isA<OauthFailure>());
      expect((result as OauthFailure).code, 'STATE_MISMATCH');
      expect(session.hasToken, isFalse);
    });

    test('returns HTTP_<code> on a non-200 token response', () async {
      final clock = FixedClock(DateTime.utc(2026, 7, 27));
      final logger = RedactingLogger(clock: clock);
      final session = SessionStore.inMemory(clock: clock, logger: logger);
      final launcher = _StubWithStateCapture(
        launcher: _StubLauncher(redirect: Uri.parse(
          'laratik://oauth/callback?code=auth-code-1&state=__placeholder__',
        )),
      );
      final flow = _buildFlow(
        session: session,
        clock: clock,
        logger: logger,
        launcher: launcher,
        httpClient: _TokenClient(
          body: 'access_token=at-1&refresh_token=rt-1',
          status: 500,
        ),
      );
      final result = await flow.run();
      expect(result, isA<OauthFailure>());
      expect((result as OauthFailure).code, 'HTTP_500');
    });

    test('the authorize URL carries the PKCE challenge + state', () async {
      final clock = FixedClock(DateTime.utc(2026, 7, 27));
      final logger = RedactingLogger(clock: clock);
      final session = SessionStore.inMemory(clock: clock, logger: logger);
      final inner = _StubLauncher(redirect: null);
      final flow = _buildFlow(
        session: session,
        clock: clock,
        logger: logger,
        launcher: inner,
      );
      await flow.run();
      final url = inner.lastUrl!;
      final params = url.queryParameters;
      expect(params['response_type'], 'code');
      expect(params['client_id'], 'test-client');
      expect(params['code_challenge_method'], 'S256');
      expect(params['code_challenge'], isNotNull);
      expect(params['code_challenge']!.length, greaterThan(20));
      expect(params['state'], isNotNull);
      expect(params['scope'], 'openid');
    });
  });
}

/// A launcher that captures the state from the actual authorize URL the
/// flow generated and uses it to rewrite the redirect's state. Lets the
/// tests pass without having to duplicate the PKCE + state logic.
class _StubWithStateCapture implements OauthBrowserLauncher {
  _StubWithStateCapture({required this.launcher});
  final _StubLauncher launcher;
  Uri? lastUrl;

  @override
  Future<Uri?> open(Uri authorizeUrl) async {
    lastUrl = authorizeUrl;
    if (launcher.redirect == null) return null;
    final actualState = authorizeUrl.queryParameters['state'];
    return launcher.redirect!.replace(
      queryParameters: <String, String>{
        ...launcher.redirect!.queryParameters,
        'state': actualState ?? '__placeholder__',
      },
    );
  }
}
