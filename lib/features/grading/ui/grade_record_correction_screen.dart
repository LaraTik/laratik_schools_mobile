// SPDX-License-Identifier: Proprietary
// Admin "Correct a grade record" form.
//
// Reachable from the Grading surface as a write flow:
//   1. The admin opens a grade's row on the policies
//      tab (or a future "recent grades" surface).
//   2. Tapping **Correct** pushes this form with the
//      grade id baked in.
//   3. The form submits via
//      `correct_school_grade_record` — the v1 server
//      requires `require_grade_approval_access()` (admin
//      role).
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)]; the per-field error
// chips + the success card use the same patterns as the
// student + staff + guardian create surfaces.
//
// The repository mints a fresh UUID for the
// `Idempotency-Key` header so a retry of the same
// correction is safe to send again. On success the
// overview + policies providers are invalidated so
// the next ref.watch re-fetches the new summary.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../../../ui/widgets/ls_text_field.dart';
import '../data/grade_record_correction.dart';
import '../data/grading_providers.dart';

import '../../../ui/app_theme.dart';

class GradeRecordCorrectionScreen extends ConsumerStatefulWidget {
  const GradeRecordCorrectionScreen({
    required this.gradeName,
    super.key,
  });

  final String gradeName;

  @override
  ConsumerState<GradeRecordCorrectionScreen> createState() =>
      _GradeRecordCorrectionScreenState();
}

class _GradeRecordCorrectionScreenState
    extends ConsumerState<GradeRecordCorrectionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _gradeNameController;
  late final TextEditingController _scoreController;
  late final TextEditingController _maxScoreController;
  late final TextEditingController _reasonController;
  GradeRecordCorrectionPayload _payload =
      const GradeRecordCorrectionPayload.empty('');
  bool _submitting = false;
  String? _generalError;
  Map<String, List<String>> _fieldErrors = const {};
  bool _isWide = false;

  @override
  void initState() {
    super.initState();
    _gradeNameController = TextEditingController(text: widget.gradeName);
    _scoreController = TextEditingController();
    _maxScoreController = TextEditingController();
    _reasonController = TextEditingController();
    _payload = _payload.copyWith(gradeName: widget.gradeName);
    for (final c in [
      _gradeNameController,
      _scoreController,
      _maxScoreController,
      _reasonController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _gradeNameController,
      _scoreController,
      _maxScoreController,
      _reasonController,
    ]) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {
      _payload = _payload.copyWith(
        gradeName: _gradeNameController.text,
        score: _scoreController.text,
        maxScore: _maxScoreController.text,
        reason: _reasonController.text,
      );
      _fieldErrors = const {};
      _generalError = null;
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _generalError = null;
      _fieldErrors = const {};
    });
    final controller = ref.read(correctGradeRecordProvider.notifier);
    final result = await controller.submit(_payload);
    if (!mounted) return;
    setState(() => _submitting = false);
    switch (result) {
      case Ok(:final value):
        _showSuccessCard(value);
      case Err(:final error):
        setState(() {
          _generalError = error.message;
          _fieldErrors = error.fieldErrors;
        });
    }
  }

  void _showSuccessCard(CorrectedGradeRecord result) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final tokens = sheetContext.laratik;
        final l = AppLocalizations.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(tokens.space.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: tokens.status.success),
                    SizedBox(width: tokens.space.sm),
                    Text(
                      l.gradingCorrectionSuccessTitle,
                      style: tokens.typography.titleLarge.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.space.sm),
                Text(
                  result.gradeName.isEmpty
                      ? l.gradingCorrectionSuccessFallback
                      : l.gradingCorrectionSuccessLabel(result.gradeName),
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.text.secondary,
                  ),
                ),
                SizedBox(height: tokens.space.sm),
                Wrap(
                  spacing: tokens.space.xs,
                  runSpacing: tokens.space.xs,
                  children: [
                    if (result.hasScore)
                      LsStatusChip(
                        label: l.gradingCorrectionScoreChip(
                          result.correctedScore!),
                        icon: Icons.check,
                        tone: LsChipTone.success,
                      ),
                    if (result.hasMaxScore)
                      LsStatusChip(
                        label: l.gradingCorrectionMaxScoreChip(
                            result.correctedMaxScore!),
                        icon: Icons.star_outline,
                        tone: LsChipTone.brand,
                      ),
                    if (result.actor != null && result.actor!.isNotEmpty)
                      LsStatusChip(
                        label: l.gradingCorrectionActorChip(result.actor!),
                        icon: Icons.person_outline,
                        tone: LsChipTone.info,
                      ),
                  ],
                ),
                if (result.timestamp != null && result.timestamp!.isNotEmpty)
                  Padding(
                    padding: EdgeInsetsDirectional.only(top: tokens.space.sm),
                    child: Text(
                      l.gradingCorrectionTimestampLabel(result.timestamp!),
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.text.tertiary,
                        fontFamily: tokens.typography.monoFamily,
                      ),
                    ),
                  ),
                SizedBox(height: tokens.space.lg),
                Row(
                  children: [
                    Expanded(
                      child: LsButton.secondary(
                        label: l.gradingCorrectionAnotherAction,
                        icon: Icons.add,
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _resetForm();
                        },
                      ),
                    ),
                    SizedBox(width: tokens.space.sm),
                    Expanded(
                      child: LsButton.primary(
                        label: l.gradingCorrectionBackAction,
                        icon: Icons.arrow_forward,
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          context.go('/shell/grading');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetForm() {
    _gradeNameController.text = widget.gradeName;
    _scoreController.clear();
    _maxScoreController.clear();
    _reasonController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    _isWide = MediaQuery.sizeOf(context).width >= 720;
    final asyncState = ref.watch(correctGradeRecordProvider);
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          tooltip: l.commonBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shell/grading'),
        ),
        title: Text(
          l.gradingCorrectionScreenTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
      ),
      body: asyncState.when(
        data: (corrected) => _buildForm(corrected, tokens, l),
        loading: () => LsStateView.loading(
          title: l.gradingCorrectionLoadingTitle,
          message: l.gradingCorrectionLoadingMessage,
        ),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: l.gradingCorrectionErrorTitle,
          message: err.toString(),
          action: LsButton.primary(
            label: l.commonTryAgain,
            expand: false,
            onPressed: () => ref.invalidate(correctGradeRecordProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    CorrectedGradeRecord? corrected,
    DesignTokens tokens,
    AppLocalizations l,
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          _SectionLabel(l.gradingCorrectionTargetHeader, tokens: tokens),
          LsTextField(
            label: l.gradingCorrectionGradeLabel,
            required: true,
            controller: _gradeNameController,
            errorText: _errorFor('grade_name'),
            onChanged: (_) => _onFieldChanged(),
          ),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.gradingCorrectionScoresHeader, tokens: tokens),
          _buildFieldsColumnOrRow([
            LsTextField(
              label: l.gradingCorrectionScoreLabel,
              required: true,
              controller: _scoreController,
              hint: l.gradingCorrectionScoreHint,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              errorText: _errorFor('score'),
              onChanged: (_) => _onFieldChanged(),
            ),
            LsTextField(
              label: l.gradingCorrectionMaxScoreLabel,
              required: true,
              controller: _maxScoreController,
              hint: l.gradingCorrectionMaxScoreHint,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              errorText: _errorFor('max_score'),
              onChanged: (_) => _onFieldChanged(),
            ),
          ], tokens),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.gradingCorrectionReasonHeader, tokens: tokens),
          LsTextField(
            label: l.gradingCorrectionReasonLabel,
            controller: _reasonController,
            maxLines: 3,
            hint: l.gradingCorrectionReasonHint,
            errorText: _errorFor('reason'),
            onChanged: (_) => _onFieldChanged(),
          ),
          SizedBox(height: tokens.space.lg),
          if (_generalError != null)
            Container(
              padding: EdgeInsets.all(tokens.space.md),
              decoration: BoxDecoration(
                color: tokens.status.errorContainer,
                borderRadius: BorderRadius.circular(tokens.radius.md),
                border: Border.all(color: tokens.status.error),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline,
                      color: tokens.status.error, size: 18),
                  SizedBox(width: tokens.space.sm),
                  Expanded(
                    child: Text(
                      _generalError!,
                      style: tokens.typography.bodyMedium.copyWith(
                        color: tokens.status.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_generalError != null) SizedBox(height: tokens.space.md),
          LsButton.primary(
            label: _submitting
                ? l.gradingCorrectionSubmitLoading
                : l.gradingCorrectionSubmitAction,
            icon: Icons.check,
            isLoading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
          if (corrected != null) ...[
            SizedBox(height: tokens.space.lg),
            Container(
              padding: EdgeInsets.all(tokens.space.md),
              decoration: BoxDecoration(
                color: tokens.status.successContainer,
                borderRadius: BorderRadius.circular(tokens.radius.md),
                border: Border.all(color: tokens.status.success),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: tokens.status.success, size: 18),
                  SizedBox(width: tokens.space.sm),
                  Expanded(
                    child: Text(
                      corrected.gradeName.isEmpty
                          ? l.gradingCorrectionSuccessFallback
                          : l.gradingCorrectionSuccessLabel(
                              corrected.gradeName),
                      style: tokens.typography.bodyMedium.copyWith(
                        color: tokens.status.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldsColumnOrRow(List<Widget> fields, DesignTokens tokens) {
    if (_isWide && fields.length == 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: fields[0]),
          SizedBox(width: tokens.space.md),
          Expanded(child: fields[1]),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < fields.length; i++) ...[
          fields[i],
          if (i < fields.length - 1) SizedBox(height: tokens.space.md),
        ],
      ],
    );
  }

  String? _errorFor(String field) {
    final errors = _fieldErrors[field];
    if (errors == null || errors.isEmpty) return null;
    return errors.first;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title, {required this.tokens});
  final String title;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: tokens.space.xs),
      child: Text(
        title,
        style: tokens.typography.titleSmall.copyWith(
          color: tokens.text.secondary,
        ),
      ),
    );
  }
}
