// SPDX-License-Identifier: Proprietary
// Manual grade form — the teacher enters an attempt ID
// + per-question scores for an exam plan's questions
// and submits via `grade_school_exam_attempt`.
//
// The form is "open-ended" by design: the mobile
// doesn't currently list attempts (the v1 SDK doesn't
// expose a `listSchoolExamAttempts` endpoint), so the
// teacher enters the attempt ID from a desktop or
// notification. The per-question score fields default
// to 0; the teacher fills in the values for the
// open-ended questions (short text, essay, numeric) and
// leaves 0 for the auto-graded multiple choice + true/
// false questions. The server returns the new total
// score on success.
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)]; the form layout
// mirrors itself under RTL so the field order stays
// consistent with the text direction.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_text_field.dart';
import '../data/teacher_exam_providers.dart';
import '../data/teacher_exam_repository.dart';

class ManualGradeScreen extends ConsumerStatefulWidget {
  const ManualGradeScreen({
    required this.examPlan,
    required this.subject,
    super.key,
  });
  final String examPlan;
  final String subject;

  @override
  ConsumerState<ManualGradeScreen> createState() => _ManualGradeScreenState();
}

class _ManualGradeScreenState extends ConsumerState<ManualGradeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _attemptController = TextEditingController();
  final Map<String, TextEditingController> _scoreControllers = {};

  @override
  void dispose() {
    _attemptController.dispose();
    for (final c in _scoreControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String questionId) {
    return _scoreControllers.putIfAbsent(questionId, () {
      return TextEditingController(text: '0');
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final subject = widget.subject;
    final questionsAsync = subject.isEmpty
        ? const AsyncValue<List<TeacherExamQuestion>>.data(<TeacherExamQuestion>[])
        : ref.watch(teacherExamQuestionsProvider(subject));
    final submitAsync = ref.watch(manualGradeSubmitProvider(widget.examPlan));
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.manualGradeScreenTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (subject.isNotEmpty) {
                ref.invalidate(teacherExamQuestionsProvider(subject));
              }
            },
          ),
        ],
      ),
      body: questionsAsync.when(
        data: (questions) => _buildBody(
          context,
          tokens,
          questions,
          submitAsync,
        ),
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
    );
  }

  Widget _buildBody(
    BuildContext context,
    DesignTokens tokens,
    List<TeacherExamQuestion> questions,
    AsyncValue<void> submitAsync,
  ) {
    final l = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.space.md,
          tokens.space.md,
          tokens.space.md,
          tokens.space.xl,
        ),
        children: [
          _SectionLabel(
            tokens: tokens,
            label: l.manualGradeAttemptHeader,
            icon: Icons.fingerprint_outlined,
          ),
          SizedBox(height: tokens.space.xs),
          LsTextField(
            controller: _attemptController,
            label: l.manualGradeAttemptLabel,
            hint: l.manualGradeAttemptHint,
            required: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l.manualGradeAttemptRequired;
              }
              return null;
            },
          ),
          SizedBox(height: tokens.space.lg),
          _SectionLabel(
            tokens: tokens,
            label: l.manualGradeScoresHeader(questions.length),
            icon: Icons.score_outlined,
          ),
          SizedBox(height: tokens.space.xs),
          if (questions.isEmpty)
            _EmptyMessage(
              tokens: tokens,
              title: l.manualGradeScoresEmptyTitle,
              message: l.manualGradeScoresEmptyMessage,
            )
          else
            for (var i = 0; i < questions.length; i++) ...[
              if (i > 0) SizedBox(height: tokens.space.sm),
              _ScoreField(
                tokens: tokens,
                index: i + 1,
                question: questions[i],
                controller: _controllerFor(questions[i].id),
              ),
            ],
          SizedBox(height: tokens.space.lg),
          LsButton.primary(
            label: submitAsync.isLoading
                ? l.manualGradeSubmitLoading
                : l.manualGradeSubmitAction,
            icon: Icons.check_circle_outline,
            expand: true,
            onPressed: submitAsync.isLoading ? null : _onSubmit,
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final attempt = _attemptController.text.trim();
    final scores = <String, double>{};
    for (final entry in _scoreControllers.entries) {
      final raw = entry.value.text.trim();
      final value = double.tryParse(raw);
      if (value != null) scores[entry.key] = value;
    }
    final result = await ref
        .read(manualGradeSubmitProvider(attempt).notifier)
        .submit(scores: scores);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    switch (result) {
      case Ok(:final value):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value.score == null
                  ? l.manualGradeSuccessSnackNoScore
                  : l.manualGradeSuccessSnack(value.score!),
            ),
          ),
        );
        if (mounted) {
          context.go('/shell/teachers/exams');
        }
      case Err(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l.manualGradeErrorSnack(error.message),
            ),
          ),
        );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.tokens,
    required this.label,
    required this.icon,
  });
  final DesignTokens tokens;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: tokens.text.secondary),
        SizedBox(width: tokens.space.xs),
        Text(
          label,
          style: tokens.typography.titleSmall.copyWith(
            color: tokens.text.secondary,
          ),
        ),
      ],
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({
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
    );
  }
}

class _ScoreField extends StatelessWidget {
  const _ScoreField({
    required this.tokens,
    required this.index,
    required this.question,
    required this.controller,
  });
  final DesignTokens tokens;
  final int index;
  final TeacherExamQuestion question;
  final TextEditingController controller;

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
            ],
          ),
          SizedBox(height: tokens.space.xs),
          LsTextField(
            controller: controller,
            label: l.manualGradeScoreLabel,
            hint: l.manualGradeScoreHint(question.marks),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            required: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l.manualGradeScoreRequired;
              }
              final parsed = double.tryParse(value.trim());
              if (parsed == null) {
                return l.manualGradeScoreInvalid;
              }
              if (parsed < 0) {
                return l.manualGradeScoreNegative;
              }
              if (parsed > question.marks) {
                return l.manualGradeScoreOverMax(question.marks);
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
