import 'app_config.dart';
import 'app_flavor.dart';

/// Central registry of every supported [AppConfig]. **This is the one
/// file the team edits** when a new environment goes live, a host URL
/// changes, or a new OAuth client is registered server-side.
///
/// Adding a new flavor is a 2-step contract:
///   1. Extend [AppFlavor] in `app_flavor.dart` with a new enum value.
///   2. Add a matching const [AppConfig] below and wire it into [of].
///
/// Nothing else in the app needs to know which environment it's in —
/// everything flows from the [AppConfig] that bootstrap() resolves.
class FlavorRegistry {
  const FlavorRegistry._();

  // -------------------------------------------------------------------------
  // dev — Android emulator on the same machine as the dev backend.
  // The `10.0.2.2` hostname is the Android emulator's alias for the host
  // machine's loopback. Cleartext is allowed via the debug network
  // security config (android/app/src/debug/res/xml/network_security_config.xml).
  // -------------------------------------------------------------------------
  static const AppConfig dev = AppConfig(
    flavor: AppFlavor.dev,
    baseUrl: 'http://10.0.2.2:8000',
    oauthClientId: 'laratik-mobile',
    oauthRedirectScheme: 'laratik',
    universalLinksDomain: 'laratik.localhost',
    appDisplayName: 'Laratik Schools (Dev)',
    appIdSuffix: '.dev',
    allowCleartext: true,
  );

  // -------------------------------------------------------------------------
  // local — physical device on the same Wi-Fi as the dev host.
  // Replace the LAN IP below with the dev machine's current IP. The app ID
  // suffix differs from dev so a single phone can carry both side-by-side.
  // -------------------------------------------------------------------------
  static const AppConfig local = AppConfig(
    flavor: AppFlavor.local,
    baseUrl: 'http://192.168.1.42:8000', // ← update when the dev machine moves
    oauthClientId: 'laratik-mobile',
    oauthRedirectScheme: 'laratik',
    universalLinksDomain: 'laratik.localhost',
    appDisplayName: 'Laratik Schools (Local)',
    appIdSuffix: '.local',
    allowCleartext: true,
  );

  // -------------------------------------------------------------------------
  // qa — staging environment. Placeholder URL until the QA host is
  // provisioned. Also needs a `laratik-mobile-qa` OAuth client registered
  // server-side before this can actually authenticate.
  // -------------------------------------------------------------------------
  static const AppConfig qa = AppConfig(
    flavor: AppFlavor.qa,
    baseUrl: 'https://qa.laratik.app', // ← update when QA host is live
    oauthClientId: 'laratik-mobile-qa',
    oauthRedirectScheme: 'laratik',
    universalLinksDomain: 'laratik.app',
    appDisplayName: 'Laratik Schools (QA)',
    appIdSuffix: '.qa',
    allowCleartext: false,
  );

  // -------------------------------------------------------------------------
  // prod — production. HTTPS only, no appIdSuffix (the bare bundle id is
  // the production one), no debug overrides.
  // -------------------------------------------------------------------------
  static const AppConfig prod = AppConfig(
    flavor: AppFlavor.prod,
    baseUrl: 'https://laratik.app',
    oauthClientId: 'laratik-mobile',
    oauthRedirectScheme: 'laratik',
    universalLinksDomain: 'laratik.app',
    appDisplayName: 'Laratik Schools',
    appIdSuffix: '',
    allowCleartext: false,
  );

  /// Lookup a flavor by enum value. Every [AppFlavor] must be present;
  /// the switch is exhaustive so adding a new flavor without registering
  /// it here is a compile-time error.
  static AppConfig of(AppFlavor flavor) => switch (flavor) {
        AppFlavor.dev => dev,
        AppFlavor.local => local,
        AppFlavor.qa => qa,
        AppFlavor.prod => prod,
      };
}
