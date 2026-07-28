import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../core/clock.dart';
import '../core/logging.dart';
import '../platform/transport.dart';

/// Persisted, in-memory session state. The auth layer is the single owner of
/// the OAuth token; the transport pulls it lazily via [TokenProvider] and
/// feature code reads role/feature flags via [currentRoles] / [currentScopes].
class SessionStore extends ChangeNotifier implements TokenProvider {
  SessionStore._({
    required SharedPreferences prefs,
    required Clock clock,
    required RedactingLogger logger,
    required String installationId,
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiresAt,
    Set<String> roles = const {},
    Set<String> scopes = const {},
  })  : _prefs = prefs,
        _clock = clock,
        _logger = logger,
        _installationId = installationId,
        _accessToken = accessToken,
        _refreshToken = refreshToken,
        _accessTokenExpiresAt = accessTokenExpiresAt,
        _roles = Set<String>.from(roles),
        _scopes = Set<String>.from(scopes);

  static const _kAccess = 'laratik.session.access_token';
  static const _kRefresh = 'laratik.session.refresh_token';
  static const _kExpires = 'laratik.session.access_token_expires_at';
  static const _kRoles = 'laratik.session.roles';
  static const _kScopes = 'laratik.session.scopes';
  static const _kInstallation = 'laratik.session.installation_id';

  final SharedPreferences _prefs;
  final Clock _clock;
  final RedactingLogger _logger;
  final String _installationId;

  String? _accessToken;
  String? _refreshToken;
  DateTime? _accessTokenExpiresAt;
  Set<String> _roles;
  Set<String> _scopes;

  /// Build a session, restoring any persisted state from disk. If no
  /// installation ID is persisted yet, a new one is minted and stored.
  static Future<SessionStore> restore({
    required SharedPreferences prefs,
    required Clock clock,
    required RedactingLogger logger,
  }) async {
    String installationId = prefs.getString(_kInstallation) ?? '';
    if (installationId.isEmpty) {
      installationId = const Uuid().v4();
      await prefs.setString(_kInstallation, installationId);
    }
    return SessionStore._(
      prefs: prefs,
      clock: clock,
      logger: logger,
      installationId: installationId,
      accessToken: prefs.getString(_kAccess),
      refreshToken: prefs.getString(_kRefresh),
      accessTokenExpiresAt: prefs.getString(_kExpires) == null
          ? null
          : DateTime.tryParse(prefs.getString(_kExpires)!),
      roles: _decodeStringSet(prefs.getString(_kRoles)),
      scopes: _decodeStringSet(prefs.getString(_kScopes)),
    );
  }

  /// Pure in-memory session for tests. No persistence, no notify wiring.
  @visibleForTesting
  static SessionStore inMemory({
    required Clock clock,
    required RedactingLogger logger,
    String installationId = 'test-installation',
  }) {
    return SessionStore._(
      prefs: _FakePrefs.empty(),
      clock: clock,
      logger: logger,
      installationId: installationId,
    );
  }

  String get installationId => _installationId;

  Set<String> get currentRoles => Set<String>.unmodifiable(_roles);
  Set<String> get currentScopes => Set<String>.unmodifiable(_scopes);
  DateTime? get accessTokenExpiresAt => _accessTokenExpiresAt;

  bool get hasToken {
    final token = _accessToken;
    if (token == null || token.isEmpty) return false;
    final expires = _accessTokenExpiresAt;
    if (expires == null) return true;
    return _clock.nowUtc().isBefore(expires);
  }

  @override
  String? get currentToken => hasToken ? _accessToken : null;

  String? get currentRefreshToken => _refreshToken;

  /// Update the session after a successful authorization-code exchange or
  /// refresh. Persists atomically and notifies listeners.
  Future<void> applyTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiresAt,
    Set<String> roles = const {},
    Set<String> scopes = const {},
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _accessTokenExpiresAt = accessTokenExpiresAt;
    _roles = Set<String>.from(roles);
    _scopes = Set<String>.from(scopes);
    await _persist();
    _logger.logSessionEvent('apply_tokens', actor: installationId);
    notifyListeners();
  }

  /// Wipe credentials on sign-out or hard auth failure. Keeps the
  /// installation ID so the next sign-in reuses the same device record.
  Future<void> clear({String reason = 'sign_out'}) async {
    _accessToken = null;
    _refreshToken = null;
    _accessTokenExpiresAt = null;
    _roles = const {};
    _scopes = const {};
    await _prefs.remove(_kAccess);
    await _prefs.remove(_kRefresh);
    await _prefs.remove(_kExpires);
    await _prefs.remove(_kRoles);
    await _prefs.remove(_kScopes);
    _logger.logSessionEvent('clear', actor: installationId, reason: reason);
    notifyListeners();
  }

  Future<void> _persist() async {
    await _prefs.setString(_kAccess, _accessToken ?? '');
    await _prefs.setString(_kRefresh, _refreshToken ?? '');
    await _prefs.setString(
      _kExpires,
      _accessTokenExpiresAt?.toIso8601String() ?? '',
    );
    await _prefs.setString(_kRoles, _encodeStringSet(_roles));
    await _prefs.setString(_kScopes, _encodeStringSet(_scopes));
  }

  static String _encodeStringSet(Set<String> values) {
    return base64Url.encode(utf8.encode(jsonEncode(values.toList()..sort())));
  }

  static Set<String> _decodeStringSet(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(utf8.decode(base64Url.decode(raw)));
      if (decoded is List) {
        return decoded.cast<String>().toSet();
      }
    } catch (_) {
      return const {};
    }
    return const {};
  }
}

/// Adapter that lets the GoRouter react to session changes (sign-in /
/// sign-out) by re-evaluating its `redirect` callback.
class SessionListenable extends ChangeNotifier {
  SessionListenable(this._session) {
    _session.addListener(notifyListeners);
  }

  final SessionStore _session;

  @override
  void dispose() {
    _session.removeListener(notifyListeners);
    super.dispose();
  }
}

/// In-memory SharedPreferences stand-in for unit tests. Persists nothing;
/// every read returns the constructor snapshot and every write is a no-op.
class _FakePrefs implements SharedPreferences {
  _FakePrefs._(this._values);
  factory _FakePrefs.empty() => _FakePrefs._({});

  final Map<String, Object> _values;

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      '_FakePrefs only implements setString / getString / remove for tests; '
      'called ${invocation.memberName}',
    );
  }
}
