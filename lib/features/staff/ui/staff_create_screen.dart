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
import '../data/staff_form_payload.dart';
import '../data/staff_providers.dart';
import '../data/staff_repository.dart';

import '../../../ui/app_theme.dart';

class StaffCreateScreen extends ConsumerStatefulWidget {
  const StaffCreateScreen({super.key});

  @override
  ConsumerState<StaffCreateScreen> createState() => _StaffCreateScreenState();
}

class _StaffCreateScreenState extends ConsumerState<StaffCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _roleController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nationalityController;
  late final TextEditingController _countryController;
  late final TextEditingController _dateOfJoiningController;
  late final TextEditingController _notesController;
  StaffFormPayload _payload = const StaffFormPayload(
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
    _roleController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _nationalityController = TextEditingController();
    _countryController = TextEditingController();
    _dateOfJoiningController = TextEditingController();
    _notesController = TextEditingController();
    for (final c in [
      _firstNameController,
      _lastNameController,
      _roleController,
      _emailController,
      _phoneController,
      _nationalityController,
      _countryController,
      _dateOfJoiningController,
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
      _roleController,
      _emailController,
      _phoneController,
      _nationalityController,
      _countryController,
      _dateOfJoiningController,
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
        staffRole: _roleController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        nationality: _nationalityController.text,
        country: _countryController.text,
        dateOfJoining: _dateOfJoiningController.text,
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
    final repo = ref.read(staffRepositoryProvider);
    final result = await repo.createStaff(_payload);
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

  void _showSuccessCard(StaffCreationResult result) {
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
                      l.staffCreateSuccessTitle,
                      style: tokens.typography.titleLarge.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.space.sm),
                Text(
                  result.staffName.isEmpty
                      ? l.staffCreateSuccessFallback
                      : result.staffName,
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.text.secondary,
                  ),
                ),
                SizedBox(height: tokens.space.sm),
                if (result.erpnextEmployee != null &&
                    result.erpnextEmployee!.isNotEmpty)
                  LsStatusChip(
                    label: l.staffCreateEmployeeChip(result.erpnextEmployee!),
                    icon: Icons.badge_outlined,
                    tone: LsChipTone.info,
                  ),
                SizedBox(height: tokens.space.lg),
                Row(
                  children: [
                    Expanded(
                      child: LsButton.secondary(
                        label: l.staffCreateAnotherAction,
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
                        label: l.staffCreateOpenRecordAction,
                        icon: Icons.arrow_forward,
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          context.go('/shell/staff/${result.schoolStaff}');
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
    _roleController.clear();
    _emailController.clear();
    _phoneController.clear();
    _nationalityController.clear();
    _countryController.clear();
    _dateOfJoiningController.clear();
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    _isWide = MediaQuery.sizeOf(context).width >= 720;
    final asyncContext = ref.watch(staffSetupContextProvider(null));
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          tooltip: l.commonBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shell/staff'),
        ),
        title: Text(
          l.staffCreateScreenTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
      ),
      body: asyncContext.when(
        data: (result) => switch (result) {
          Ok(:final value) => _buildForm(value, tokens, l),
          Err(:final error) => LsStateView.error(
              icon: Icons.error_outline,
              title: l.staffCreateErrorTitle,
              message: error.message,
              action: LsButton.primary(
                label: l.commonTryAgain,
                expand: false,
                onPressed: () =>
                    ref.invalidate(staffSetupContextProvider(null)),
              ),
            ),
        },
        loading: () => LsStateView.loading(
          title: l.staffCreateLoadingTitle,
          message: l.staffCreateLoadingMessage,
        ),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: l.staffCreateErrorTitle,
          message: err.toString(),
        ),
      ),
    );
  }

  Widget _buildForm(
    JsonMap setupContext,
    DesignTokens tokens,
    AppLocalizations l,
  ) {
    final defaults = setupContext['defaults'] is JsonMap
        ? setupContext['defaults'] as JsonMap
        : const <String, Object?>{};
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          _SectionLabel(l.staffCreateIdentityHeader, tokens: tokens),
          _buildFieldsColumnOrRow([
            LsTextField(
              label: l.staffCreateFirstNameLabel,
              required: true,
              controller: _firstNameController,
              errorText: _errorFor('first_name'),
              onChanged: (_) => _onFieldChanged(),
            ),
            LsTextField(
              label: l.staffCreateLastNameLabel,
              required: true,
              controller: _lastNameController,
              errorText: _errorFor('last_name'),
              onChanged: (_) => _onFieldChanged(),
            ),
          ], tokens),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.staffCreateRoleHeader, tokens: tokens),
          LsTextField(
            label: l.staffCreateRoleLabel,
            required: true,
            controller: _roleController,
            hint: defaults['staff_role']?.toString() ?? l.staffCreateRoleHint,
            errorText: _errorFor('staff_role'),
            onChanged: (_) => _onFieldChanged(),
          ),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.staffCreateContactHeader, tokens: tokens),
          _buildFieldsColumnOrRow([
            LsTextField(
              label: l.staffCreateEmailLabel,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              errorText: _errorFor('email'),
              onChanged: (_) => _onFieldChanged(),
            ),
            LsTextField(
              label: l.staffCreatePhoneLabel,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              errorText: _errorFor('phone'),
              onChanged: (_) => _onFieldChanged(),
            ),
          ], tokens),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.staffCreateCountryHeader, tokens: tokens),
          _buildFieldsColumnOrRow([
            LsTextField(
              label: l.staffCreateNationalityLabel,
              controller: _nationalityController,
              errorText: _errorFor('nationality'),
              onChanged: (_) => _onFieldChanged(),
            ),
            LsTextField(
              label: l.staffCreateCountryLabel,
              controller: _countryController,
              errorText: _errorFor('country'),
              onChanged: (_) => _onFieldChanged(),
            ),
          ], tokens),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.staffCreateDateHeader, tokens: tokens),
          LsTextField(
            label: l.staffCreateDateOfJoiningLabel,
            controller: _dateOfJoiningController,
            hint: l.staffCreateDateOfJoiningHint,
            errorText: _errorFor('date_of_joining'),
            onChanged: (_) => _onFieldChanged(),
          ),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.staffCreateNotesHeader, tokens: tokens),
          LsTextField(
            label: l.staffCreateNotesLabel,
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
                ? l.staffCreateSubmitLoading
                : l.staffCreateSubmitAction,
            icon: Icons.check,
            isLoading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
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
