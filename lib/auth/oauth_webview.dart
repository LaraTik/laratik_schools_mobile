import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../l10n/app_localizations.dart';

/// In-app WebView that runs the OAuth PKCE round-trip end-to-end.
///
/// Why not Chrome Custom Tabs (the previous `flutter_web_auth_2`
/// approach)? Android 9+ blocks cleartext HTTP to most non-localhost
/// hosts in Chrome's own process, regardless of the host app's
/// `network_security_config`. The dev flavor needs `http://10.0.2.2:8000`
/// for the emulator-to-host loopback, so Chrome Custom Tabs cannot
/// reach Frappe. Loading the authorize URL in an in-app `WebView`
/// means the request goes through our debug NSC, which already allows
/// cleartext to `10.0.2.2`. The redirect to `laratik://oauth/callback`
/// is intercepted in [NavigationDelegate.onNavigationRequest] — no
/// intent round-trip, no race with the OS router.
///
/// Returns the captured callback [Uri] via [Navigator.pop] (or `null`
/// if the user dismisses the sheet). The caller is responsible for
/// parsing it and performing the token exchange; this widget is just
/// a smarter browser.
class OauthWebViewScreen extends StatefulWidget {
  const OauthWebViewScreen({
    super.key,
    required this.authorizeUrl,
    required this.callbackScheme,
    this.callbackHost = 'oauth',
    this.title = 'Sign in',
  });

  /// The fully-built authorize URL. The WebView will follow every
  /// server-side redirect until it either lands on a page that the
  /// user dismisses, or the server redirects back to
  /// `<callbackScheme>://<callbackHost>/callback?…`.
  final Uri authorizeUrl;

  /// The custom URL scheme the OS / Frappe will redirect to once the
  /// user authenticates. Matches the Android `<data android:scheme>`
  /// entry in `AndroidManifest.xml` and the registered
  /// `redirect_uri` on the OAuth client. Typically `laratik` (dev /
  /// local) or `laratik-qa` (qa).
  final String callbackScheme;

  /// The host segment of the callback URI. We only fire the navigation
  /// rule when **both** the scheme and host match — this prevents the
  /// common foot-gun where a third-party analytics redirect uses the
  /// same scheme but a different path.
  final String callbackHost;

  final String title;

  @override
  State<OauthWebViewScreen> createState() => _OauthWebViewScreenState();
}

class _OauthWebViewScreenState extends State<OauthWebViewScreen> {
  late final WebViewController _controller;
  bool _completing = false;
  int _progress = 0;
  WebResourceError? _resourceError;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      // Frappe's login page runs inline JS (CSRF token rotation, the
      // remember-me toggle, etc.) and the OAuth consent screen on
      // production shells out to a JS bundle — unrestricted is the
      // safe default here.
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('LaratikSchoolsMobile/0.1 (Flutter; Android)')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (mounted) setState(() => _progress = p);
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) {
              // Malformed URL — don't try to navigate, don't try to
              // complete. Just block it.
              return NavigationDecision.prevent;
            }
            if (uri.scheme == widget.callbackScheme &&
                uri.host == widget.callbackHost) {
              _complete(uri);
              // We own the redirect — prevent the WebView from firing
              // an external intent.
              return NavigationDecision.prevent;
            }
            // Permit normal web navigation. We intentionally do not
            // allow `intent://` / `market://` / `tel:` / etc. — those
            // should be impossible on a Frappe login flow and would
            // mean a misconfigured server or a hostile link.
            if (uri.scheme == 'http' || uri.scheme == 'https') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
          onWebResourceError: (error) {
            if (mounted) setState(() => _resourceError = error);
          },
        ),
      )
      ..loadRequest(widget.authorizeUrl);
  }

  void _complete(Uri callback) {
    if (_completing) return;
    _completing = true;
    Navigator.of(context).pop<Uri>(callback);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final error = _resourceError;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          tooltip: l.commonClose,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: _progress > 0 && _progress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _progress / 100.0,
                  minHeight: 2,
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          if (error != null) _ErrorBanner(error: error),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.error});

  // `errorCode` is platform-typed (enum on web, int on Android), so we
  // stringify defensively rather than calling a getter that only exists
  // on one platform.
  final WebResourceError error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline,
                color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Could not load the sign-in page',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${error.errorCode} — ${error.description}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
