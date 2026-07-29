import 'package:meta/meta.dart';

import 'app_flavor.dart';

/// Immutable per-environment configuration. One [AppConfig] is constructed
/// at app startup from the active [AppFlavor] (see [FlavorLoader]) and
/// threaded through [bootstrap].
///
/// **This is the single source of truth for environment-specific values.**
/// Anywhere in the app that needs a base URL, OAuth client, app name, or
/// bundle suffix should read it from the [AppConfig] resolved at startup
/// — never from a hard-coded literal.
///
/// To change a value: edit the matching entry in `flavor_config.dart`.
@immutable
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.baseUrl,
    required this.oauthClientId,
    required this.oauthRedirectScheme,
    required this.universalLinksDomain,
    required this.appDisplayName,
    required this.appIdSuffix,
    required this.allowCleartext,
  });

  /// The active flavor this config belongs to.
  final AppFlavor flavor;

  /// Origin (scheme + host + port) the HTTP transport uses for every
  /// request. Examples:
  ///   - dev:   `http://10.0.2.2:8000`
  ///   - local: `http://192.168.1.42:8000`
  ///   - qa:    `https://qa.laratik.app`
  ///   - prod:  `https://laratik.app`
  final String baseUrl;

  /// OAuth `client_id` registered server-side for this app surface.
  /// ADR 0003.
  final String oauthClientId;

  /// URL scheme the OS hands back via universal/app links. Must be
  /// registered in Info.plist (iOS) and the AndroidManifest intent filter
  /// (Android) for the same flavor.
  final String oauthRedirectScheme;

  /// Universal links / app links host. Placeholder until DNS is wired.
  final String universalLinksDomain;

  /// Human-readable app name shown in the launcher + title bars.
  final String appDisplayName;

  /// Suffix appended to the Android `applicationId` for this flavor so
  /// dev / local / qa installs can coexist on the same device. Empty
  /// string for production.
  final String appIdSuffix;

  /// When true, the Android network security config permits cleartext
  /// HTTP to the dev hosts. Production MUST stay false.
  final bool allowCleartext;

  @override
  String toString() => 'AppConfig(flavor: ${flavor.id}, baseUrl: $baseUrl)';
}
