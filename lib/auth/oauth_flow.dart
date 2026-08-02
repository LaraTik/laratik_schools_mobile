import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/clock.dart';
import '../core/logging.dart';
import 'oauth_pkce.dart';
import 'session.dart';

/// One-line outcome of an [OauthFlow.run] call. The UI layer pattern-matches
/// on this — success hands the access / refresh pair to the session store;
/// failure maps to a user-safe error message.
sealed class OauthResult {
  const OauthResult();
}

class OauthSuccess extends OauthResult {
  const OauthSuccess({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.roles,
    required this.scopes,
  });
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final Set<String> roles;
  final Set<String> scopes;
}

class OauthFailure extends OauthResult {
  const OauthFailure({required this.code, required this.message, this.detail});
  final String code;
  final String message;
  final String? detail;
}

/// High-level OAuth2 PKCE flow used by the login screen.
///
/// Steps:
///   1. Mint a fresh [PkcePair] + [OauthState].
///   2. Build the authorize URL (server is expected to honor `code_challenge`
///      + `code_challenge_method=S256` — see laratik_schools mobile_platform).
///   3. Hand the URL to the platform system browser (ASWebAuthenticationSession
///      on iOS, Custom Tabs on Android) via [OauthBrowserLauncher].
///   4. Parse the redirect; abort on state mismatch.
///   5. Exchange the code + verifier at the token endpoint.
///   6. Hand the tokens to the [SessionStore].
class OauthFlow {
  OauthFlow({
    required this.authorizeUrl,
    required this.tokenUrl,
    required this.clientId,
    required this.redirectUri,
    required this.scope,
    required this.session,
    required this.clock,
    required this.logger,
    required this.launcher,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Authorize endpoint. Resolved at construction from [AppConfig.baseUrl]
  /// — the caller does **not** hard-code a host here. Example for the
  /// dev flavor: `http://10.0.2.2:8000/api/method/frappe.integrations.oauth2.authorize`.
  final Uri authorizeUrl;

  /// Token endpoint. Same origin as [authorizeUrl] (e.g. for the dev
  /// flavor: `http://10.0.2.2:8000/api/method/frappe.integrations.oauth2.get_token`).
  final Uri tokenUrl;

  /// OAuth client id (`laratik-mobile`, per ADR 0003).
  final String clientId;

  /// App-side redirect URI — must match the universal link / scheme
  /// registered with the server (e.g. `laratik://oauth/callback`).
  final Uri redirectUri;

  /// OAuth scope (`openid all` for the Laratik Schools deployment).
  final String scope;

  final SessionStore session;
  final Clock clock;
  final RedactingLogger logger;
  final OauthBrowserLauncher launcher;
  final http.Client _httpClient;

  Future<OauthResult> run({PkceGenerator? pkce}) async {
    final generator = pkce ?? PkceGenerator();
    final pkcePair = generator.generate();
    final state = OauthState.generate();
    final request = AuthorizationRequest(
      authorizeUrl: authorizeUrl,
      clientId: clientId,
      redirectUri: redirectUri,
      scope: scope,
      pkce: pkcePair,
      state: state,
    );

    final redirect = await launcher.open(request.toUri());
    if (redirect == null) {
      return const OauthFailure(
        code: 'USER_CANCELLED',
        message: 'Sign-in was cancelled.',
      );
    }

    final parser = const AuthorizationResponseParser();
    AuthorizationResponse response;
    try {
      response = parser.parse(redirectUri: redirect, expectedState: state);
    } on AuthorizationResponseException catch (e) {
      logger.logSessionEvent('oauth.parse_failed',
          actor: session.installationId, reason: e.code);
      return OauthFailure(
        code: e.code,
        message: e.message,
        detail: redirect.toString(),
      );
    }

    return _exchange(response, pkcePair.codeVerifier);
  }

  Future<OauthResult> _exchange(
    AuthorizationResponse response,
    String codeVerifier,
  ) async {
    try {
      final body = <String, String>{
        'grant_type': 'authorization_code',
        'code': response.code,
        'code_verifier': codeVerifier,
        'client_id': clientId,
        'redirect_uri': redirectUri.toString(),
      };
      final httpResponse = await _httpClient
          .post(
            tokenUrl,
            headers: const {'Accept': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));
      final raw = utf8.decode(httpResponse.bodyBytes, allowMalformed: true);
      if (httpResponse.statusCode != 200) {
        logger.logSessionEvent('oauth.exchange_failed',
            actor: session.installationId,
            reason: 'HTTP_${httpResponse.statusCode}');
        return OauthFailure(
          code: 'HTTP_${httpResponse.statusCode}',
          message: 'Token endpoint returned ${httpResponse.statusCode}.',
          detail: _redact(raw),
        );
      }
      final Map<String, Object?> json;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) throw const FormatException('not a map');
        json = Map<String, Object?>.from(decoded);
      } on FormatException catch (e) {
        return OauthFailure(
          code: 'INVALID_RESPONSE',
          message: 'Token endpoint returned non-JSON body.',
          detail: e.message,
        );
      }

      final message = json['message'];
      final messageMap =
          message is Map ? Map<String, Object?>.from(message) : json;
      final accessToken = (messageMap['access_token'] ?? '').toString();
      final refreshToken = (messageMap['refresh_token'] ?? '').toString();
      final expiresIn = messageMap['expires_in'];
      if (accessToken.isEmpty || refreshToken.isEmpty) {
        return OauthFailure(
          code: 'MISSING_TOKENS',
          message:
              'Token endpoint did not return access_token and refresh_token.',
        );
      }
      final expiresAt = clock.nowUtc().add(
            expiresIn is num
                ? Duration(seconds: expiresIn.toInt())
                : const Duration(minutes: 30),
          );
      final scopes = <String>{
        if (messageMap['scope'] is String)
          ...(messageMap['scope'] as String).split(RegExp(r'\s+')),
      };
      final roles = <String>{
        if (messageMap['roles'] is List)
          ...(messageMap['roles'] as List).map((e) => e.toString()),
      };
      await session.applyTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresAt: expiresAt,
        roles: roles,
        scopes: scopes,
      );
      return OauthSuccess(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
        roles: roles,
        scopes: scopes,
      );
    } on TimeoutException {
      return const OauthFailure(
        code: 'TIMEOUT',
        message: 'Token endpoint did not respond in time.',
      );
    } on SocketException catch (e) {
      return OauthFailure(
        code: 'NETWORK',
        message: 'Could not reach the token endpoint.',
        detail: e.message,
      );
    } on Exception catch (e, st) {
      // ignore: avoid_print
      print('OauthFlow._exchange exception: $e\n$st');
      return OauthFailure(code: 'EXCEPTION', message: e.toString());
    }
  }

  String? _redact(String raw) {
    // Drop anything that looks like a token in the detail field.
    // Match `access_token` / `refresh_token` followed by the usual
    // boundary punctuation (quote, colon, equals, whitespace) and the
    // token value. Non-raw to allow embedded double-quotes; single
    // quotes use the hex escape so the string literal stays a single
    // line.
    // Non-raw string so we can mix the JSON quote and the form-encoded
    // punctuation around an OAuth2 token in one literal. The token
    // value itself can be A-Z / a-z / 0-9 / . / _.
    final accessPattern = RegExp(
      r'access_token[\s:=]+[A-Za-z0-9._-]+',
      caseSensitive: false,
    );
    final refreshPattern = RegExp(
      r'refresh_token[\s:=]+[A-Za-z0-9._-]+',
      caseSensitive: false,
    );
    final scrubbed =
        raw.replaceAll(accessPattern, '***').replaceAll(refreshPattern, '***');
    if (scrubbed.length > 200) {
      return '${scrubbed.substring(0, 200)}…';
    }
    return scrubbed;
  }
}

/// Platform-agnostic launcher abstraction. Production wires
/// `flutter_web_auth_2`'s `FlutterWebAuth2.authenticate`; tests use a
/// fake that returns a pre-baked redirect.
abstract class OauthBrowserLauncher {
  Future<Uri?> open(Uri authorizeUrl);
}
