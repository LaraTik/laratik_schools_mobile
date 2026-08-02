import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/assessment/data/assessment_providers.dart';
import '../features/assessment/data/current_student_provider.dart';
import '../features/assessment/data/exam.dart';
import '../features/communication/data/communication_providers.dart';
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
    final currentStudentAsync = ref.watch(currentStudentProvider);
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
          'My school',
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                if (unread > 0)
                  Positioned(
                    right: -2,
                    top: -2,
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
          // "Acting as" — surfaces the active student so the user
          // can verify the exam attempt will be filed against the
          // right person. The mobile session is pinned to a single
          // student by the dev seed; a future "switch student"
          // surface (operator or self for older students) will let
          // the user change it.
          currentStudentAsync.when(
            data: (current) => _ActingAsCard(tokens: tokens, current: current),
            loading: () => _LoadingCard(
              tokens: tokens,
              title: 'Resolving student…',
              message: 'Looking up the active student for this device.',
            ),
            error: (err, _) => _ErrorCard(
              tokens: tokens,
              title: 'Student resolution failed',
              message: err.toString(),
            ),
          ),
          SizedBox(height: tokens.space.lg),
          Text(
            'Today',
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
                  title: 'No exams today',
                  message: 'You have no published exam plans waiting for you. '
                      'New exams will appear here as teachers publish them.',
                );
              }
              final next = page.plans.first;
              return _NextExamCard(tokens: tokens, exam: next);
            },
            loading: () => _LoadingCard(
              tokens: tokens,
              title: 'Loading exams',
              message: 'Fetching your published exam catalog.',
            ),
            error: (err, _) => _ErrorCard(
              tokens: tokens,
              title: 'Could not load exams',
              message: err.toString(),
            ),
          ),
          SizedBox(height: tokens.space.lg),
          Text(
            'More',
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          _SurfaceTile(
            tokens: tokens,
            icon: Icons.assignment_outlined,
            title: 'All exams',
            subtitle: 'Browse every published exam',
            onTap: () => context.go('/shell/academics/exams'),
          ),
          SizedBox(height: tokens.space.sm),
          _SurfaceTile(
            tokens: tokens,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: unread == 0
                ? 'Inbox + announcements'
                : '$unread unread message${unread == 1 ? '' : 's'}',
            onTap: () => context.go('/shell/notifications'),
          ),
          SizedBox(height: tokens.space.lg),
          _FutureSurfaceCard(
            tokens: tokens,
            title: 'Grades, attendance & report cards',
            message: 'These surfaces land in the next release.',
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
    final icon = Icons.person_outline;
    final label = current == null
        ? 'No student resolved'
        : 'Hi, ${current!.person.fullName.isEmpty ? current!.studentId : current!.person.fullName}';
    final sub = current == null
        ? 'No students are seeded on this site yet.'
        : 'Student ID: ${current!.studentId}';
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
                'Take your next exam',
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
            label: 'Open exam',
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
              Icon(Icons.chevron_right, color: tokens.text.tertiary),
            ],
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

class _FutureSurfaceCard extends StatelessWidget {
  const _FutureSurfaceCard({
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
          Icon(Icons.upcoming_outlined, color: tokens.status.info, size: 22),
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
