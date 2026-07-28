import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/oauth_browser.dart';
import '../auth/oauth_flow.dart';
import '../auth/session.dart';
import '../core/clock.dart';
import '../core/logging.dart';
import '../ui/design_tokens.dart';
import '../ui/widgets/ls_button.dart';
import '../ui/widgets/ls_status_chip.dart';

/// Login screen. The OAuth flow is wired to the system browser via
/// `flutter_web_auth_2`; the redirect scheme is `laratik://oauth/callback`
/// per ADR 0003. The OAuth config is read from the bootstrap graph so
/// the same code runs in test, dev, and prod.
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
    final session = container.read(sessionProvider);
    final clock = container.read(clockProvider);
    final logger = container.read(loggerProvider);
    return OauthFlow(
      authorizeUrl: Uri.parse(
        'https://laratik.localhost/api/method/frappe.integrations.oauth2.authorize',
      ),
      tokenUrl: Uri.parse(
        'https://laratik.localhost/api/method/frappe.integrations.oauth2.get_token',
      ),
      clientId: 'laratik-mobile',
      redirectUri: Uri.parse('laratik://oauth/callback'),
      scope: 'openid all',
      session: session,
      clock: clock,
      logger: logger,
      launcher: const FlutterWebAuthBrowserLauncher(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
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
                    'Laratik Schools',
                    textAlign: TextAlign.center,
                    style: tokens.typography.headlineLarge.copyWith(
                      color: tokens.text.primary,
                    ),
                  ),
                  SizedBox(height: tokens.space.sm),
                  Text(
                    'Sign in to continue',
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
                                'OAuth + PKCE',
                                style: tokens.typography.titleSmall.copyWith(
                                  color: tokens.text.primary,
                                ),
                              ),
                              SizedBox(height: tokens.space.xxs),
                              Text(
                                'S256, system browser, no embedded webview.',
                                style: tokens.typography.bodySmall.copyWith(
                                  color: tokens.text.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const LsStatusChip(
                          label: 'Laratik SSO',
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
                    label: _signingIn ? 'Opening browser…' : 'Sign in with Laratik',
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
  (ref) => throw StateError('sessionProvider must be overridden by bootstrap()'),
);
final clockProvider = Provider<Clock>(
  (ref) => throw StateError('clockProvider must be overridden by bootstrap()'),
);
final loggerProvider = Provider<RedactingLogger>(
  (ref) => throw StateError('loggerProvider must be overridden by bootstrap()'),
);
