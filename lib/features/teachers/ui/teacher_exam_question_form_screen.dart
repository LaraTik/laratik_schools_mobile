// SPDX-License-Identifier: Proprietary
// Question authoring form — the teacher enters the
// question text + type + marks + (for choice questions)
// the option list, and submits via
// `create_school_question`.
//
// The form is "wizard-free" by design: the SDK already
// wraps per-question creation in a single call, and the
// v1 server persists the question under the named exam
// plan via the `exam_plan` field. On success, the per-
// subject question list provider is invalidated so the
// plan detail re-renders with the new question card.
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
import '../../../ui/widgets/ls_text_field.dart';
import '../data/teacher_exam_providers.dart';

class TeacherExamQuestionFormScreen extends ConsumerStatefulWidget {
  const TeacherExamQuestionFormScreen({
    required this.examPlan,
    required this.subject,
    super.key,
  });
  final String examPlan;
  final String subject;

  @override
  ConsumerState<TeacherExamQuestionFormScreen> createState() =>
      _TeacherExamQuestionFormScreenState();
}

class _TeacherExamQuestionFormScreenState
    extends ConsumerState<TeacherExamQuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _marksController = TextEditingController(text: '1');
  String _questionType = 'Single Choice';
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctIndex = 0;

  @override
  void dispose() {
    _textController.dispose();
    _marksController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _isChoiceQuestion =>
      _questionType == 'Single Choice' ||
      _questionType == 'Multiple Choice' ||
      _questionType == 'True/False';

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return;
    setState(() {
      final removed = _optionControllers.removeAt(index);
      removed.dispose();
      if (_correctIndex >= _optionControllers.length) {
        _correctIndex = _optionControllers.length - 1;
      }
    });
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final marks = int.tryParse(_marksController.text.trim()) ?? 0;
    final options = <Map<String, Object?>>[];
    if (_isChoiceQuestion) {
      for (var i = 0; i < _optionControllers.length; i++) {
        final text = _optionControllers[i].text.trim();
        if (text.isEmpty) continue;
        options.add(<String, Object?>{
          'option_key': 'OPT-${i + 1}',
          'option_text': text,
          'is_correct': i == _correctIndex,
        });
      }
    }
    final result = await ref
        .read(createTeacherExamQuestionProvider(widget.examPlan).notifier)
        .submit(
          examPlan: widget.examPlan,
          questionText: _textController.text.trim(),
          questionType: _questionType,
          marks: marks,
          schoolSubject: widget.subject.isEmpty ? null : widget.subject,
          options: options.isEmpty ? null : options,
        );
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    switch (result) {
      case Ok():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.teacherExamQuestionCreatedSnack)),
        );
        if (mounted) {
          context.go(
            '/shell/teachers/exams/${Uri.encodeComponent(widget.examPlan)}',
          );
        }
      case Err(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l.teacherExamQuestionErrorSnack(error.message),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final submitAsync = ref
        .watch(createTeacherExamQuestionProvider(widget.examPlan));
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.teacherExamQuestionFormTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
      ),
      body: Form(
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
              label: l.teacherExamQuestionTypeHeader,
              icon: Icons.help_outline,
            ),
            SizedBox(height: tokens.space.xs),
            _QuestionTypePicker(
              tokens: tokens,
              value: _questionType,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _questionType = value;
                  if (value == 'True/False') {
                    if (_optionControllers.length < 2) {
                      while (_optionControllers.length < 2) {
                        _optionControllers.add(TextEditingController());
                      }
                    }
                    while (_optionControllers.length > 2) {
                      final removed = _optionControllers.removeLast();
                      removed.dispose();
                    }
                    if (_optionControllers[0].text.isEmpty) {
                      _optionControllers[0].text = 'True';
                    }
                    if (_optionControllers[1].text.isEmpty) {
                      _optionControllers[1].text = 'False';
                    }
                  }
                });
              },
            ),
            SizedBox(height: tokens.space.lg),
            _SectionLabel(
              tokens: tokens,
              label: l.teacherExamQuestionTextHeader,
              icon: Icons.text_fields,
            ),
            SizedBox(height: tokens.space.xs),
            LsTextField(
              controller: _textController,
              label: l.teacherExamQuestionTextLabel,
              hint: l.teacherExamQuestionTextHint,
              required: true,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l.teacherExamQuestionTextRequired;
                }
                return null;
              },
            ),
            SizedBox(height: tokens.space.lg),
            _SectionLabel(
              tokens: tokens,
              label: l.teacherExamQuestionMarksHeader,
              icon: Icons.star_outline,
            ),
            SizedBox(height: tokens.space.xs),
            LsTextField(
              controller: _marksController,
              label: l.teacherExamQuestionMarksLabel,
              hint: l.teacherExamQuestionMarksHint,
              required: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l.teacherExamQuestionMarksRequired;
                }
                final parsed = int.tryParse(value.trim());
                if (parsed == null) {
                  return l.teacherExamQuestionMarksInvalid;
                }
                if (parsed <= 0) {
                  return l.teacherExamQuestionMarksNegative;
                }
                return null;
              },
            ),
            if (_isChoiceQuestion) ...[
              SizedBox(height: tokens.space.lg),
              _SectionLabel(
                tokens: tokens,
                label: l.teacherExamQuestionOptionsHeader(
                  _optionControllers.length,
                ),
                icon: Icons.checklist_outlined,
              ),
              SizedBox(height: tokens.space.xs),
              for (var i = 0; i < _optionControllers.length; i++) ...[
                if (i > 0) SizedBox(height: tokens.space.xs),
                _OptionRow(
                  tokens: tokens,
                  index: i,
                  controller: _optionControllers[i],
                  isCorrect: _correctIndex == i,
                  isRemovable: _optionControllers.length > 2 &&
                      _questionType != 'True/False',
                  onCorrectChanged: () {
                    setState(() {
                      _correctIndex = i;
                    });
                  },
                  onRemove: () => _removeOption(i),
                ),
              ],
              if (_questionType != 'True/False') ...[
                SizedBox(height: tokens.space.xs),
                LsButton.secondary(
                  label: l.teacherExamQuestionAddOption,
                  icon: Icons.add,
                  expand: false,
                  onPressed: _addOption,
                ),
              ],
            ],
            SizedBox(height: tokens.space.lg),
            LsButton.primary(
              label: submitAsync.isLoading
                  ? l.teacherExamQuestionSubmitLoading
                  : l.teacherExamQuestionSubmitAction,
              icon: Icons.check_circle_outline,
              expand: true,
              onPressed: submitAsync.isLoading ? null : _onSubmit,
            ),
          ],
        ),
      ),
    );
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

class _QuestionTypePicker extends StatelessWidget {
  const _QuestionTypePicker({
    required this.tokens,
    required this.value,
    required this.onChanged,
  });
  final DesignTokens tokens;
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: tokens.space.xs,
      runSpacing: tokens.space.xxs,
      children: [
        for (final type in const [
          'Single Choice',
          'Multiple Choice',
          'True/False',
          'Short Text',
          'Long Text',
          'Numeric',
        ])
          ChoiceChip(
            label: Text(type),
            selected: value == type,
            onSelected: (selected) {
              if (selected) onChanged(type);
            },
          ),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.tokens,
    required this.index,
    required this.controller,
    required this.isCorrect,
    required this.isRemovable,
    required this.onCorrectChanged,
    required this.onRemove,
  });
  final DesignTokens tokens;
  final int index;
  final TextEditingController controller;
  final bool isCorrect;
  final bool isRemovable;
  final VoidCallback onCorrectChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(tokens.space.sm),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: isCorrect ? 'Correct' : 'Mark as correct',
            icon: Icon(
              isCorrect
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isCorrect ? tokens.brand.primary : tokens.text.tertiary,
            ),
            onPressed: onCorrectChanged,
          ),
          SizedBox(width: tokens.space.xs),
          Expanded(
            child: TextField(
              controller: controller,
              style: tokens.typography.bodyMedium.copyWith(
                color: tokens.text.primary,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Option ${index + 1}',
              ),
            ),
          ),
          if (isRemovable)
            IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.close),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
