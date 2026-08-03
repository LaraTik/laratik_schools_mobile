// SPDX-License-Identifier: Proprietary
// Teacher home. Read-mostly surface for the staff member who
// teaches one or more (class, subject) pairs.
//
// The role-aware shell routes here when [LaratikRole.teacher] is
// the active role. The home surfaces the unread notifications
// count, a hero "My classes" tile that jumps straight into the
// class picker, and the attendance + inbox shortcuts.
//
// The actual classes list lives at `/shell/teachers/classes` (the
// MyClassesScreen widget). This surface is the lightweight
// launcher; the picker is the place where the teacher picks a
// class and drills into the student roster.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/communication/data/communication_providers.dart';
import '../features/teachers/data/teachers_providers.dart';
import '../l10n/app_localizations.dart';
import '../ui/app_theme.dart';
import '../ui/design_tokens.dart';
import '../ui/widgets/ls_status_chip.dart';

class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final unread = ref
            .watch(notificationsListProvider)
            .value
            ?.items
            .where((n) => !n.read)
            .length ??
        0;
    // Eagerly watch the teaching-assignments list so the "My
    // classes" hero card shows the live count rather than a
    // generic placeholder. The picker screen re-fetches on its
    // own; this is a read-only peek to keep the home calm.
    final classesAsync = ref.watch(myClassesProvider);

    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.homeTeacherMySchool,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.a11yNotificationsTooltip,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                if (unread > 0)
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    top: -2,
                    end: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: tokens.status.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => context.go('/shell/notifications'),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          _HeroClassesCard(tokens: tokens, classesAsync: classesAsync),
          SizedBox(height: tokens.space.lg),
          Text(
            l.homeTeacherQuickStart,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          _Tile(
            tokens: tokens,
            icon: Icons.fact_check_outlined,
            title: l.homeTeacherCaptureAttendance,
            subtitle: l.homeTeacherCaptureAttendanceSubtitle,
            onTap: () => context.go('/shell/attendance'),
          ),
          SizedBox(height: tokens.space.sm),
          _Tile(
            tokens: tokens,
            icon: Icons.assignment_outlined,
            title: l.homeTeacherExams,
            subtitle: l.homeTeacherExamsSubtitle,
            onTap: () => context.go('/shell/teachers/exams'),
          ),
          SizedBox(height: tokens.space.sm),
          _Tile(
            tokens: tokens,
            icon: Icons.notifications_outlined,
            title: l.shellNotifications,
            subtitle: unread == 0
                ? l.homeTeacherInboxSubtitle
                : l.a11yUnreadNotifications(unread),
            onTap: () => context.go('/shell/notifications'),
          ),
        ],
      ),
    );
  }
}

/// Hero "My classes" card. Shows the live count from
/// [myClassesProvider] when available, otherwise a calm loading
/// placeholder. Tap → /shell/teachers/classes.
class _HeroClassesCard extends StatelessWidget {
  const _HeroClassesCard({required this.tokens, required this.classesAsync});
  final DesignTokens tokens;
  final AsyncValue<dynamic> classesAsync;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final summary = _summaryFor(classesAsync, l);
    return Material(
      color: tokens.brand.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: InkWell(
        onTap: () => context.go('/shell/teachers/classes'),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: tokens.surface.surface,
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Icon(
                  Icons.class_outlined,
                  color: tokens.brand.primary,
                  size: 28,
                ),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.homeTeacherMyClasses,
                      style: tokens.typography.titleMedium.copyWith(
                        color: tokens.brand.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(height: tokens.space.xxs),
                    Text(
                      summary.message,
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.brand.onPrimaryContainer,
                      ),
                    ),
                    if (summary.chip != null) ...[
                      SizedBox(height: tokens.space.xs),
                      LsStatusChip(
                        label: summary.chip!,
                        tone: LsChipTone.brand,
                        icon: Icons.class_outlined,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                color: tokens.brand.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _HeroSummary _summaryFor(
    AsyncValue<dynamic> async,
    AppLocalizations l,
  ) {
    return async.when(
      data: (page) {
        final assignments =
            (page as dynamic).assignments as List<dynamic>? ?? const [];
        if (assignments.isEmpty) {
          return _HeroSummary(
            message: l.homeTeacherHeroEmpty,
            chip: null,
          );
        }
        final active =
            assignments.where((a) => (a as dynamic).isActive as bool).length;
        final count = assignments.length;
        return _HeroSummary(
          message: l.homeTeacherHeroActive(count, active),
          chip: l.myClassesHeaderTotal(count),
        );
      },
      loading: () => _HeroSummary(
        message: l.homeTeacherHeroLoadingMessage,
        chip: l.homeTeacherHeroLoadingChip,
      ),
      error: (_, __) => _HeroSummary(
        message: l.homeTeacherHeroErrorMessage,
        chip: l.homeTeacherHeroErrorChip,
      ),
    );
  }
}

class _HeroSummary {
  const _HeroSummary({required this.message, required this.chip});
  final String message;
  final String? chip;
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.tokens,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final DesignTokens tokens;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tokens.surface.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.surface.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tokens.brand.primaryContainer,
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Icon(icon,
                    color: tokens.brand.onPrimaryContainer, size: 22),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tokens.typography.titleSmall.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                    SizedBox(height: tokens.space.xxs),
                    Text(
                      subtitle,
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.text.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                color: tokens.text.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
