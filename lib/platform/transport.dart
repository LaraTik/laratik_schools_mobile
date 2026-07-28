import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../core/clock.dart';
import '../core/logging.dart';

/// The app's HTTP transport. Implements the SDK's [LaratikSchoolsTransport]
/// contract: every call lands on the Frappe whitelisted-method endpoint
/// `POST <baseUrl>/api/method/<method>` with the typed args serialized as
/// `{"args": <args>}` and the OAuth bearer token attached.
///
/// Responsibilities:
///   * OAuth bearer injection (token pulled from a [TokenProvider] each call,
///     so the transport stays correct across refreshes and sign-out).
///   * Request timeout + retry on transient network errors (no retry on 4xx).
///   * Redacted logging (token, Authorization header, and `field_errors` are
///     never logged in plaintext — see [RedactingLogger]).
///   * Frappe response unwrap — strip the `message` envelope so feature code
///     sees the typed [ApiEnvelope] directly.
///   * Idempotency-Key header for mutating calls (POST) when supplied.
class HttpLaratikApiTransport implements LaratikSchoolsTransport {
  HttpLaratikApiTransport({
    required String baseUrl,
    required RedactingLogger logger,
    required Clock clock,
    TokenProvider? tokenProvider,
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 20),
    int maxAttempts = 3,
  })  : _baseUrl = _normalizeBaseUrl(baseUrl),
        _logger = logger,
        _clock = clock,
        _tokenProvider = tokenProvider,
        _httpClient = httpClient ?? http.Client(),
        _timeout = timeout,
        _maxAttempts = maxAttempts;

  final String _baseUrl;
  final RedactingLogger _logger;
  final Clock _clock;
  final TokenProvider? _tokenProvider;
  final http.Client _httpClient;
  final Duration _timeout;
  final int _maxAttempts;

  /// Resolves the OAuth bearer token at call time. The transport is given
  /// the most recent token on every invoke, so refresh + sign-out work
  /// without rebuilding the transport.
  String? _bearer() => _tokenProvider?.currentToken;

  @override
  Future<JsonMap> invoke({
    required String method,
    required HttpVerb verb,
    JsonMap arguments = const {},
    String? idempotencyKey,
  }) async {
    final url = Uri.parse('$_baseUrl/api/method/$method');
    final body = jsonEncode({'args': arguments});
    final started = _clock.nowUtc();

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final headers = <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Laratik-Client': 'mobile/0.1.0',
        };
        final token = _bearer();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
        if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
          headers['X-Idempotency-Key'] = idempotencyKey;
        }

        final response = await _httpClient
            .post(url, headers: headers, body: body)
            .timeout(_timeout);

        _logger.logApiCall(
          method: method,
          status: response.statusCode,
          duration: _clock.nowUtc().difference(started),
          attempt: attempt,
        );

        if (response.statusCode >= 500 && attempt < _maxAttempts) {
          await _backoff(attempt);
          continue;
        }
        return _decode(method, response);
      } on TimeoutException catch (e, st) {
        _logger.logTransportFailure(
          method: method,
          attempt: attempt,
          reason: 'timeout',
          error: e,
          stack: st,
        );
        if (attempt >= _maxAttempts) {
          throw TransportException(
            code: 'TIMEOUT',
            message: 'Request to $method timed out after $_timeout.',
          );
        }
        await _backoff(attempt);
      } on SocketException catch (e, st) {
        _logger.logTransportFailure(
          method: method,
          attempt: attempt,
          reason: 'socket',
          error: e,
          stack: st,
        );
        if (attempt >= _maxAttempts) {
          throw TransportException(
            code: 'NETWORK_UNREACHABLE',
            message: 'Cannot reach $method: ${e.message}',
          );
        }
        await _backoff(attempt);
      } on http.ClientException catch (e, st) {
        _logger.logTransportFailure(
          method: method,
          attempt: attempt,
          reason: 'http_client',
          error: e,
          stack: st,
        );
        if (attempt >= _maxAttempts) {
          throw TransportException(
            code: 'NETWORK_FAILURE',
            message: 'Network failure calling $method: ${e.message}',
          );
        }
        await _backoff(attempt);
      }
    }
    // Defensive: the loop above always either returns or throws.
    throw TransportException(
      code: 'UNREACHABLE',
      message: 'Transport did not produce a response for $method.',
    );
  }

  Future<Duration> _backoff(int attempt) async {
    final ms = (250 * (1 << (attempt - 1))).clamp(250, 2000);
    final delay = Duration(milliseconds: ms);
    await Future<void>.delayed(delay);
    return delay;
  }

  /// Unwrap the Frappe `{"message": ...}` envelope and return a JsonMap the
  /// SDK can decode into [ApiEnvelope].
  JsonMap _decode(String method, http.Response response) {
    final raw = utf8.decode(response.bodyBytes, allowMalformed: true);
    Map<String, Object?> outer;
    try {
      final parsed = jsonDecode(raw);
      if (parsed is! Map) {
        throw const FormatException('non-object body');
      }
      outer = Map<String, Object?>.from(parsed);
    } on FormatException catch (e) {
      throw TransportException(
        code: 'INVALID_RESPONSE',
        message: 'Response from $method was not valid JSON: ${e.message}',
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      // Surface auth errors so the auth layer can react (refresh / re-login).
      throw TransportException(
        code: response.statusCode == 401 ? 'UNAUTHENTICATED' : 'FORBIDDEN',
        message: outer['message'] is Map
            ? ((outer['message'] as Map)['message']?.toString() ??
                'Authentication failed for $method.')
            : 'Authentication failed for $method.',
      );
    }

    if (response.statusCode >= 400) {
      final message = outer['message'];
      throw TransportException(
        code: 'HTTP_${response.statusCode}',
        message: message is Map
            ? (message['message']?.toString() ?? message.toString())
            : (message?.toString() ?? 'Request failed with ${response.statusCode}.'),
      );
    }

    final message = outer['message'];
    if (message is Map) {
      return Map<String, Object?>.from(message);
    }
    if (message == null) {
      // Whitelisted method that returned None — return an empty envelope.
      return <String, Object?>{};
    }
    // Non-envelope return — wrap so the SDK can still decode something sane.
    return <String, Object?>{'data': message};
  }

  void close() => _httpClient.close();

  static String _normalizeBaseUrl(String url) {
    var u = url.trim();
    if (u.endsWith('/')) u = u.substring(0, u.length - 1);
    return u;
  }
}

/// Source of the OAuth bearer token used by the transport. Pulled at call
/// time so the auth layer can rotate or revoke without rebuilding the
/// transport graph.
abstract class TokenProvider {
  String? get currentToken;
}

/// Raised by the transport on hard failures (timeouts, auth errors, HTTP
/// non-success, malformed bodies). The auth layer catches this and decides
/// whether to refresh, sign out, or surface the error.
class TransportException implements Exception {
  const TransportException({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'TransportException($code): $message';
}
