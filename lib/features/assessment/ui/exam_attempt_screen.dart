import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../data/assessment_providers.dart';
import '../data/assessment_repository.dart';
import '../data/current_student_provider.dart';
import '../data/exam.dart';

import '../../../ui/app_theme.dart';

/// Exam attempt screen. Renders the question list, autosaves every 15s,
/// and surfaces a Submit action that POSTs the final answers. The screen
/// is keyed by the student + exam plan pair; the actual attempt id is
/// minted by the server when [startAttempt] resolves.
///
/// [studentId] is kept for backward compatibility with the router's
/// `?student=...` deep-link query param. When empty, the screen falls
/// back to [currentStudentProvider] — the typical case in the dev
/// shell where the mobile session is pinned to a single student by
/// the dev seed.
class ExamAttemptScreen extends ConsumerStatefulWidget {
  const ExamAttemptScreen({
    required this.examPlanId,
    this.studentId = '',
    super.key,
  });

  final String examPlanId;
  final String studentId;

  @override
  ConsumerState<ExamAttemptScreen> createState() => _ExamAttemptScreenState();
}

class _ExamAttemptScreenState extends ConsumerState<ExamAttemptScreen> {
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, Set<String>> _multiSelect = {};
  String? _singleChoice;
  String? _attemptId;
  int? _revision;
  List<ExamQuestion> _questions = const [];
  String? _autosaveStatus;
  Timer? _autosaveTimer;
  bool _submitting = false;
  bool _started = false;
  bool _abandoning = false;
  bool _abandoned = false;
  bool _submitted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _autosaveTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _autosave(),
    );
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _start() async {
    // Re-resolve the current student at start time so the screen
    // works even if the build resolved an empty id (the provider is
    // still warming up).
    final current = ref.read(currentStudentProvider).valueOrNull;
    final studentId = widget.studentId.isNotEmpty
        ? widget.studentId
        : (current?.studentId ?? '');
    final enrollmentId = current?.enrollmentId ?? '';
    if (studentId.isEmpty) {
      setState(() => _error = 'No student resolved. Sign in and retry.');
      return;
    }
    final repo = ref.read(assessmentRepositoryProvider);
    final result = await repo.startAttempt(
      examPlanId: widget.examPlanId,
      studentId: studentId,
      schoolEnrollment: enrollmentId.isEmpty ? null : enrollmentId,
    );
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        setState(() {
          _started = true;
          _attemptId = value.attemptId;
          _revision = value.revision;
          _questions = value.questions;
        });
      case Err(:final error):
        setState(() => _error = error.message);
    }
  }

  Future<void> _autosave() async {
    if (_attemptId == null || _revision == null) return;
    final repo = ref.read(assessmentRepositoryProvider);
    final result = await repo.autosave(
      attemptId: _attemptId!,
      revision: _revision!,
      answers: _currentAnswers(),
    );
    if (!mounted) return;
    setState(() {
      _autosaveStatus = switch (result) {
        Ok() => 'Saved at ${TimeOfDay.now().format(context)}',
        Err() => 'Autosave failed',
      };
    });
  }

  Future<void> _submit() async {
    if (_attemptId == null || _revision == null || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final repo = ref.read(assessmentRepositoryProvider);
    final result = await repo.submit(
      attemptId: _attemptId!,
      revision: _revision!,
      answers: _currentAnswers(),
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _submitted = result is Ok;
    });
    if (result is Err) {
      setState(() {
        if (result case Err(:final error)) {
          _error = error.message;
        }
      });
    } else {
      _autosaveTimer?.cancel();
    }
  }

  Future<void> _abandon() async {
    if (_attemptId == null || _abandoning) return;
    setState(() => _abandoning = true);
    final repo = ref.read(assessmentRepositoryProvider);
    await repo.abandon(_attemptId!);
    if (!mounted) return;
    setState(() {
      _abandoning = false;
      _abandoned = true;
    });
    _autosaveTimer?.cancel();
  }

  Map<String, Object?> _currentAnswers() {
    final result = <String, Object?>{};
    _textControllers.forEach((id, controller) {
      result[id] = controller.text;
    });
    if (_singleChoice != null) {
      result['__single_choice__'] = _singleChoice;
    }
    if (_multiSelect.isNotEmpty) {
      result['__multi_select__'] = _multiSelect.map(
        (key, value) => MapEntry(key, value.toList()),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    // Resolve the student id from the deep-link query param when
    // present, otherwise from `currentStudentProvider`. We hold the
    // resolved id in [widget.studentId] only at construction; the
    // `ref.watch` here gives us the live value as the provider
    // resolves.
    final currentStudentAsync = ref.watch(currentStudentProvider);
    final resolvedStudentId = widget.studentId.isNotEmpty
        ? widget.studentId
        : (currentStudentAsync.valueOrNull?.studentId ?? '');
    // The server-side `is_eligible` check requires the active
    // enrollment id to match the audience row's `school_enrollment`.
    // We pass it through from the resolved current student so the
    // mobile user doesn't have to re-pick it per exam.
    final resolvedEnrollmentId =
        currentStudentAsync.valueOrNull?.enrollmentId ?? '';
    final asyncEligibility = ref.watch(examEligibilityProvider(
      ExamEligibilityArgs(
        examPlanId: widget.examPlanId,
        studentId: resolvedStudentId,
        schoolEnrollment: resolvedEnrollmentId,
      ),
    ));
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shell/assessment/exams'),
        ),
        title: Text(
          'Exam attempt',
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          if (_started && !_submitted && !_abandoned)
            Padding(
              padding: EdgeInsets.only(right: tokens.space.sm),
              child: Text(
                _autosaveStatus ?? 'Autosave armed',
                style: tokens.typography.bodySmall.copyWith(
                  color: tokens.text.tertiary,
                ),
              ),
            ),
        ],
      ),
      body: asyncEligibility.when(
        data: (result) {
          return switch (result) {
            Ok(:final value) => value.eligible
                ? _buildAttempt(tokens)
                : _buildIneligible(value, tokens),
            Err(:final error) => LsStateView.error(
                icon: Icons.error_outline,
                title: 'Could not check eligibility',
                message: error.message,
              ),
          };
        },
        loading: () {
          return const LsStateView.loading(title: 'Checking eligibility');
        },
        error: (err, _) {
          return LsStateView.error(
            icon: Icons.error_outline,
            title: 'Could not check eligibility',
            message: err.toString(),
          );
        },
      ),
    );
  }

  Widget _buildIneligible(EligibilityResult value, DesignTokens tokens) {
    return LsStateView.empty(
      icon: Icons.block,
      title: 'Not eligible',
      message: 'The server says you cannot take this exam.',
      action: LsButton.secondary(
        label: 'Back to exams',
        icon: Icons.arrow_back,
        onPressed: () => context.go('/shell/assessment/exams'),
      ),
    );
  }

  Widget _buildAttempt(DesignTokens tokens) {
    if (_abandoned) {
      return LsStateView.empty(
        icon: Icons.flag_outlined,
        title: 'Attempt abandoned',
        message:
            'You abandoned this attempt. The server marked it as abandoned.',
        action: LsButton.primary(
          label: 'Back to exams',
          icon: Icons.arrow_back,
          onPressed: () => context.go('/shell/assessment/exams'),
        ),
      );
    }
    if (_submitted) {
      return LsStateView.empty(
        icon: Icons.check_circle_outline,
        title: 'Submitted',
        message:
            'Your answers are on the server. Check back when the result is published.',
        action: LsButton.primary(
          label: 'Back to exams',
          icon: Icons.arrow_back,
          onPressed: () => context.go('/shell/assessment/exams'),
        ),
      );
    }

    if (!_started) {
      if (_error != null) {
        return LsStateView.error(
          icon: Icons.error_outline,
          title: 'Could not start the attempt',
          message: _error!,
          action: LsButton.primary(
            label: 'Try again',
            icon: Icons.refresh,
            expand: false,
            onPressed: _start,
          ),
        );
      }
      return _buildStart(tokens);
    }
    return _buildQuestions(tokens);
  }

  Widget _buildStart(DesignTokens tokens) {
    final currentStudentAsync = ref.watch(currentStudentProvider);
    final currentStudent = currentStudentAsync.valueOrNull;
    return Padding(
      padding: EdgeInsets.all(tokens.space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to start?',
            style: tokens.typography.titleLarge.copyWith(
              color: tokens.text.primary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          currentStudent == null
              ? Text(
                  currentStudentAsync.hasError
                      ? 'Could not resolve student: ${currentStudentAsync.error}'
                      : 'Resolving student…',
                  style: tokens.typography.bodyLarge.copyWith(
                    color: tokens.text.secondary,
                  ),
                )
              : Text(
                  'Student: ${currentStudent.person.fullName.isEmpty ? currentStudent.studentId : currentStudent.person.fullName}',
                  style: tokens.typography.bodyLarge.copyWith(
                    color: tokens.text.secondary,
                  ),
                ),
          SizedBox(height: tokens.space.lg),
          const LsStatusChip(
            label: 'Autosave every 15s',
            icon: Icons.autorenew,
            tone: LsChipTone.info,
          ),
          SizedBox(height: tokens.space.lg),
          LsButton.primary(
            label: currentStudent == null ? 'Resolving…' : 'Start attempt',
            icon: Icons.play_arrow,
            onPressed: currentStudent == null ? null : _start,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestions(DesignTokens tokens) {
    if (_questions.isEmpty) {
      return const LsStateView.empty(
        icon: Icons.help_outline,
        title: 'No questions',
        message: 'The server did not return any questions for this attempt.',
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(tokens.space.md),
            itemCount: _questions.length,
            separatorBuilder: (_, __) => SizedBox(height: tokens.space.md),
            itemBuilder: (context, index) {
              final q = _questions[index];
              return _QuestionCard(
                question: q,
                textController: _textControllers.putIfAbsent(
                  q.id,
                  () => TextEditingController(),
                ),
                singleChoice: _singleChoice,
                multiSelect: _multiSelect[q.id] ?? <String>{},
                onSingleChoiceChanged: (value) {
                  setState(() => _singleChoice = value);
                },
                onMultiSelectToggled: (value, selected) {
                  setState(() {
                    final set = _multiSelect.putIfAbsent(
                      q.id,
                      () => <String>{},
                    );
                    if (selected) {
                      set.add(value);
                    } else {
                      set.remove(value);
                    }
                  });
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(tokens.space.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Container(
                    padding: EdgeInsets.all(tokens.space.sm),
                    decoration: BoxDecoration(
                      color: tokens.status.errorContainer,
                      borderRadius: BorderRadius.circular(tokens.radius.md),
                      border: Border.all(color: tokens.status.error),
                    ),
                    child: Text(
                      _error!,
                      style: tokens.typography.bodyMedium.copyWith(
                        color: tokens.status.error,
                      ),
                    ),
                  ),
                if (_error != null) SizedBox(height: tokens.space.sm),
                Row(
                  children: [
                    Expanded(
                      child: LsButton.secondary(
                        label: _abandoning ? 'Abandoning…' : 'Abandon',
                        icon: Icons.flag_outlined,
                        isLoading: _abandoning,
                        onPressed:
                            _abandoning ? null : () => _confirmAbandon(tokens),
                      ),
                    ),
                    SizedBox(width: tokens.space.sm),
                    Expanded(
                      flex: 2,
                      child: LsButton.primary(
                        label: _submitting ? 'Submitting…' : 'Submit attempt',
                        icon: Icons.check,
                        isLoading: _submitting,
                        onPressed: _submitting ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmAbandon(DesignTokens tokens) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Abandon attempt?'),
          content: const Text(
            'This will mark the attempt as abandoned on the server. '
            'You cannot resume it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Abandon'),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      await _abandon();
    }
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.textController,
    required this.singleChoice,
    required this.multiSelect,
    required this.onSingleChoiceChanged,
    required this.onMultiSelectToggled,
  });

  final ExamQuestion question;
  final TextEditingController textController;
  final String? singleChoice;
  final Set<String> multiSelect;
  final ValueChanged<String> onSingleChoiceChanged;
  final void Function(String value, bool selected) onMultiSelectToggled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
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
              Expanded(
                child: Text(
                  question.questionText,
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
              ),
              LsStatusChip(
                label: '${question.marks} pt${question.marks == 1 ? '' : 's'}',
                tone: LsChipTone.brand,
                icon: Icons.star_outline,
              ),
            ],
          ),
          SizedBox(height: tokens.space.sm),
          if (question.questionType == ExamQuestion.typeText ||
              question.questionType == ExamQuestion.typeEssay ||
              question.options.isEmpty)
            TextField(
              controller: textController,
              minLines: 3,
              maxLines: 8,
              style: tokens.typography.bodyMedium.copyWith(
                color: tokens.text.primary,
              ),
              decoration: InputDecoration(
                hintText: 'Type your answer…',
                filled: true,
                fillColor: tokens.surface.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                  borderSide: BorderSide(color: tokens.surface.outline),
                ),
              ),
            )
          else if (question.questionType == ExamQuestion.typeMultiChoice ||
              question.questionType == ExamQuestion.typeTrueFalse)
            for (final option in question.options)
              RadioListTile<String>(
                value: (option['value'] ?? option['name'] ?? '').toString(),
                groupValue: singleChoice,
                onChanged: (value) {
                  if (value != null) onSingleChoiceChanged(value);
                },
                title: Text(
                  (option['label'] ?? option['name'] ?? '—').toString(),
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
              )
          else if (question.questionType == ExamQuestion.typeMultiSelect)
            for (final option in question.options)
              CheckboxListTile(
                value: multiSelect.contains(
                  (option['value'] ?? option['name'] ?? '').toString(),
                ),
                onChanged: (selected) {
                  if (selected != null) {
                    onMultiSelectToggled(
                      (option['value'] ?? option['name'] ?? '').toString(),
                      selected,
                    );
                  }
                },
                title: Text(
                  (option['label'] ?? option['name'] ?? '—').toString(),
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
              )
          else
            Text(
              'Unsupported question type: ${question.questionType}',
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.status.warning,
              ),
            ),
        ],
      ),
    );
  }
}
