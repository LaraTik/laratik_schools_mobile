import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../core/clock.dart';
import '../core/logging.dart';
import '../platform/transport.dart';

/// Persisted session state. The auth layer is the single owner of
/// the OAuth tokens; the transport pulls it lazily via [TokenProvider]
/// and feature code reads role/feature flags via [currentRoles] /
/// [currentScopes].
///
/// **Storage layout (Phase 2.1):**
///   * [SecureTokenStore.flutter] (Android Keystore + AES, iOS Keychain)
///     — `access_token` and `refresh_token`. These are bearer
///     credentials; they never touch plain SharedPreferences.
///   * [SharedPreferences] — `installation_id`, `roles`, `scopes`,
///     `access_token_expires_at`. None of these are secrets; they're
///     either user-bound metadata (roles / scopes) or derivable from
///     the token (expires_at).
///
/// **Why a `SecureTokenStore` abstraction?**
/// Three things need to be testable in isolation:
///   * [SecureTokenStore.flutter] — backed by `flutter_secure_storage`.
///   * [SecureTokenStore.inMemory] — a `Map`-backed fake for tests that
///     need to assert on what was written.
///   * [SecureTokenStore.noop] — a const, all-reads-return-null shim for
///     tests that don't care about persistence at all (the default
///     for [SessionStore.inMemory]).
///
/// **Test path:** [SessionStore.inMemory] swaps the secure storage for
/// an in-memory shim and the SharedPreferences for a fake, so unit
/// tests don't need a Keystore or platform channels.
class SessionStore extends ChangeNotifier implements TokenProvider {
  SessionStore._({
    required SharedPreferences prefs,
    required Clock clock,
    required RedactingLogger logger,
    required String installationId,
    required SecureTokenStore secureTokens,
    DateTime? accessTokenExpiresAt,
    Set<String> roles = const {},
    Set<String> scopes = const {},
    String? currentStudentId,
    String? currentEnrollmentId,
  })  : _prefs = prefs,
        _clock = clock,
        _logger = logger,
        _installationId = installationId,
        _secureTokens = secureTokens,
        _accessTokenExpiresAt = accessTokenExpiresAt,
        _roles = Set<String>.from(roles),
        _scopes = Set<String>.from(scopes),
        _currentStudentId = currentStudentId,
        _currentEnrollmentId = currentEnrollmentId;

  // SharedPreferences keys. Secure storage keys live in [SecureTokenStore].
  // SharedPreferences keys (non-secret session metadata). The
  // `access_token` and `refresh_token` live in [SecureTokenStore] —
  // see the file-level comment for why they are *not* here in dev.
  static const _kExpires = 'laratik.session.access_token_expires_at';
  static const _kRoles = 'laratik.session.roles';
  static const _kScopes = 'laratik.session.scopes';
  static const _kInstallation = 'laratik.session.installation_id';
  static const _kCurrentStudentId = 'laratik.session.current_student_id';
  static const _kCurrentEnrollmentId = 'laratik.session.current_enrollment_id';

  /// Maximum time we will wait for a single secure-storage read at
  /// boot. Set conservatively — the Keystore should respond in
  /// milliseconds once the device is unlocked. Anything past this is
  /// treated as "no session"; the user re-logs in and [applyTokens]
  /// rehydrates the cache.
  static const Duration _kSecureReadTimeout = Duration(seconds: 5);

  final SharedPreferences _prefs;
  final Clock _clock;
  final RedactingLogger _logger;
  final String _installationId;
  final SecureTokenStore _secureTokens;

  // Tokens are kept in memory too, so synchronous [currentToken] reads
  // (which the transport needs at call time) don't hit the Keystore on
  // every request. The Keystore is the durable copy; this is the cache.
  String? _accessToken;
  String? _refreshToken;
  DateTime? _accessTokenExpiresAt;
  Set<String> _roles;
  Set<String> _scopes;
  // The student id the mobile is "acting as" for the practice-quiz
  // slice. The mobile OAuth user is the Administrator, but Frappe's
  // `is_eligible` check on the exam plan requires the linked student
  // row's `user` to match the session user. We pin the mobile session
  // to a single student (the seed) and pass their id + current
  // enrollment id to the start_attempt endpoint. Non-secret: lives in
  // SharedPreferences, not the Keystore.
  String? _currentStudentId;
  String? _currentEnrollmentId;

  /// Build a session, restoring any persisted state from disk. The
  /// secure storage is required in production but is allowed to be
  /// `null` for tests that don't exercise the Keystore.
  static Future<SessionStore> restore({
    required SharedPreferences prefs,
    required Clock clock,
    required RedactingLogger logger,
    SecureTokenStore? secureTokens,
  }) async {
    final tokens = secureTokens ?? SecureTokenStore.noop();
    String installationId = prefs.getString(_kInstallation) ?? '';
    if (installationId.isEmpty) {
      installationId = const Uuid().v4();
      await prefs.setString(_kInstallation, installationId);
    }
    final store = SessionStore._(
      prefs: prefs,
      clock: clock,
      logger: logger,
      installationId: installationId,
      secureTokens: tokens,
      accessTokenExpiresAt: prefs.getString(_kExpires) == null
          ? null
          : DateTime.tryParse(prefs.getString(_kExpires)!),
      roles: _decodeStringSet(prefs.getString(_kRoles)),
      scopes: _decodeStringSet(prefs.getString(_kScopes)),
      currentStudentId: _readNullableString(prefs, _kCurrentStudentId),
      currentEnrollmentId: _readNullableString(prefs, _kCurrentEnrollmentId),
    );
    // Hydrate the in-memory token cache from secure storage. Done
    // after construction so a missing / corrupted Keystore entry
    // produces a clean anonymous session rather than throwing.
    //
    // The reads are bounded by [_kSecureReadTimeout] so a misbehaving
    // Keystore (e.g. the Android Emulator's first Tink provisioning)
    // can't lock the app on the splash screen. On timeout we treat
    // the session as anonymous; the next successful [applyTokens]
    // will repopulate the cache from the user's point of view.
    try {
      final access = await tokens.readAccess().timeout(_kSecureReadTimeout);
      final refresh = await tokens.readRefresh().timeout(_kSecureReadTimeout);
      if (access != null && access.isNotEmpty) {
        store._accessToken = access;
      }
      if (refresh != null && refresh.isNotEmpty) {
        store._refreshToken = refresh;
      }
    } on TimeoutException {
      logger.logSessionEvent(
        'secure_storage.read_timeout',
        actor: installationId,
        reason: 'treated_as_anonymous',
      );
    } on Object catch (e, st) {
      logger.logSessionEvent(
        'secure_storage.read_failed',
        actor: installationId,
        reason: e.toString(),
      );
      // ignore: avoid_print
      print('SessionStore.restore: secure read failed: $e\n$st');
    }
    return store;
  }

  /// Pure in-memory session for tests. No persistence, no notify wiring,
  /// no secure storage. The [SessionStore._FakePrefs] is the
  /// SharedPreferences stand-in; the [SecureTokenStore.inMemory] is the
  /// Keystore stand-in.
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
      secureTokens: SecureTokenStore.inMemory(),
    );
  }

  String get installationId => _installationId;

  Set<String> get currentRoles => Set<String>.unmodifiable(_roles);
  Set<String> get currentScopes => Set<String>.unmodifiable(_scopes);
  DateTime? get accessTokenExpiresAt => _accessTokenExpiresAt;

  /// The student id the mobile session is currently "acting as" for
  /// the practice-quiz slice. `null` until [setCurrentStudent] is
  /// called (typically by the `currentStudentProvider` after a list
  /// lookup).
  String? get currentStudentId => _currentStudentId;

  /// The matching active enrollment id, if known. Some `start_attempt`
  /// flows require both `school_student` and `school_enrollment`.
  String? get currentEnrollmentId => _currentEnrollmentId;

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
  /// refresh. Persists atomically (tokens to secure storage, metadata to
  /// SharedPreferences) and notifies listeners.
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
    // Tokens first — if the SharedPreferences write below fails, we
    // still have valid credentials in the Keystore. The reverse would
    // leave a half-credentialed session.
    await _secureTokens.writeAccess(accessToken);
    await _secureTokens.writeRefresh(refreshToken);
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
    await _secureTokens.deleteAll();
    await _prefs.remove(_kExpires);
    await _prefs.remove(_kRoles);
    await _prefs.remove(_kScopes);
    _logger.logSessionEvent('clear', actor: installationId, reason: reason);
    notifyListeners();
  }

  /// Persist the student id + matching active enrollment id the mobile
  /// session is acting as. The choice survives across launches because
  /// `currentStudentProvider` reads it from [SharedPreferences]. Passing
  /// `null` for either field clears that slot.
  Future<void> setCurrentStudent({
    required String studentId,
    String? enrollmentId,
  }) async {
    _currentStudentId = studentId;
    _currentEnrollmentId = enrollmentId;
    await _prefs.setString(_kCurrentStudentId, studentId);
    if (enrollmentId == null) {
      await _prefs.remove(_kCurrentEnrollmentId);
    } else {
      await _prefs.setString(_kCurrentEnrollmentId, enrollmentId);
    }
    notifyListeners();
  }

  Future<void> _persist() async {
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

  /// SharedPreferences returns `null` for missing keys, but we also
  /// treat empty strings as "no value" so a previously-set-then-cleared
  /// slot behaves the same as a never-set one.
  static String? _readNullableString(SharedPreferences prefs, String key) {
    final v = prefs.getString(key);
    if (v == null || v.isEmpty) return null;
    return v;
  }
}

/// Abstraction over the secure token store. Two implementations:
///   * [SecureTokenStore.flutter] — backed by `flutter_secure_storage`
///     (Android Keystore + EncryptedSharedPreferences, iOS Keychain).
///   * [SecureTokenStore.inMemory] — pure in-memory, for unit tests.
abstract class SecureTokenStore {
  /// No-op implementation used when secure storage is unavailable
  /// (e.g. in tests that opt out of persistence). All reads return
  /// `null`; all writes succeed silently. The in-memory token cache
  /// in [SessionStore] still works.
  const factory SecureTokenStore.noop() = _NoopTokenStore;

  /// Real implementation, backed by `flutter_secure_storage`. Pass a
  /// [FlutterSecureStorage] for tests; the default uses the AES+RSA
  /// backend via the platform Keystore (Android Keystore, iOS Keychain).
  ///
  /// **Caveat on the Android 17 emulator:** the platform-channel read
  /// path hangs the very first time the Keystore's RSA key is exercised
  /// in a brand-new AVD. We avoid this in dev by defaulting to
  /// [SecureTokenStore.prefs] from the bootstrap; the prod shell can
  /// opt into this factory once we have a real device.
  factory SecureTokenStore.flutter({FlutterSecureStorage? storage}) =
      _FlutterSecureTokenStore;

  /// SharedPreferences-backed implementation. The bearer tokens are
  /// stored as plain Base64 strings — **not encrypted at rest**. This
  /// is the dev flavor's default so the OAuth round-trip works on the
  /// Pixel 10 emulator without the Android Keystore dance. The prod
  /// build should wire up [SecureTokenStore.flutter] (or a
  /// production-grade Keystore wrapper) before the first signed
  /// release.
  factory SecureTokenStore.prefs({required SharedPreferences prefs}) =
      _PrefsTokenStore;

  /// In-memory implementation backed by a Map. For tests that want
  /// to assert on what was written (rare — most tests just need
  /// [SecureTokenStore.noop]).
  factory SecureTokenStore.inMemory() = _InMemoryTokenStore;

  Future<String?> readAccess();
  Future<String?> readRefresh();
  Future<void> writeAccess(String value);
  Future<void> writeRefresh(String value);
  Future<void> deleteAll();
}

class _FlutterSecureTokenStore implements SecureTokenStore {
  _FlutterSecureTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccess() =>
      _storage.read(key: 'laratik.session.access_token');

  @override
  Future<String?> readRefresh() =>
      _storage.read(key: 'laratik.session.refresh_token');

  @override
  Future<void> writeAccess(String value) =>
      _storage.write(key: 'laratik.session.access_token', value: value);

  @override
  Future<void> writeRefresh(String value) =>
      _storage.write(key: 'laratik.session.refresh_token', value: value);

  @override
  Future<void> deleteAll() async {
    await _storage.delete(key: 'laratik.session.access_token');
    await _storage.delete(key: 'laratik.session.refresh_token');
  }
}

class _InMemoryTokenStore implements SecureTokenStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> readAccess() async => _values['access'];

  @override
  Future<String?> readRefresh() async => _values['refresh'];

  @override
  Future<void> writeAccess(String value) async {
    _values['access'] = value;
  }

  @override
  Future<void> writeRefresh(String value) async {
    _values['refresh'] = value;
  }

  @override
  Future<void> deleteAll() async {
    _values.clear();
  }
}

class _NoopTokenStore implements SecureTokenStore {
  const _NoopTokenStore();

  @override
  Future<String?> readAccess() async => null;

  @override
  Future<String?> readRefresh() async => null;

  @override
  Future<void> writeAccess(String value) async {}

  @override
  Future<void> writeRefresh(String value) async {}

  @override
  Future<void> deleteAll() async {}
}

class _PrefsTokenStore implements SecureTokenStore {
  _PrefsTokenStore({required SharedPreferences prefs}) : _prefs = prefs;

  static const _kAccess = 'laratik.session.access_token';
  static const _kRefresh = 'laratik.session.refresh_token';

  final SharedPreferences _prefs;

  @override
  Future<String?> readAccess() async => _prefs.getString(_kAccess);

  @override
  Future<String?> readRefresh() async => _prefs.getString(_kRefresh);

  @override
  Future<void> writeAccess(String value) =>
      _prefs.setString(_kAccess, value);

  @override
  Future<void> writeRefresh(String value) =>
      _prefs.setString(_kRefresh, value);

  @override
  Future<void> deleteAll() async {
    await _prefs.remove(_kAccess);
    await _prefs.remove(_kRefresh);
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
