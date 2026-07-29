/// Build-time app flavor. Selects which [AppConfig] the runtime loads and
/// (on Android) the applicationIdSuffix + appName the build produces.
///
/// Pass via `--dart-define=APP_FLAVOR=<id>` at build/run time; defaults to
/// [dev] when unset so `flutter run` with no flags works out of the box.
///
/// To add a new environment:
///   1. Add an enum value below.
///   2. Add the matching [AppConfig] entry in `flavor_config.dart`.
///   3. (Android) Add the applicationIdSuffix + appName mapping in
///      `android/app/build.gradle.kts` so the build produces a
///      side-by-side installable APK.
library;

enum AppFlavor {
  /// Android emulator → host machine (10.0.2.2:8000). Cleartext HTTP
  /// allowed to the dev host via the debug-only network security config.
  dev,

  /// Physical device on the same LAN as the dev host. Update the LAN IP
  /// in [FlavorRegistry.local] when the dev machine moves networks.
  local,

  /// Staging / QA environment. Placeholder URL until the QA host is live;
  /// also needs a server-side `laratik-mobile-qa` OAuth client.
  qa,

  /// Production. HTTPS only, no debug overrides, no appIdSuffix.
  prod,
}

extension AppFlavorX on AppFlavor {
  /// Stable lowercase identifier used in `--dart-define=APP_FLAVOR=<id>`
  /// and in the runtime registry.
  String get id => switch (this) {
        AppFlavor.dev => 'dev',
        AppFlavor.local => 'local',
        AppFlavor.qa => 'qa',
        AppFlavor.prod => 'prod',
      };

  /// Short uppercase tag used in logs and crash reports so the active
  /// environment is immediately visible.
  String get tag => switch (this) {
        AppFlavor.dev => 'DEV',
        AppFlavor.local => 'LOCAL',
        AppFlavor.qa => 'QA',
        AppFlavor.prod => 'PROD',
      };

  /// Parse a raw `--dart-define` value into an [AppFlavor]. Throws on
  /// unknown values so misconfigurations fail loudly at startup instead of
  /// silently picking the wrong backend.
  static AppFlavor fromString(String? raw) {
    if (raw == null || raw.isEmpty) return AppFlavor.dev;
    final normalized = raw.toLowerCase();
    for (final f in AppFlavor.values) {
      if (f.id == normalized) return f;
    }
    throw ArgumentError.value(
      raw,
      'APP_FLAVOR',
      'Unknown flavor. Known: ${AppFlavor.values.map((f) => f.id).join(', ')}',
    );
  }
}
