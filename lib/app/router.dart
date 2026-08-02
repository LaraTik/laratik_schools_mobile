import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../auth/session.dart';
import '../core/clock.dart';
import '../core/logging.dart';
import '../features/academics/ui/academics_screen.dart';
import '../features/academics/ui/subject_create_screen.dart';
import '../features/assessment/ui/exam_attempt_screen.dart';
import '../features/assessment/ui/exams_list_screen.dart';
import '../features/attendance/ui/attendance_capture_screen.dart';
import '../features/attendance/ui/attendance_list_screen.dart';
import '../features/boot/boot_provider.dart';
import '../features/communication/ui/notifications_screen.dart';
import '../features/guardians/ui/guardian_create_screen.dart';
import '../features/guardians/ui/guardian_detail_screen.dart';
import '../features/guardians/ui/guardians_list_screen.dart';
import '../features/people/ui/student_create_screen.dart';
import '../features/people/ui/student_detail_screen.dart';
import '../features/people/ui/students_list_screen.dart';
import '../features/staff/ui/staff_create_screen.dart';
import '../features/staff/ui/staff_detail_screen.dart';
import '../features/staff/ui/staff_list_screen.dart';
import '../ui/app_theme.dart';
import '../ui/widgets/ls_button.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

/// Top-level navigation destinations. The shell renders these in a bottom
/// navigation bar. Order matters — left-to-right is the operator's mental
/// model (most-used first, admin surfaces last). Capped at 5 entries per
/// the Laratik UI rules; the Home dashboard lives on the AppBar action of
/// every tab instead of taking a slot.
///
/// `requiredCapability` is the per-tab gate read from the active
/// [BootContext]. A tab whose gate returns `false` is hidden from
/// the bottom nav. The shell also falls back to the home dashboard
/// when no tabs match (e.g. for a parent role, where the 5 registrar
/// tabs are all hidden) so the user always has somewhere to land.
enum ShellTab {
  students('student.read'),
  staff('staff.read'),
  guardians('guardian.read'),
  academics('academics.read'),
  attendance('attendance.read');

  const ShellTab(this.requiredCapability);
  final String requiredCapability;
}

extension ShellTabX on ShellTab {
  String get label => switch (this) {
        ShellTab.students => 'Students',
        ShellTab.staff => 'Staff',
        ShellTab.guardians => 'Guardians',
        ShellTab.academics => 'Academics',
        ShellTab.attendance => 'Attendance',
      };

  IconData get icon => switch (this) {
        ShellTab.students => Icons.school_outlined,
        ShellTab.staff => Icons.badge_outlined,
        ShellTab.guardians => Icons.people_outline,
        ShellTab.academics => Icons.menu_book_outlined,
        ShellTab.attendance => Icons.fact_check_outlined,
      };

  IconData get activeIcon => switch (this) {
        ShellTab.students => Icons.school,
        ShellTab.staff => Icons.badge,
        ShellTab.guardians => Icons.people,
        ShellTab.academics => Icons.menu_book,
        ShellTab.attendance => Icons.fact_check,
      };

  String get route => switch (this) {
        ShellTab.students => '/shell/students',
        ShellTab.staff => '/shell/staff',
        ShellTab.guardians => '/shell/guardians',
        ShellTab.academics => '/shell/academics',
        ShellTab.attendance => '/shell/attendance',
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
      final location = state.matchedLocation;
      final loggingIn = location.startsWith('/auth');
      // The splash is the boot screen — once the session is known, we
      // move to either /auth/login (anonymous) or /shell (authed). The
      // previous version only redirected authed users when they were
      // on /auth/login, which meant a restart-after-sign-in landed on
      // /splash and never advanced to the home screen.
      if (location == '/splash') {
        return isAuthed ? '/shell' : '/auth/login';
      }
      if (!isAuthed && !loggingIn) return '/auth/login';
      if (isAuthed && loggingIn) return '/shell';
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
        builder: (context, state) => const LoginScreen(),
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
            builder: (context, state) => const DashboardScreen(),
            routes: [
              GoRoute(
                path: 'notifications',
                name: 'notifications',
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
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
            path: '/shell/attendance',
            name: 'attendance',
            builder: (context, state) => const AttendanceListScreen(),
            routes: [
              GoRoute(
                path: 'capture/:id',
                name: 'attendance_capture',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return AttendanceCaptureScreen(classGroupId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/shell/academics',
            name: 'academics',
            builder: (context, state) => const AcademicsScreen(),
            routes: [
              GoRoute(
                path: 'subjects/new',
                name: 'subject_new',
                builder: (context, state) => const SubjectCreateScreen(),
              ),
              GoRoute(
                path: 'exams',
                name: 'exams',
                builder: (context, state) => const ExamsListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'exam_attempt',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return ExamAttemptScreen(
                        examPlanId: id,
                        // The student id can be supplied via the deep
                        // link query (?student=...). When empty, the
                        // screen resolves the current student via
                        // [currentStudentProvider] (the dev session is
                        // pinned to a single student by the dev seed).
                        studentId: state.uri.queryParameters['student'] ?? '',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const _ErrorScreen(),
  );
}

class _ShellScaffold extends ConsumerWidget {
  const _ShellScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final location = GoRouterState.of(context).matchedLocation;
    // Filter the 5 tab list by the active role's capability map.
    // A parent (Guardian) typically has zero of the 5 capabilities
    // and lands on the home dashboard; a Registrar has all 5 and
    // sees the full bottom nav.
    final ctx = ref.watch(bootContextProvider);
    final visibleTabs = ShellTab.values
        .where((tab) => ctx?.hasCapability(tab.requiredCapability) ?? false)
        .toList(growable: false);
    final active = _activeTabFor(location, visibleTabs);

    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      body: child,
      bottomNavigationBar: visibleTabs.isEmpty
          ? null
          : NavigationBar(
              backgroundColor: tokens.surface.surface,
              selectedIndex: active == null
                  ? 0
                  : visibleTabs
                      .indexOf(active)
                      .clamp(0, visibleTabs.length - 1),
              onDestinationSelected: (index) {
                final tab = visibleTabs[index];
                context.go(tab.route);
              },
              destinations: [
                for (final tab in visibleTabs)
                  NavigationDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.activeIcon),
                    label: tab.label,
                  ),
              ],
            ),
    );
  }

  ShellTab? _activeTabFor(String location, List<ShellTab> visible) {
    if (location == '/shell' || location == '/shell/') {
      return null;
    }
    for (final tab in visible) {
      if (location.startsWith(tab.route)) return tab;
    }
    return null;
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
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

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(tokens.space.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: tokens.status.error,
                  ),
                  SizedBox(height: tokens.space.md),
                  Text(
                    'We could not find that page',
                    textAlign: TextAlign.center,
                    style: tokens.typography.titleLarge.copyWith(
                      color: tokens.text.primary,
                    ),
                  ),
                  SizedBox(height: tokens.space.xs),
                  Text(
                    'The link you followed may be broken, or the page may '
                    'have been moved. Head back home to keep working.',
                    textAlign: TextAlign.center,
                    style: tokens.typography.bodyMedium.copyWith(
                      color: tokens.text.secondary,
                    ),
                  ),
                  SizedBox(height: tokens.space.lg),
                  LsButton.primary(
                    label: 'Back to home',
                    icon: Icons.home_outlined,
                    onPressed: () => GoRouter.of(context).go('/shell'),
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
