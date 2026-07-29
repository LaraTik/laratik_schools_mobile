import 'package:flutter/material.dart';

import 'oauth_flow.dart';
import 'oauth_webview.dart';

/// In-app [OauthBrowserLauncher] backed by a [WebViewWidget].
///
/// Loads the authorize URL in a fullscreen [OauthWebViewScreen] pushed
/// onto the root [Navigator], and returns the captured
/// `<scheme>://oauth/callback?…` URI to the OAuth flow. Bypasses
/// Chrome Custom Tabs entirely so the dev flavor's
/// `network_security_config` governs the requests — Chrome's process
/// would otherwise block cleartext HTTP to `10.0.2.2` and the user
/// would see the "Open in browser" fallback instead of the real
/// Frappe login page.
///
/// The login screen passes its own root [NavigatorState] in (captured
/// via `Navigator.of(context, rootNavigator: true)`); the auth layer
/// stays decoupled from the widget tree without needing a global
/// `GlobalKey`.
///
/// **History:** the original `flutter_web_auth_2`-backed launcher was
/// retired once we confirmed the in-app WebView works on every flavor.
/// The intent filter for `laratik://oauth/callback` is still in
/// `AndroidManifest.xml` so email magic links / universal links from
/// the host browser still land back in the app.
class WebViewOauthBrowserLauncher implements OauthBrowserLauncher {
  const WebViewOauthBrowserLauncher({
    required this.navigator,
    required this.callbackScheme,
    this.title = 'Sign in',
  });

  /// Root navigator captured by the caller. Pushing on it places the
  /// WebView above the current route (e.g. the login screen) so
  /// dismissing it returns the user to where they were.
  final NavigatorState navigator;

  final String callbackScheme;
  final String title;

  @override
  Future<Uri?> open(Uri authorizeUrl) async {
    final result = await navigator.push<Uri>(
      MaterialPageRoute<Uri>(
        fullscreenDialog: true,
        builder: (_) => OauthWebViewScreen(
          authorizeUrl: authorizeUrl,
          callbackScheme: callbackScheme,
          title: title,
        ),
      ),
    );
    return result;
  }
}
