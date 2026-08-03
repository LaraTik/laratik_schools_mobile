import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/assessment/data/current_student_provider.dart';
import '../features/boot/boot_provider.dart';
import '../features/communication/data/communication_providers.dart';
import '../l10n/app_localizations.dart';
import '../ui/app_theme.dart';
import '../ui/design_tokens.dart';
import '../ui/widgets/ls_status_chip.dart';
import 'parent_home.dart';
import 'student_home.dart';
import 'teacher_home.dart';

/// Home surface. Routes to a role-specific home based on the
/// active [LaratikRole]:
///   * `Student` → [StudentHomeScreen]
///   * `Guardian` → [ParentHomeScreen]
///   * `Teacher` → [TeacherHomeScreen]
///   * everyone else (admin / registrar / teacher / unknown) → the
///     "Quick start" surface (kept below for backward compat and
///     as the default when the boot context hasn't resolved yet).
///
/// The role branching is intentionally additive: the original
/// operator surface still works for every role. The new surfaces
/// are read-only placeholders that hint at what's coming; they
/// don't replace the admin / registrar flow.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = activeRole(ref);
    switch (role) {
      case LaratikRole.student:
        return const StudentHomeScreen();
      case LaratikRole.guardian:
        return const ParentHomeScreen();
      case LaratikRole.teacher:
        return const TeacherHomeScreen();
      case LaratikRole.registrar:
      case LaratikRole.schoolAdmin:
      case LaratikRole.operator:
      case LaratikRole.unknown:
        return const _AdminHomeScreen();
    }
  }
}

/// The operator home. Quick-start grid of the most-used create /
/// capture actions plus the resolved "acting as" student card.
/// Every user-facing string is locale-aware via
/// [AppLocalizations.of(context)]; the chevron in the quick-start
/// tiles mirrors itself under RTL so the visual flow stays
/// consistent with the text direction.
class _AdminHomeScreen extends ConsumerWidget {
  const _AdminHomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final today = _today();
    final currentStudentAsync = ref.watch(currentStudentProvider);
    final role = activeRole(ref);
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.homeAdminMyHome,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.a11yNotificationsTooltip,
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/shell/notifications'),
          ),
          Padding(
            // `start:` so the date hugs the leading edge under RTL
            // and the trailing edge under LTR — the visual remains
            // "title on the start side, date on the end side" in
            // both directions. The literal `right:` would have
            // glued the date to the left edge under RTL.
            padding: EdgeInsetsDirectional.only(end: tokens.space.md),
            child: Center(
              child: Text(
                today,
                style: tokens.typography.titleSmall.copyWith(
                  color: tokens.text.secondary,
                  fontFamily: tokens.typography.monoFamily,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          if (role != LaratikRole.unknown)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.space.sm),
              child: _RoleChip(tokens: tokens, role: role),
            ),
          Text(
            l.homeAdminQuickStart,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          const _QuickStartGrid(),
          SizedBox(height: tokens.space.lg),
          // "Acting as" — surfaces the resolved student so the
          // operator knows who they're taking the practice quiz as.
          // The mobile session is pinned to a single student by the
          // dev seed; the "Switch student" icon button on the card
          // opens the full-screen picker at /shell/me/switch-student.
          _ActingAsCard(
            tokens: tokens,
            studentAsync: currentStudentAsync,
          ),
        ],
      ),
    );
  }

  String _today() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.tokens, required this.role});
  final DesignTokens tokens;
  final LaratikRole role;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: LsStatusChip(
        label: l.homeAdminSignedInAs(role.wire),
        tone: LsChipTone.brand,
        icon: Icons.verified_user_outlined,
      ),
    );
  }
}

class _QuickStartGrid extends ConsumerWidget {
  const _QuickStartGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    // Watch the notifications list just to compute the unread count.
    final unread = ref
            .watch(notificationsListProvider)
            .value
            ?.items
            .where((n) => !n.read)
            .length ??
        0;
    // Capability-gated tiles: the "Fee plans" + "Fee operations"
    // tiles only render when the user has `can_view_fees`. The
    // "Operations" tile only renders when the user can manage
    // branches (the v1 server does not yet expose a
    // `can_view_operations` capability; the operations surface
    // is admin-only by intent and `can_manage_branches` is
    // already admin-only on the wire — see the audit's §4
    // follow-up for the future hardening). The capability
    // map is server-driven (see the boot context); a user
    // without the capability won't see the tile and the
    // matching bottom-nav tab stays hidden.
    final canViewFees = hasCapability(ref, 'can_view_fees');
    final canManageBranches = hasCapability(ref, 'can_manage_branches');
    final items = <_QuickItem>[
      _QuickItem(
        label: l.homeAdminPracticeQuiz,
        description: l.homeAdminPracticeQuizSubtitle,
        icon: Icons.assignment_outlined,
        tone: LsChipTone.brand,
        onTap: () => context.go('/shell/academics/exams'),
      ),
      _QuickItem(
        label: l.homeAdminCaptureAttendance,
        description: l.homeAdminCaptureAttendanceSubtitle,
        icon: Icons.fact_check_outlined,
        tone: LsChipTone.success,
        onTap: () => context.go('/shell/attendance'),
      ),
      _QuickItem(
        label: l.homeAdminNewStudent,
        description: l.homeAdminNewStudentSubtitle,
        icon: Icons.person_add_alt_1,
        tone: LsChipTone.brand,
        onTap: () => context.go('/shell/students/new'),
      ),
      _QuickItem(
        label: l.homeAdminNewStaff,
        description: l.homeAdminNewStaffSubtitle,
        icon: Icons.badge_outlined,
        tone: LsChipTone.brand,
        onTap: () => context.go('/shell/staff/new'),
      ),
      _QuickItem(
        label: l.homeAdminNewSubject,
        description: l.homeAdminNewSubjectSubtitle,
        icon: Icons.menu_book_outlined,
        tone: LsChipTone.info,
        onTap: () => context.go('/shell/academics/subjects/new'),
      ),
      if (canViewFees)
        _QuickItem(
          label: l.homeAdminFeePlans,
          description: l.homeAdminFeePlansSubtitle,
          icon: Icons.receipt_long_outlined,
          tone: LsChipTone.warning,
          onTap: () => context.go('/shell/fees/plans'),
        ),
      if (canViewFees)
        _QuickItem(
          label: l.homeAdminFeeOperations,
          description: l.homeAdminFeeOperationsSubtitle,
          icon: Icons.insights_outlined,
          tone: LsChipTone.success,
          onTap: () => context.go('/shell/fees/operations'),
        ),
      if (canManageBranches)
        _QuickItem(
          label: l.homeAdminOperations,
          description: l.homeAdminOperationsSubtitle,
          icon: Icons.health_and_safety_outlined,
          tone: LsChipTone.info,
          onTap: () => context.go('/shell/operations'),
        ),
      _QuickItem(
        label: l.shellNotifications,
        description: unread == 0
            ? l.homeAdminNotificationsSubtitle
            : l.a11yUnreadNotifications(unread),
        icon: Icons.notifications_outlined,
        tone: unread == 0 ? LsChipTone.warning : LsChipTone.error,
        badge: unread == 0 ? null : unread.toString(),
        onTap: () => context.go('/shell/notifications'),
      ),
    ];
    if (isWide) {
      return Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(child: _QuickCard(item: items[i], tokens: tokens)),
            if (i < items.length - 1) SizedBox(width: tokens.space.md),
          ],
        ],
      );
    }
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _QuickCard(item: items[i], tokens: tokens),
          if (i < items.length - 1) SizedBox(height: tokens.space.sm),
        ],
      ],
    );
  }
}

class _QuickItem {
  const _QuickItem({
    required this.label,
    required this.description,
    required this.icon,
    required this.tone,
    required this.onTap,
    this.badge,
  });
  final String label;
  final String description;
  final IconData icon;
  final LsChipTone tone;
  final VoidCallback onTap;
  final String? badge;
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.item, required this.tokens});
  final _QuickItem item;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.label,
      child: Material(
        color: tokens.surface.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.md),
          side: BorderSide(color: tokens.surface.outlineVariant),
        ),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(tokens.radius.md),
          child: Padding(
            padding: EdgeInsets.all(tokens.space.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _toneContainer(tokens, item.tone),
                    borderRadius: BorderRadius.circular(tokens.radius.sm),
                  ),
                  child: Icon(
                    item.icon,
                    color: _toneFg(tokens, item.tone),
                    size: 22,
                  ),
                ),
                SizedBox(width: tokens.space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.label,
                              style: tokens.typography.titleSmall.copyWith(
                                color: tokens.text.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.badge != null) ...[
                            SizedBox(width: tokens.space.xs),
                            _Badge(label: item.badge!, tokens: tokens),
                          ],
                        ],
                      ),
                      SizedBox(height: tokens.space.xxs),
                      Text(
                        item.description,
                        style: tokens.typography.bodySmall.copyWith(
                          color: tokens.text.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  // Mirror the chevron under RTL so the visual
                  // "next →" stays consistent with the text flow.
                  // Material's `ListTile` does this for free; a raw
                  // `Icon` does not.
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  color: tokens.text.tertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _toneContainer(DesignTokens tokens, LsChipTone tone) {
    return switch (tone) {
      LsChipTone.success => tokens.status.successContainer,
      LsChipTone.warning => tokens.status.warningContainer,
      LsChipTone.error => tokens.status.errorContainer,
      LsChipTone.info => tokens.status.infoContainer,
      LsChipTone.brand => tokens.brand.primaryContainer,
      LsChipTone.neutral => tokens.surface.surfaceContainer,
    };
  }

  Color _toneFg(DesignTokens tokens, LsChipTone tone) {
    return switch (tone) {
      LsChipTone.success => tokens.status.success,
      LsChipTone.warning => tokens.status.warning,
      LsChipTone.error => tokens.status.error,
      LsChipTone.info => tokens.status.info,
      LsChipTone.brand => tokens.brand.onPrimaryContainer,
      LsChipTone.neutral => tokens.text.secondary,
    };
  }
}

/// Compact pill used to surface a count next to a quick-action
/// label (e.g. "Notifications · 3"). Always error-toned — only the
/// unread notifications path uses it today, and "unread" is the
/// only count worth surfacing on a dashboard quick card.
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.tokens});
  final String label;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      label: l.a11yUnreadNotifications(int.parse(label)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space.xs,
          vertical: tokens.space.xxs,
        ),
        decoration: BoxDecoration(
          color: tokens.status.errorContainer,
          borderRadius: BorderRadius.circular(tokens.radius.pill),
        ),
        child: Text(
          label,
          style: tokens.typography.labelSmall.copyWith(
            color: tokens.status.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// "Acting as: <name>" pill. Resolves the current student via
/// [currentStudentProvider] and surfaces their name + id so the
/// operator can verify the practice-quiz attempt will be filed
/// against the right person. The mobile session is pinned to a
/// single student for the first slice; the "Switch" icon button
/// on the card opens the full-screen picker at
/// /shell/me/switch-student.
class _ActingAsCard extends StatelessWidget {
  const _ActingAsCard({required this.tokens, required this.studentAsync});
  final DesignTokens tokens;
  final AsyncValue<CurrentStudent?> studentAsync;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final content = studentAsync.when(
      data: (current) {
        if (current == null) {
          return _row(
            context,
            tokens,
            icon: Icons.person_outline,
            label: l.homeStudentNoStudent,
            sub: l.homeStudentNoStudentMessage,
          );
        }
        final name = current.person.fullName;
        return _row(
          context,
          tokens,
          icon: Icons.person_outline,
          label: l.homeAdminActingAs(
            name.isEmpty ? current.studentId : name,
          ),
          sub: current.studentId,
        );
      },
      loading: () => _row(
        context,
        tokens,
        icon: Icons.hourglass_top_outlined,
        label: l.homeStudentResolving,
        sub: l.homeStudentResolvingMessage,
      ),
      error: (err, _) => _row(
        context,
        tokens,
        icon: Icons.warning_amber_outlined,
        label: l.homeStudentResolvingFailed,
        sub: err.toString(),
      ),
    );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space.md,
        vertical: tokens.space.sm,
      ),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: content,
    );
  }

  Widget _row(
    BuildContext context,
    DesignTokens tokens, {
    required IconData icon,
    required String label,
    required String sub,
  }) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Icon(icon, color: tokens.brand.primary, size: 18),
        SizedBox(width: tokens.space.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: tokens.typography.titleSmall.copyWith(
                  color: tokens.text.primary,
                ),
              ),
              Text(
                sub,
                style: tokens.typography.bodySmall.copyWith(
                  color: tokens.text.secondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: l.a11ySwitchStudentTooltip,
          icon: const Icon(Icons.swap_horiz),
          onPressed: () => context.go('/shell/me/switch-student'),
        ),
      ],
    );
  }
}
