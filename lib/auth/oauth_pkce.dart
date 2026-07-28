import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// PKCE S256 challenge for OAuth 2.0 authorization code with PKCE.
///
/// RFC 7636 (Proof Key for Code Exchange):
///   * `code_verifier` — high-entropy random string, 43..128 chars,
///     unreserved set `[A-Z][a-z][0-9]-._~`.
///   * `code_challenge` = BASE64URL-NOPAD(SHA256(ASCII(code_verifier))).
///   * `code_challenge_method` = `S256`.
///
/// We always emit S256 — `plain` is forbidden by the Laratik mobile
/// security configuration (`pkce_required` + S256 enforcement lives on the
/// server, see `laratik_schools.core.mobile_platform`).
class PkcePair {
  const PkcePair({required this.codeVerifier, required this.codeChallenge});

  final String codeVerifier;
  final String codeChallenge;
}

class PkceGenerator {
  PkceGenerator({Random? random}) : _random = random ?? _defaultRandom;

  final Random _random;

  // PKCE allows 43..128 chars; we use 64 for a comfortable security margin
  // and to keep the URL fragment short.
  static const int _verifierLength = 64;
  static const String _unreserved =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  static final Random _defaultRandom = Random.secure();

  PkcePair generate() {
    final verifier = _randomUnreserved(_verifierLength);
    final challenge = _s256Challenge(verifier);
    return PkcePair(codeVerifier: verifier, codeChallenge: challenge);
  }

  /// Cryptographically random string from the PKCE unreserved character set.
  String _randomUnreserved(int length) {
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(_unreserved[_random.nextInt(_unreserved.length)]);
    }
    return buffer.toString();
  }

  String _s256Challenge(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
}

/// One-time state value bound to the current authorization request. The
/// redirect handler must echo this back exactly, otherwise the flow aborts.
class OauthState {
  OauthState._(this.value);

  final String value;

  factory OauthState.generate({Random? random}) {
    final r = random ?? PkceGenerator._defaultRandom;
    final bytes = List<int>.generate(32, (_) => r.nextInt(256));
    final encoded = base64Url.encode(bytes).replaceAll('=', '');
    return OauthState._(encoded);
  }

  bool matches(String? candidate) {
    if (candidate == null) return false;
    if (candidate.length != value.length) return false;
    // Constant-time compare to avoid timing leaks.
    var diff = 0;
    for (var i = 0; i < value.length; i++) {
      diff |= value.codeUnitAt(i) ^ candidate.codeUnitAt(i);
    }
    return diff == 0;
  }
}

/// The authorization request the app launches in a custom tab / webview.
class AuthorizationRequest {
  AuthorizationRequest({
    required this.authorizeUrl,
    required this.clientId,
    required this.redirectUri,
    required this.scope,
    required this.pkce,
    required this.state,
  });

  /// The server's authorize endpoint. For Laratik Schools this is
  /// `<baseUrl>/api/method/frappe.integrations.oauth2.authorize`.
  final Uri authorizeUrl;
  final String clientId;
  final Uri redirectUri;
  final String scope;
  final PkcePair pkce;
  final OauthState state;

  /// Build the URL the OS opens in the system browser / ASWebAuthentication
  /// session. Includes all RFC 7636 parameters and a Laratik marker so the
  /// server can route to the PKCE-aware handler.
  Uri toUri() {
    final params = <String, String>{
      'response_type': 'code',
      'client_id': clientId,
      'code_challenge': pkce.codeChallenge,
      'code_challenge_method': 'S256',
      'redirect_uri': redirectUri.toString(),
      'scope': scope,
      'state': state.value,
      'laratik_client': 'mobile',
    };
    return authorizeUrl.replace(queryParameters: params);
  }
}

/// What the app parses from the redirect after the user consents.
class AuthorizationResponse {
  AuthorizationResponse({required this.code, required this.state});

  final String code;
  final OauthState state;
}

/// Thrown by [AuthorizationResponseParser] when the redirect is missing,
/// the state mismatches, or the server returned an error.
class AuthorizationResponseException implements Exception {
  const AuthorizationResponseException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'AuthorizationResponseException($code): $message';
}

class AuthorizationResponseParser {
  const AuthorizationResponseParser();

  AuthorizationResponse parse({
    required Uri redirectUri,
    required OauthState expectedState,
  }) {
    if (redirectUri.queryParameters['error'] != null) {
      throw AuthorizationResponseException(
        redirectUri.queryParameters['error']!,
        redirectUri.queryParameters['error_description'] ??
            'Authorization server returned an error.',
      );
    }
    final code = redirectUri.queryParameters['code'];
    final state = redirectUri.queryParameters['state'];
    if (code == null || code.isEmpty) {
      throw const AuthorizationResponseException(
        'MISSING_CODE',
        'Authorization redirect did not include a code.',
      );
    }
    if (!expectedState.matches(state)) {
      throw const AuthorizationResponseException(
        'STATE_MISMATCH',
        'Authorization state did not match the request.',
      );
    }
    return AuthorizationResponse(
      code: code,
      state: OauthState._(state!),
    );
  }
}
