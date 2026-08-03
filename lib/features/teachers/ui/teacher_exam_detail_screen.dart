// SPDX-License-Identifier: Proprietary
// Per-plan detail — read-only exam plan summary + the
// subject's question catalog + a "Manual grade" action.
//
// The detail surface shows:
//   * Status chip + title + subject + exam date +
//     duration + max score header.
//   * The subject's question list (one card per
//     question, with the question text + type + marks).
//   * **Manual grade** button (bottom) that opens the
//     manual grade form at
//     `/shell/teachers/exams/:examPlanId/grade`.
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
import '../../assessment/data/exam.dart';
import '../data/teacher_exam_providers.dart';
import '../data/teacher_exam_repository.dart';

class TeacherExamDetailScreen extends ConsumerWidget {
  const TeacherExamDetailScreen({required this.examPlan, super.key});
  final String examPlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final plansAsync = ref.watch(teacherExamPlansProvider);
    final ExamPlan? plan = plansAsync.value
        ?.plans
        .where((p) => p.id == examPlan)
        .firstOrNull;
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.teacherExamDetailTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(teacherExamPlansProvider);
              if (plan?.subject != null && plan!.subject!.isNotEmpty) {
                ref.invalidate(teacherExamQuestionsProvider(plan.subject!));
              }
            },
          ),
        ],
      ),
      body: plansAsync.when(
        data: (page) {
          if (plan == null) {
            return LsStateView.empty(
              icon: Icons.assignment_outlined,
              title: l.teacherExamNotFoundTitle,
              message: l.teacherExamNotFoundMessage,
            );
          }
          return _buildBody(context, ref, tokens, plan);
        },
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
    ExamPlan plan,
  ) {
    final l = AppLocalizations.of(context);
    final subject = plan.subject ?? '';
    final questionsAsync = subject.isEmpty
        ? null
        : ref.watch(teacherExamQuestionsProvider(subject));
    return ListView(
      padding: EdgeInsets.fromLTRB(
        tokens.space.md,
        tokens.space.md,
        tokens.space.md,
        tokens.space.xl,
      ),
      children: [
        _Header(tokens: tokens, plan: plan),
        SizedBox(height: tokens.space.lg),
        Text(
          l.teacherExamQuestionsHeader,
          style: tokens.typography.titleSmall.copyWith(
            color: tokens.text.secondary,
          ),
        ),
        SizedBox(height: tokens.space.sm),
        if (questionsAsync == null)
          LsStateView.empty(
            icon: Icons.help_outline,
            title: l.teacherExamQuestionsEmptyTitle,
            message: l.teacherExamQuestionsEmptyMessage,
          )
        else
          questionsAsync.when(
            data: (questions) {
              if (questions.isEmpty) {
                return LsStateView.empty(
                  icon: Icons.help_outline,
                  title: l.teacherExamQuestionsEmptyTitle,
                  message: l.teacherExamQuestionsEmptyMessage,
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < questions.length; i++) ...[
                    if (i > 0) SizedBox(height: tokens.space.sm),
                    _QuestionCard(
                      tokens: tokens,
                      index: i + 1,
                      question: questions[i],
                    ),
                  ],
                ],
              );
            },
            loading: () => LsStateView.loading(
              title: l.teacherExamsLoadingTitle,
              message: l.teacherExamsLoadingMessage,
            ),
            error: (err, _) => LsStateView.error(
              icon: Icons.error_outline,
              title: l.teacherExamsErrorTitle,
              message: err.toString(),
            ),
          ),
        SizedBox(height: tokens.space.lg),
        LsButton.primary(
          label: l.teacherExamManualGradeAction,
          icon: Icons.grading_outlined,
          expand: true,
          onPressed: () {
            final subjectQuery = (plan.subject ?? '').isEmpty
                ? ''
                : '?subject=${Uri.encodeComponent(plan.subject!)}';
            context.go(
              '/shell/teachers/exams/${Uri.encodeComponent(plan.id)}/grade$subjectQuery',
            );
          },
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.tokens, required this.plan});
  final DesignTokens tokens;
  final ExamPlan plan;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (LsChipTone tone, IconData icon, String label) = switch (plan.status) {
      'Published' => (
          LsChipTone.success,
          Icons.check_circle_outline,
          l.teacherExamStatusPublished,
        ),
      'Closed' => (
          LsChipTone.neutral,
          Icons.lock_outline,
          l.teacherExamStatusClosed,
        ),
      _ => (
          LsChipTone.warning,
          Icons.edit_outlined,
          l.teacherExamStatusDraft,
        ),
    };
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
              Icon(icon, color: _toneFg(tokens, tone), size: 22),
              SizedBox(width: tokens.space.sm),
              Expanded(
                child: Text(
                  plan.title.isEmpty ? '—' : plan.title,
                  style: tokens.typography.titleMedium.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
              ),
              LsStatusChip(
                label: label,
                tone: tone,
                icon: icon,
              ),
            ],
          ),
          if ((plan.subject ?? '').isNotEmpty) ...[
            SizedBox(height: tokens.space.xs),
            Text(
              plan.subject!,
              style: tokens.typography.bodyMedium.copyWith(
                color: tokens.text.secondary,
              ),
            ),
          ],
          if ((plan.examDate ?? '').isNotEmpty ||
              plan.durationMinutes != null ||
              plan.totalMarks != null) ...[
            SizedBox(height: tokens.space.xs),
            Wrap(
              spacing: tokens.space.xs,
              runSpacing: tokens.space.xxs,
              children: [
                if ((plan.examDate ?? '').isNotEmpty)
                  LsStatusChip(
                    label: l.teacherExamDateChip(plan.examDate!),
                    tone: LsChipTone.neutral,
                    icon: Icons.calendar_today_outlined,
                  ),
                if (plan.durationMinutes != null)
                  LsStatusChip(
                    label: l.teacherExamsDurationChip(plan.durationMinutes!),
                    tone: LsChipTone.neutral,
                    icon: Icons.timer_outlined,
                  ),
                if (plan.totalMarks != null)
                  LsStatusChip(
                    label: l.teacherExamsMaxScoreChip(plan.totalMarks!),
                    tone: LsChipTone.neutral,
                    icon: Icons.star_outline,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.tokens,
    required this.index,
    required this.question,
  });
  final DesignTokens tokens;
  final int index;
  final TeacherExamQuestion question;

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
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: tokens.brand.primaryContainer,
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Center(
                  child: Text(
                    index.toString(),
                    style: tokens.typography.labelMedium.copyWith(
                      color: tokens.brand.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              SizedBox(width: tokens.space.sm),
              Expanded(
                child: Text(
                  question.questionText.isEmpty
                      ? l.teacherExamQuestionFallback
                      : question.questionText,
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
              ),
              LsStatusChip(
                label: l.teacherExamMarksChip(question.marks),
                tone: LsChipTone.info,
                icon: Icons.star_outline,
              ),
            ],
          ),
          SizedBox(height: tokens.space.xs),
          Text(
            l.teacherExamQuestionTypeChip(question.questionType),
            style: tokens.typography.labelSmall.copyWith(
              color: tokens.text.tertiary,
            ),
          ),
        ],
      ),
    );
  }
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
