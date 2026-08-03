import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/assessment/data/assessment_providers.dart';
import '../features/assessment/data/current_student_provider.dart';
import '../features/assessment/data/exam.dart';
import '../features/communication/data/communication_providers.dart';
import '../l10n/app_localizations.dart';
import '../ui/app_theme.dart';
import '../ui/design_tokens.dart';
import '../ui/widgets/ls_button.dart';
import '../ui/widgets/ls_status_chip.dart';

/// Student home. Quick-access cards: take the next available exam,
/// see past attempts, and (later) grades, attendance, and report
/// cards. The surface is data-driven off the active student the
/// mobile is "acting as" — see [currentStudentProvider].
class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final currentStudentAsync = ref.watch(currentStudentProvider);
    // Pull the resolved CurrentStudent out of the AsyncValue so
    // the "My records" tile can decide whether to enable its tap
    // target. Loading / error / null all keep the tile disabled
    // with a friendly sub-line.
    final current = currentStudentAsync.maybeWhen(
      data: (v) => v,
      orElse: () => null,
    );
    final unread = ref
            .watch(notificationsListProvider)
            .value
            ?.items
            .where((n) => !n.read)
            .length ??
        0;
    final examsAsync = ref.watch(examPlansListProvider);

    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.homeStudentMySchool,
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
          currentStudentAsync.when(
            data: (current) => _ActingAsCard(tokens: tokens, current: current),
            loading: () => _LoadingCard(
              tokens: tokens,
              title: l.homeStudentResolving,
              message: l.homeStudentResolvingMessage,
            ),
            error: (err, _) => _ErrorCard(
              tokens: tokens,
              title: l.homeStudentResolvingFailed,
              message: err.toString(),
            ),
          ),
          SizedBox(height: tokens.space.lg),
          Text(
            l.homeStudentToday,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          examsAsync.when(
            data: (page) {
              if (page.plans.isEmpty) {
                return _PlaceholderCard(
                  tokens: tokens,
                  icon: Icons.assignment_outlined,
                  title: l.homeStudentNoExamsTitle,
                  message: l.homeStudentNoExamsMessage,
                );
              }
              final next = page.plans.first;
              return _NextExamCard(tokens: tokens, exam: next);
            },
            loading: () => _LoadingCard(
              tokens: tokens,
              title: l.homeStudentLoadingExamsTitle,
              message: l.homeStudentLoadingExamsMessage,
            ),
            error: (err, _) => _ErrorCard(
              tokens: tokens,
              title: l.homeStudentCouldNotLoadExams,
              message: err.toString(),
            ),
          ),
          SizedBox(height: tokens.space.lg),
          Text(
            l.homeStudentMore,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          _SurfaceTile(
            tokens: tokens,
            icon: Icons.assignment_outlined,
            title: l.homeStudentAllExams,
            subtitle: l.homeStudentAllExamsSubtitle,
            onTap: () => context.go('/shell/academics/exams'),
          ),
          SizedBox(height: tokens.space.sm),
          _SurfaceTile(
            tokens: tokens,
            icon: Icons.summarize_outlined,
            title: l.homeStudentMyRecords,
            subtitle: current == null
                ? l.homeStudentResolving
                : l.homeStudentMyRecordsSubtitle,
            onTap:
                current == null ? null : () => context.go('/shell/me/records'),
          ),
          SizedBox(height: tokens.space.sm),
          _SurfaceTile(
            tokens: tokens,
            icon: Icons.notifications_outlined,
            title: l.shellNotifications,
            subtitle: unread == 0
                ? l.homeStudentInboxSubtitle
                : l.a11yUnreadNotifications(unread),
            onTap: () => context.go('/shell/notifications'),
          ),
        ],
      ),
    );
  }
}

class _ActingAsCard extends ConsumerWidget {
  const _ActingAsCard({required this.tokens, required this.current});
  final DesignTokens tokens;
  final CurrentStudent? current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final label = current == null
        ? l.homeStudentNoStudent
        : l.homeStudentGreeting(
            current!.person.fullName.isEmpty
                ? current!.studentId
                : current!.person.fullName,
          );
    final sub = current == null
        ? l.homeStudentNoStudentMessage
        : l.homeStudentStudentId(current!.studentId);
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
      child: Row(
        children: [
          Icon(Icons.person_outline, color: tokens.brand.primary, size: 18),
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
      ),
    );
  }
}

class _NextExamCard extends StatelessWidget {
  const _NextExamCard({required this.tokens, required this.exam});
  final DesignTokens tokens;
  final ExamPlan exam;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt_outlined,
                color: tokens.brand.primary,
                size: 18,
              ),
              SizedBox(width: tokens.space.xs),
              Text(
                l.homeStudentTakeNextExam,
                style: tokens.typography.titleSmall.copyWith(
                  color: tokens.text.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space.xs),
          Text(
            exam.title,
            style: tokens.typography.bodyMedium.copyWith(
              color: tokens.text.primary,
            ),
          ),
          if (exam.subject != null && exam.subject!.isNotEmpty) ...[
            SizedBox(height: tokens.space.xxs),
            LsStatusChip(
              label: exam.subject!,
              tone: LsChipTone.brand,
              icon: Icons.menu_book_outlined,
            ),
          ],
          SizedBox(height: tokens.space.md),
          LsButton.primary(
            label: l.homeStudentOpenExam,
            icon: Icons.play_arrow,
            expand: false,
            onPressed: exam.id.isEmpty
                ? null
                : () => context.go('/shell/academics/exams/${exam.id}'),
          ),
        ],
      ),
    );
  }
}

class _SurfaceTile extends StatelessWidget {
  const _SurfaceTile({
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final iconBg = disabled
        ? tokens.surface.surfaceContainerHigh
        : tokens.brand.primaryContainer;
    final iconFg =
        disabled ? tokens.text.tertiary : tokens.brand.onPrimaryContainer;
    final titleColor = disabled ? tokens.text.secondary : tokens.text.primary;
    final chevronColor = disabled ? tokens.text.disabled : tokens.text.tertiary;
    return Semantics(
      button: !disabled,
      enabled: !disabled,
      label: title,
      child: Material(
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
                    color: iconBg,
                    borderRadius: BorderRadius.circular(tokens.radius.sm),
                  ),
                  child: Icon(icon, color: iconFg, size: 22),
                ),
                SizedBox(width: tokens.space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tokens.typography.titleSmall.copyWith(
                          color: titleColor,
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
                  color: chevronColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({
    required this.tokens,
    required this.icon,
    required this.title,
    required this.message,
  });
  final DesignTokens tokens;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: tokens.text.tertiary, size: 22),
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
                  message,
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.text.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({
    required this.tokens,
    required this.title,
    required this.message,
  });
  final DesignTokens tokens;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: tokens.brand.primary,
              strokeWidth: 2,
            ),
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
                  message,
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.text.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.tokens,
    required this.title,
    required this.message,
  });
  final DesignTokens tokens;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.status.errorContainer,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.status.error),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: tokens.status.error, size: 22),
          SizedBox(width: tokens.space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.status.error,
                  ),
                ),
                SizedBox(height: tokens.space.xxs),
                Text(
                  message,
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.status.error,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
