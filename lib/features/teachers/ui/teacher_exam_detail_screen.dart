// SPDX-License-Identifier: Proprietary
// Per-plan detail — exam plan summary + the subject's
// question catalog + authoring + manual grading actions.
//
// The detail surface shows:
//   * Status chip + title + subject + exam date +
//     duration + max score header.
//   * The subject's question list (one card per
//     question, with the question text + type + marks
//     + a per-question "Publish" action).
//   * **Add question** button → opens the question
//     authoring form at
//     `/shell/teachers/exams/:examPlanId/questions/new`.
//   * **Publish exam** button → calls
//     `publish_school_online_exam` to freeze the
//     audience + question list.
//   * **Manual grade** button → opens the manual grade
//     form at `/shell/teachers/exams/:examPlanId/grade`.
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)]; the chevron mirrors
// itself under RTL so the visual flow stays consistent
// with the text direction.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
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
            tooltip: l.teacherPromoteAttemptAction,
            icon: const Icon(Icons.upgrade_outlined),
            onPressed: () => _showPromoteAttemptPrompt(context, ref, l),
          ),
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
    final publishExamAsync =
        ref.watch(publishTeacherExamProvider(plan.id));
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
        Row(
          children: [
            Expanded(
              child: Text(
                l.teacherExamQuestionsHeader,
                style: tokens.typography.titleSmall.copyWith(
                  color: tokens.text.secondary,
                ),
              ),
            ),
            LsButton.secondary(
              label: l.teacherExamAddQuestionAction,
              icon: Icons.add,
              expand: false,
              onPressed: () {
                final subjectQuery = subject.isEmpty
                    ? ''
                    : '?subject=${Uri.encodeComponent(subject)}';
                context.go(
                  '/shell/teachers/exams/${Uri.encodeComponent(plan.id)}/questions/new$subjectQuery',
                );
              },
            ),
          ],
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
                      subject: subject,
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
          label: publishExamAsync.isLoading
              ? l.teacherExamPublishLoading
              : l.teacherExamPublishAction,
          icon: Icons.publish_outlined,
          expand: true,
          onPressed: publishExamAsync.isLoading
              ? null
              : () => _onPublishExam(context, ref, plan, subject),
        ),
        SizedBox(height: tokens.space.sm),
        LsButton.secondary(
          label: l.teacherExamManualGradeAction,
          icon: Icons.grading_outlined,
          expand: true,
          onPressed: () {
            final subjectQuery = subject.isEmpty
                ? ''
                : '?subject=${Uri.encodeComponent(subject)}';
            context.go(
              '/shell/teachers/exams/${Uri.encodeComponent(plan.id)}/grade$subjectQuery',
            );
          },
        ),
      ],
    );
  }

  Future<void> _onPublishExam(
    BuildContext context,
    WidgetRef ref,
    ExamPlan plan,
    String subject,
  ) async {
    // The mobile does not currently maintain an
    // "audience" list (the v1 server is expected to
    // resolve the audience from the plan's
    // `school_class_group` + branch on publish). The
    // wire envelope accepts an empty list and the
    // server fills it in from the plan's class
    // enrollment. The question list is the per-subject
    // list rendered on this screen; we pass every
    // question's id.
    final questionsAsync = subject.isEmpty
        ? null
        : ref.read(teacherExamQuestionsProvider(subject));
    final questions = questionsAsync?.value ?? const [];
    final questionIds = <String>[
      for (final q in questions) q.id,
    ];
    final result = await ref
        .read(publishTeacherExamProvider(plan.id).notifier)
        .publish(questionIds: questionIds);
    if (!context.mounted) return;
    final l = AppLocalizations.of(context);
    switch (result) {
      case Ok():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.teacherExamPublishedSnack)),
        );
      case Err(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l.teacherExamPublishErrorSnack(error.message),
            ),
          ),
        );
    }
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

class _QuestionCard extends ConsumerWidget {
  const _QuestionCard({
    required this.tokens,
    required this.index,
    required this.question,
    required this.subject,
  });
  final DesignTokens tokens;
  final int index;
  final TeacherExamQuestion question;
  final String subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final publishAsync =
        ref.watch(publishTeacherExamQuestionProvider(question.id));
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
          SizedBox(height: tokens.space.xs),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: LsButton.secondary(
              label: publishAsync.isLoading
                  ? l.teacherExamQuestionPublishLoading
                  : l.teacherExamQuestionPublishAction,
              icon: Icons.publish_outlined,
              expand: false,
              onPressed: publishAsync.isLoading
                  ? null
                  : () => _onPublish(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onPublish(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(publishTeacherExamQuestionProvider(question.id).notifier)
        .publish(schoolSubject: subject);
    if (!context.mounted) return;
    final l = AppLocalizations.of(context);
    switch (result) {
      case Ok():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.teacherExamQuestionPublishedSnack)),
        );
      case Err(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l.teacherExamQuestionPublishErrorSnack(error.message),
            ),
          ),
        );
    }
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


/// Show a 1-field prompt that asks the teacher for the
/// attempt id, then calls `promote_school_exam_attempt`
/// on Continue. The v1 SDK does not expose a "list
/// attempts" endpoint on the mobile SDK today, so the
/// teacher enters the attempt id (the same pattern as
/// the manual grade form + the admin "Correct a grade"
/// + the admin "Promote assessment result" prompts).
Future<void> _showPromoteAttemptPrompt(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l,
) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(l.teacherPromoteAttemptPromptTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l.teacherPromoteAttemptLabel,
            hintText: l.teacherPromoteAttemptHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.commonCancel),
          ),
          FilledButton.tonal(
            onPressed: () {
              final id = controller.text.trim();
              if (id.isEmpty) return;
              Navigator.of(ctx).pop(id);
            },
            child: Text(l.commonContinue),
          ),
        ],
      );
    },
  );
  if (result == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  final tokens = context.laratik;
  final outcome = await promoteTeacherExamAttempt(
    ref,
    attempt: result,
  );
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        switch (outcome) {
          Ok(:final value) => value.hasGradeRecord
              ? l.teacherPromoteAttemptSuccess(value.gradeRecord)
              : l.teacherPromoteAttemptSuccessFallback,
          Err(:final error) => l.teacherPromoteAttemptError(error.message),
        },
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: switch (outcome) {
        Ok() => tokens.status.success,
        Err() => tokens.status.error,
      },
    ),
  );
}

