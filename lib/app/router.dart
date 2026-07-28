import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../auth/session.dart';
import '../core/clock.dart';
import '../core/logging.dart';

/// Router configuration. The route table is owned here; per-feature deep links
/// register their own sub-routers once those features land. Until then the
/// foundation exposes:
///   - /splash          app boot, capability snapshot
///   - /auth/login      OAuth PKCE entry
///   - /auth/callback   OAuth PKCE redirect target
///   - /shell           post-auth, role-aware navigation chrome
///   - /error           global error sink
GoRouter buildRouter({
  required LaratikSchoolsApiClient api,
  required SessionStore session,
  required RedactingLogger logger,
  required Clock clock,
}) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: SessionListenable(session),
    redirect: (context, state) {
      final isAuthed = session.hasToken;
      final loggingIn = state.matchedLocation.startsWith('/auth');
      if (!isAuthed && !loggingIn) return '/auth/login';
      if (isAuthed && state.matchedLocation == '/auth/login') return '/shell';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const _LoginScreen(),
      ),
      GoRoute(
        path: '/auth/callback',
        name: 'oauth_callback',
        builder: (context, state) => const _OAuthCallbackScreen(),
      ),
      GoRoute(
        path: '/shell',
        name: 'shell',
        builder: (context, state) => const _ShellScreen(),
      ),
      GoRoute(
        path: '/error',
        name: 'error',
        builder: (context, state) => const _ErrorScreen(),
      ),
    ],
    errorBuilder: (context, state) => const _ErrorScreen(),
  );
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) => const _Placeholder(label: 'Splash');
}

class _LoginScreen extends StatelessWidget {
  const _LoginScreen();

  @override
  Widget build(BuildContext context) => const _Placeholder(label: 'Login');
}

class _OAuthCallbackScreen extends StatelessWidget {
  const _OAuthCallbackScreen();

  @override
  Widget build(BuildContext context) => const _Placeholder(label: 'OAuth callback');
}

class _ShellScreen extends StatelessWidget {
  const _ShellScreen();

  @override
  Widget build(BuildContext context) => const _Placeholder(label: 'Shell');
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) => const _Placeholder(label: 'Error');
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }
}
