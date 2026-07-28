import 'dart:io';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'oauth_flow.dart';

/// Production [OauthBrowserLauncher] using `flutter_web_auth_2`.
///
/// On iOS this opens an `ASWebAuthenticationSession`; on Android, a
/// Custom Tab. The redirect scheme (e.g. `laratik://oauth/callback`)
/// must be registered in the iOS Info.plist and the Android
/// `AndroidManifest.xml` for the OS to hand control back to the app.
class FlutterWebAuthBrowserLauncher implements OauthBrowserLauncher {
  const FlutterWebAuthBrowserLauncher();

  @override
  Future<Uri?> open(Uri authorizeUrl) async {
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authorizeUrl.toString(),
        options: const AuthenticationBrowserOptions(
          // Use the OS browser, not an embedded webview; matches the
          // Laratik mobile security configuration (see
          // laratik_schools.core.mobile_platform).
          useWebview: false,
        ),
      );
      if (result.isEmpty) return null;
      return Uri.parse(result);
    } on PlatformException {
      return null;
    }
  }
}
