import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/oauth_browser.dart';
import '../auth/oauth_flow.dart';
import '../auth/session.dart';
import '../config/flavor_loader.dart';
import '../core/clock.dart';
import '../core/logging.dart';
import '../l10n/app_localizations.dart';
import '../ui/app_theme.dart';
import '../ui/widgets/ls_button.dart';
import '../ui/widgets/ls_status_chip.dart';

/// Login screen. The OAuth flow is wired to the system browser via
/// `flutter_web_auth_2`; the redirect scheme is configured per flavor
/// (e.g. `laratik://oauth/callback` in dev, qa, prod) per ADR 0003.
/// **All** environment-specific values are read from [appConfigProvider]
/// — never hard-coded — so the same screen code runs in test, dev,
/// local, qa, and prod.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _signingIn = false;
  String? _error;

  Future<void> _signIn() async {
    if (_signingIn) return;
    setState(() {
      _signingIn = true;
      _error = null;
    });
    // Pull the OAuth flow off the bootstrap graph so the same wiring is
    // exercised in tests via `bootstrap(... transportFactory, sessionFactory)`.
    final flow = _oauthFlow();
    final result = await flow.run();
    if (!mounted) return;
    setState(() => _signingIn = false);
    switch (result) {
      case OauthSuccess():
        context.go('/shell');
      case OauthFailure(:final code, :final message):
        setState(() => _error = '$code — $message');
    }
  }

  OauthFlow _oauthFlow() {
    final container = ProviderScope.containerOf(context, listen: false);
    final config = container.read(appConfigProvider);
    final session = container.read(sessionProvider);
    final clock = container.read(clockProvider);
    final logger = container.read(loggerProvider);
    // All OAuth URLs are derived from AppConfig — no hard-coded hostnames
    // anywhere in the login screen.
    final baseUri = Uri.parse(config.baseUrl);
    final authorizeBase = baseUri.resolve(
      '/api/method/frappe.integrations.oauth2.authorize',
    );
    final tokenBase = baseUri.resolve(
      '/api/method/frappe.integrations.oauth2.get_token',
    );
    return OauthFlow(
      authorizeUrl: authorizeBase,
      tokenUrl: tokenBase,
      clientId: config.oauthClientId,
      // Host is always "oauth" — the scheme comes from the flavor so
      // dev / local / qa / prod can register parallel redirect URIs
      // (e.g. `laratik-dev://oauth/callback`) without touching this code.
      redirectUri: Uri.parse('${config.oauthRedirectScheme}://oauth/callback'),
      scope: 'openid all',
      session: session,
      clock: clock,
      logger: logger,
      // WebView, not Chrome Custom Tabs: Chrome's process would block
      // cleartext HTTP to 10.0.2.2, which the dev flavor needs. Our
      // debug NSC allows it; the in-app WebView honors the NSC.
      // The root navigator (above the GoRouter) is what we push onto
      // so dismissing the WebView returns to the login screen.
      launcher: WebViewOauthBrowserLauncher(
        navigator: Navigator.of(context, rootNavigator: true),
        callbackScheme: config.oauthRedirectScheme,
        title: AppLocalizations.of(context).loginButton,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(tokens.space.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.loginScreenTitle,
                    textAlign: TextAlign.center,
                    style: tokens.typography.headlineLarge.copyWith(
                      color: tokens.text.primary,
                    ),
                  ),
                  SizedBox(height: tokens.space.sm),
                  Text(
                    l.loginSignInSubtitle,
                    textAlign: TextAlign.center,
                    style: tokens.typography.bodyLarge.copyWith(
                      color: tokens.text.secondary,
                    ),
                  ),
                  SizedBox(height: tokens.space.xl),
                  Container(
                    padding: EdgeInsets.all(tokens.space.md),
                    decoration: BoxDecoration(
                      color: tokens.surface.surface,
                      borderRadius: BorderRadius.circular(tokens.radius.md),
                      border: Border.all(color: tokens.surface.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: tokens.status.success,
                        ),
                        SizedBox(width: tokens.space.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.loginOAuthPkceTitle,
                                style: tokens.typography.titleSmall.copyWith(
                                  color: tokens.text.primary,
                                ),
                              ),
                              SizedBox(height: tokens.space.xxs),
                              Text(
                                l.loginOAuthPkceMessage,
                                style: tokens.typography.bodySmall.copyWith(
                                  color: tokens.text.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        LsStatusChip(
                          label: l.loginSsoChip,
                          tone: LsChipTone.brand,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: tokens.space.lg),
                  if (_error != null)
                    Container(
                      padding: EdgeInsets.all(tokens.space.md),
                      decoration: BoxDecoration(
                        color: tokens.status.errorContainer,
                        borderRadius: BorderRadius.circular(tokens.radius.md),
                        border: Border.all(color: tokens.status.error),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: tokens.status.error,
                            size: 18,
                          ),
                          SizedBox(width: tokens.space.sm),
                          Expanded(
                            child: Text(
                              _error!,
                              style: tokens.typography.bodyMedium.copyWith(
                                color: tokens.status.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_error != null) SizedBox(height: tokens.space.md),
                  LsButton.primary(
                    label: _signingIn ? l.loginButtonLoading : l.loginButton,
                    icon: _signingIn ? Icons.hourglass_empty : Icons.login,
                    isLoading: _signingIn,
                    onPressed: _signingIn ? null : _signIn,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Re-export the session, clock, and logger from the bootstrap graph so the
/// login screen can build an [OauthFlow] without duplicating constructor
/// wiring. Lives here so the auth layer owns the OAuth concerns.
final sessionProvider = Provider<SessionStore>(
  (ref) =>
      throw StateError('sessionProvider must be overridden by bootstrap()'),
);
final clockProvider = Provider<Clock>(
  (ref) => throw StateError('clockProvider must be overridden by bootstrap()'),
);
final loggerProvider = Provider<RedactingLogger>(
  (ref) => throw StateError('loggerProvider must be overridden by bootstrap()'),
);
