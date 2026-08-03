// SPDX-License-Identifier: Proprietary
// Student create form.
//
// Loads the setup context once for schema + defaults, then renders a
// two-column form (stacks to one column under 720dp). On submit the
// form hands a [StudentFormPayload] to the repository; the
// §1.3 country flags surface on the success card so the operator can
// confirm before navigating to the detail screen.
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)] — AppBar title, form section
// labels, field hints + required error copy, the success modal's
// "Student created" header + "Create another" / "Open record"
// actions, the country-warning chips, and the loading / error
// states. RTL mirrors the input row layout.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../../../ui/widgets/ls_text_field.dart';
import '../data/person_providers.dart';
import '../data/person_repository.dart';
import '../data/student_form_payload.dart';

import '../../../ui/app_theme.dart';

class StudentCreateScreen extends ConsumerStatefulWidget {
  const StudentCreateScreen({super.key});

  @override
  ConsumerState<StudentCreateScreen> createState() =>
      _StudentCreateScreenState();
}

class _StudentCreateScreenState extends ConsumerState<StudentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _guardianController;
  late final TextEditingController _guardianPhoneController;
  late final TextEditingController _nationalityController;
  late final TextEditingController _countryController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _gradeController;
  late final TextEditingController _notesController;
  StudentFormPayload _payload = const StudentFormPayload(
    firstName: '',
    lastName: '',
  );
  bool _submitting = false;
  String? _generalError;
  Map<String, List<String>> _fieldErrors = const {};
  bool _isWide = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _guardianController = TextEditingController();
    _guardianPhoneController = TextEditingController();
    _nationalityController = TextEditingController();
    _countryController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _gradeController = TextEditingController();
    _notesController = TextEditingController();
    for (final c in [
      _firstNameController,
      _lastNameController,
      _guardianController,
      _guardianPhoneController,
      _nationalityController,
      _countryController,
      _dateOfBirthController,
      _gradeController,
      _notesController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _firstNameController,
      _lastNameController,
      _guardianController,
      _guardianPhoneController,
      _nationalityController,
      _countryController,
      _dateOfBirthController,
      _gradeController,
      _notesController,
    ]) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {
      _payload = _payload.copyWith(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        guardian: _guardianController.text,
        guardianPhone: _guardianPhoneController.text,
        nationality: _nationalityController.text,
        country: _countryController.text,
        dateOfBirth: _dateOfBirthController.text,
        grade: _gradeController.text,
        notes: _notesController.text,
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
    final repo = ref.read(personRepositoryProvider);
    final result = await repo.createStudent(_payload);
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

  void _showSuccessCard(PersonCreationResult result) {
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
                    Icon(
                      Icons.check_circle,
                      color: tokens.status.success,
                    ),
                    SizedBox(width: tokens.space.sm),
                    Text(
                      l.studentCreateSuccessTitle,
                      style: tokens.typography.titleLarge.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.space.sm),
                Text(
                  result.studentName.isEmpty
                      ? l.studentCreateSuccessFallback
                      : result.studentName,
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.text.secondary,
                  ),
                ),
                SizedBox(height: tokens.space.sm),
                Wrap(
                  spacing: tokens.space.xs,
                  runSpacing: tokens.space.xs,
                  children: [
                    if (result.countryWasDefaulted)
                      LsStatusChip(
                        label: l.studentCreateCountryDefaultedChip,
                        icon: Icons.info_outline,
                        tone: LsChipTone.warning,
                      ),
                    if (result.residentialCountryMismatch)
                      LsStatusChip(
                        label: l.studentCreateCountryMismatchChip,
                        icon: Icons.swap_horiz,
                        tone: LsChipTone.warning,
                      ),
                    if (result.warnings.isNotEmpty)
                      LsStatusChip(
                        label: l.studentCreateWarningsChip(
                          result.warnings.length,
                        ),
                        icon: Icons.priority_high,
                        tone: LsChipTone.info,
                      ),
                  ],
                ),
                SizedBox(height: tokens.space.lg),
                Row(
                  children: [
                    Expanded(
                      child: LsButton.secondary(
                        label: l.studentCreateAnotherAction,
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
                        label: l.studentCreateOpenRecordAction,
                        icon: Icons.arrow_forward,
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          context.go('/shell/students/${result.schoolStudent}');
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
    _firstNameController.clear();
    _lastNameController.clear();
    _guardianController.clear();
    _guardianPhoneController.clear();
    _nationalityController.clear();
    _countryController.clear();
    _dateOfBirthController.clear();
    _gradeController.clear();
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    _isWide = MediaQuery.sizeOf(context).width >= 720;

    final asyncContext = ref.watch(studentSetupContextProvider(null));
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shell/students'),
        ),
        title: Text(
          l.studentCreateScreenTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
      ),
      body: asyncContext.when(
        data: (result) => switch (result) {
          Ok(:final value) => _buildForm(value, tokens),
          Err(:final error) => LsStateView.error(
              icon: Icons.error_outline,
              title: l.studentCreateSchemaErrorTitle,
              message: error.message,
              action: LsButton.primary(
                label: l.commonTryAgain,
                expand: false,
                onPressed: () =>
                    ref.invalidate(studentSetupContextProvider(null)),
              ),
            ),
        },
        loading: () => LsStateView.loading(
          title: l.studentCreateLoadingTitle,
          message: l.studentCreateLoadingMessage,
        ),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: l.studentCreateSchemaErrorTitle,
          message: err.toString(),
        ),
      ),
    );
  }

  Widget _buildForm(JsonMap setupContext, DesignTokens tokens) {
    final l = AppLocalizations.of(context);
    final defaults = setupContext['defaults'] is JsonMap
        ? setupContext['defaults'] as JsonMap
        : const <String, Object?>{};
    final requiredRoles =
        (setupContext['required_roles'] as List?)?.cast<String>() ??
            const <String>[];

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          if (requiredRoles.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.space.md),
              child: LsStatusChip(
                label: l.studentCreateRequiredRolesChip(
                  requiredRoles.join(', '),
                ),
                icon: Icons.lock_outline,
                tone: LsChipTone.info,
              ),
            ),
          _SectionLabel(l.studentCreateIdentityHeader, tokens: tokens),
          _buildFieldsColumnOrRow([
            LsTextField(
              label: l.studentCreateFirstNameLabel,
              required: true,
              controller: _firstNameController,
              hint: l.studentCreateFirstNameHint,
              errorText: _errorFor('first_name'),
              onChanged: (_) => _onFieldChanged(),
            ),
            LsTextField(
              label: l.studentCreateLastNameLabel,
              required: true,
              controller: _lastNameController,
              errorText: _errorFor('last_name'),
              onChanged: (_) => _onFieldChanged(),
            ),
          ], tokens),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.studentCreateDateOfBirthHeader, tokens: tokens),
          LsTextField(
            label: l.studentCreateDateOfBirthLabel,
            controller: _dateOfBirthController,
            hint: l.studentCreateDateOfBirthHint,
            errorText: _errorFor('date_of_birth'),
            onChanged: (_) => _onFieldChanged(),
          ),
          SizedBox(height: tokens.space.md),
          _SectionLabel(
            l.studentCreateCountryNationalityHeader,
            tokens: tokens,
          ),
          _buildFieldsColumnOrRow([
            LsTextField(
              label: l.studentCreateNationalityLabel,
              controller: _nationalityController,
              hint: l.studentCreateNationalityHint,
              errorText: _errorFor('nationality'),
              onChanged: (_) => _onFieldChanged(),
            ),
            LsTextField(
              label: l.studentCreateCountryLabel,
              controller: _countryController,
              hint: l.studentCreateCountryHint,
              errorText: _errorFor('country'),
              onChanged: (_) => _onFieldChanged(),
            ),
          ], tokens),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.studentCreateGuardianHeader, tokens: tokens),
          _buildFieldsColumnOrRow([
            LsTextField(
              label: l.studentCreateGuardianNameLabel,
              required: true,
              controller: _guardianController,
              hint: defaults['guardian']?.toString() ?? '',
              errorText: _errorFor('guardian'),
              onChanged: (_) => _onFieldChanged(),
            ),
            LsTextField(
              label: l.studentCreateGuardianPhoneLabel,
              controller: _guardianPhoneController,
              keyboardType: TextInputType.phone,
              errorText: _errorFor('guardian_phone'),
              onChanged: (_) => _onFieldChanged(),
            ),
          ], tokens),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.studentCreateEnrollmentHeader, tokens: tokens),
          LsTextField(
            label: l.studentCreateGradeLabel,
            controller: _gradeController,
            hint: defaults['grade']?.toString() ?? l.studentCreateGradeHint,
            errorText: _errorFor('grade'),
            onChanged: (_) => _onFieldChanged(),
          ),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.studentCreateNotesHeader, tokens: tokens),
          LsTextField(
            label: l.studentCreateNotesLabel,
            controller: _notesController,
            maxLines: 4,
            errorText: _errorFor('notes'),
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
                  Icon(
                    Icons.error_outline,
                    color: tokens.status.error,
                    size: 18,
                  ),
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
                ? l.studentCreateSubmitLoading
                : l.studentCreateSubmitAction,
            icon: Icons.check,
            isLoading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsColumnOrRow(
    List<Widget> fields,
    DesignTokens tokens,
  ) {
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
      padding: EdgeInsets.only(bottom: tokens.space.xs),
      child: Text(
        title,
        style: tokens.typography.titleSmall.copyWith(
          color: tokens.text.secondary,
        ),
      ),
    );
  }
}
