import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../auth/session.dart';
import '../core/clock.dart';
import '../core/logging.dart';
import '../features/guardians/ui/guardian_create_screen.dart';
import '../features/guardians/ui/guardian_detail_screen.dart';
import '../features/guardians/ui/guardians_list_screen.dart';
import '../features/people/ui/student_create_screen.dart';
import '../features/people/ui/student_detail_screen.dart';
import '../features/people/ui/students_list_screen.dart';
import '../features/staff/ui/staff_create_screen.dart';
import '../features/staff/ui/staff_detail_screen.dart';
import '../features/staff/ui/staff_list_screen.dart';
import '../ui/design_tokens.dart';

/// Top-level navigation destinations. The shell renders these in a bottom
/// navigation bar. Order matters — left-to-right is the operator's mental
/// model (most-used first, admin surfaces last).
enum ShellTab { dashboard, students, staff, guardians, more }

extension ShellTabX on ShellTab {
  String get label => switch (this) {
        ShellTab.dashboard => 'Home',
        ShellTab.students => 'Students',
        ShellTab.staff => 'Staff',
        ShellTab.guardians => 'Guardians',
        ShellTab.more => 'More',
      };

  IconData get icon => switch (this) {
        ShellTab.dashboard => Icons.dashboard_outlined,
        ShellTab.students => Icons.school_outlined,
        ShellTab.staff => Icons.badge_outlined,
        ShellTab.guardians => Icons.people_outline,
        ShellTab.more => Icons.menu,
      };

  IconData get activeIcon => switch (this) {
        ShellTab.dashboard => Icons.dashboard,
        ShellTab.students => Icons.school,
        ShellTab.staff => Icons.badge,
        ShellTab.guardians => Icons.people,
        ShellTab.more => Icons.menu_open,
      };

  String get route => switch (this) {
        ShellTab.dashboard => '/shell',
        ShellTab.students => '/shell/students',
        ShellTab.staff => '/shell/staff',
        ShellTab.guardians => '/shell/guardians',
        ShellTab.more => '/shell/more',
      };
}

/// Router configuration. The route table is owned here; per-feature deep
/// links register their own sub-routers via `router.registerRoute` once
/// those features land.
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
        path: '/error',
        name: 'error',
        builder: (context, state) => const _ErrorScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/shell',
            name: 'dashboard',
            builder: (context, state) =>
                const _TabPlaceholder(tab: ShellTab.dashboard),
          ),
          GoRoute(
            path: '/shell/students',
            name: 'students',
            builder: (context, state) => const StudentsListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'student_new',
                builder: (context, state) => const StudentCreateScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'student_detail',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return StudentDetailScreen(studentId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/shell/staff',
            name: 'staff',
            builder: (context, state) => const StaffListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'staff_new',
                builder: (context, state) => const StaffCreateScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'staff_detail',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return StaffDetailScreen(staffId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/shell/guardians',
            name: 'guardians',
            builder: (context, state) => const GuardiansListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'guardian_new',
                builder: (context, state) => const GuardianCreateScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'guardian_detail',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return GuardianDetailScreen(guardianId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/shell/more',
            name: 'more',
            builder: (context, state) =>
                const _TabPlaceholder(tab: ShellTab.more),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const _ErrorScreen(),
  );
}

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    final location = GoRouterState.of(context).matchedLocation;
    final active = _activeTabFor(location);

    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: tokens.surface.surface,
        selectedIndex: ShellTab.values.indexOf(active),
        onDestinationSelected: (index) {
          final tab = ShellTab.values[index];
          context.go(tab.route);
        },
        destinations: [
          for (final tab in ShellTab.values)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.activeIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }

  ShellTab _activeTabFor(String location) {
    for (final tab in ShellTab.values) {
      if (tab == ShellTab.dashboard) {
        if (location == '/shell' || location == '/shell/') return tab;
        continue;
      }
      if (location.startsWith(tab.route)) return tab;
    }
    return ShellTab.dashboard;
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.tab});
  final ShellTab tab;

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 48, color: tokens.text.tertiary),
            SizedBox(height: tokens.space.md),
            Text(
              tab.label,
              style: tokens.typography.titleLarge.copyWith(
                color: tokens.text.primary,
              ),
            ),
            SizedBox(height: tokens.space.xs),
            Text(
              'Coming in the next release.',
              style: tokens.typography.bodyMedium.copyWith(
                color: tokens.text.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Laratik Schools',
              style: tokens.typography.headlineLarge.copyWith(
                color: tokens.text.primary,
              ),
            ),
            SizedBox(height: tokens.space.lg),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: tokens.brand.primary,
                strokeWidth: 2.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginScreen extends StatelessWidget {
  const _LoginScreen();

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sign in',
                  style: tokens.typography.titleLarge.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
                SizedBox(height: tokens.space.sm),
                Text(
                  'OAuth PKCE lands in Phase 1.1.',
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.text.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OAuthCallbackScreen extends StatelessWidget {
  const _OAuthCallbackScreen();

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      body: Center(
        child: Text(
          'OAuth callback',
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      body: Center(
        child: Text(
          'Something went wrong.',
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
      ),
    );
  }
}
