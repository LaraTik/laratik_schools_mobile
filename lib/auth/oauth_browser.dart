import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'oauth_flow.dart';

/// Production [OauthBrowserLauncher] using `flutter_web_auth_2`.
///
/// On iOS this opens an `ASWebAuthenticationSession`; on Android, a
/// Custom Tab. The redirect scheme (e.g. `laratik://oauth/callback`)
/// must be registered in the iOS Info.plist and the Android
/// `AndroidManifest.xml` for the OS to hand control back to the app.
///
/// `flutter_web_auth_2` 2.1+ exposes a single `authenticate({url,
/// callbackUrlScheme, preferEphemeral})` entry point — we use the
/// default (OS browser) surface and pass `preferEphemeral: false` so
/// the user can re-use the same SSO cookies they would in Safari /
/// Chrome. The server side binds to `laratik-mobile` OAuth client per
/// ADR 0003.
class FlutterWebAuthBrowserLauncher implements OauthBrowserLauncher {
  const FlutterWebAuthBrowserLauncher({
    this.callbackUrlScheme = 'laratik',
    this.preferEphemeral = false,
  });

  /// The scheme that the OS hands back to the app via universal links
  /// or app links. Matches the registration in the iOS Info.plist and
  /// the Android `AndroidManifest.xml` intent filter.
  final String callbackUrlScheme;

  /// Pass-through to `flutter_web_auth_2`'s `preferEphemeral`. When
  /// `true`, the OS browser runs in incognito / private mode and does
  /// not share cookies with the regular browser session.
  final bool preferEphemeral;

  @override
  Future<Uri?> open(Uri authorizeUrl) async {
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authorizeUrl.toString(),
        callbackUrlScheme: callbackUrlScheme,
        preferEphemeral: preferEphemeral,
      );
      if (result.isEmpty) return null;
      return Uri.parse(result);
    } on PlatformException {
      return null;
    }
  }
}
