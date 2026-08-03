// SPDX-License-Identifier: Proprietary
// Teacher "Exams" surface — read-only list of exam plans
// the teacher owns.
//
// Reachable from the "Exams" tile on the teacher home
// (capability-gated on the v1 `can_view_academics`
// capability plus a teacher role gate). Each row shows
// status chip, subject, exam date, duration, + max
// score. Tapping a row opens the per-plan detail at
// `/shell/teachers/exams/:examPlanId` with the question
// list + a "Manual grade" action button.
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)]; the chevron mirrors
// itself under RTL so the visual flow stays consistent
// with the text direction.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../../assessment/data/assessment_repository.dart' show ExamPlanPage;
import '../../assessment/data/exam.dart';
import '../data/teacher_exam_providers.dart';

class TeacherExamsScreen extends ConsumerWidget {
  const TeacherExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(teacherExamPlansProvider);
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.teacherExamsScreenTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(teacherExamPlansProvider.notifier).refresh(),
          ),
        ],
      ),
      body: async.when(
        data: (page) => _buildBody(context, ref, tokens, page),
        loading: () => LsStateView.loading(
          title: l.teacherExamsLoadingTitle,
          message: l.teacherExamsLoadingMessage,
        ),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: l.teacherExamsErrorTitle,
          message: err.toString(),
          action: LsButton.primary(
            label: l.commonTryAgain,
            expand: false,
            onPressed: () =>
                ref.read(teacherExamPlansProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DesignTokens tokens,
    ExamPlanPage page,
  ) {
    final l = AppLocalizations.of(context);
    if (page.plans.isEmpty) {
      return LsStateView.empty(
        icon: Icons.assignment_outlined,
        title: l.teacherExamsEmptyTitle,
        message: l.teacherExamsEmptyMessage,
      );
    }
    return RefreshIndicator(
      color: tokens.brand.primary,
      onRefresh: () => ref.read(teacherExamPlansProvider.notifier).refresh(),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          tokens.space.md,
          tokens.space.md,
          tokens.space.md,
          tokens.space.xl,
        ),
        itemCount: page.plans.length,
        separatorBuilder: (_, __) => SizedBox(height: tokens.space.sm),
        itemBuilder: (context, index) {
          return _ExamCard(tokens: tokens, plan: page.plans[index]);
        },
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.tokens, required this.plan});
  final DesignTokens tokens;
  final ExamPlan plan;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (LsChipTone tone, IconData icon, String label) = _toneFor(plan);
    final subject = plan.subject ?? '';
    final date = plan.examDate ?? '';
    final duration = plan.durationMinutes;
    return Material(
      color: tokens.surface.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.surface.outlineVariant),
      ),
      child: InkWell(
        onTap: () => context.go(
          '/shell/teachers/exams/${Uri.encodeComponent(plan.id)}',
        ),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _toneContainer(tokens, tone),
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Icon(icon, color: _toneFg(tokens, tone), size: 22),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            plan.title.isEmpty ? '—' : plan.title,
                            style: tokens.typography.titleSmall.copyWith(
                              color: tokens.text.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: tokens.space.xs),
                        LsStatusChip(
                          label: label,
                          tone: tone,
                          icon: icon,
                        ),
                      ],
                    ),
                    if (subject.isNotEmpty || date.isNotEmpty || duration != null) ...[
                      SizedBox(height: tokens.space.xxs),
                      Text(
                        [
                          if (subject.isNotEmpty) subject,
                          if (date.isNotEmpty) date,
                          if (duration != null) l.teacherExamsDurationChip(duration),
                          if (plan.totalMarks != null)
                            l.teacherExamsMaxScoreChip(plan.totalMarks!),
                        ].join(' · '),
                        style: tokens.typography.bodySmall.copyWith(
                          color: tokens.text.secondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

(LsChipTone, IconData, String) _toneFor(ExamPlan plan) {
  if (plan.status == 'Published') {
    return (LsChipTone.success, Icons.check_circle_outline, 'Published');
  }
  if (plan.status == 'Closed') {
    return (LsChipTone.neutral, Icons.lock_outline, 'Closed');
  }
  return (LsChipTone.warning, Icons.edit_outlined, 'Draft');
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
