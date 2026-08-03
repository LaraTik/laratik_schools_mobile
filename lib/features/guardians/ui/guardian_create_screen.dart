import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_text_field.dart';
import '../data/guardian_form_payload.dart';
import '../data/guardian_providers.dart';
import '../data/guardian_repository.dart';

import '../../../ui/app_theme.dart';

class GuardianCreateScreen extends ConsumerStatefulWidget {
  const GuardianCreateScreen({super.key});

  @override
  ConsumerState<GuardianCreateScreen> createState() =>
      _GuardianCreateScreenState();
}

class _GuardianCreateScreenState extends ConsumerState<GuardianCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _relationController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _occupationController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _nationalityController;
  GuardianFormPayload _payload = const GuardianFormPayload(guardianName: '');
  bool _submitting = false;
  String? _generalError;
  Map<String, List<String>> _fieldErrors = const {};
  bool _isWide = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _relationController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _occupationController = TextEditingController();
    _addressLine1Controller = TextEditingController();
    _addressLine2Controller = TextEditingController();
    _cityController = TextEditingController();
    _postalCodeController = TextEditingController();
    _countryController = TextEditingController();
    _nationalityController = TextEditingController();
    for (final c in [
      _nameController,
      _relationController,
      _phoneController,
      _emailController,
      _occupationController,
      _addressLine1Controller,
      _addressLine2Controller,
      _cityController,
      _postalCodeController,
      _countryController,
      _nationalityController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _relationController,
      _phoneController,
      _emailController,
      _occupationController,
      _addressLine1Controller,
      _addressLine2Controller,
      _cityController,
      _postalCodeController,
      _countryController,
      _nationalityController,
    ]) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {
      _payload = _payload.copyWith(
        guardianName: _nameController.text,
        relation: _relationController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        occupation: _occupationController.text,
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text,
        city: _cityController.text,
        postalCode: _postalCodeController.text,
        country: _countryController.text,
        nationality: _nationalityController.text,
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
    final repo = ref.read(guardianRepositoryProvider);
    final result = await repo.createGuardian(_payload);
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

  void _showSuccessCard(GuardianCreationResult result) {
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
                      l.guardianCreateSuccessTitle,
                      style: tokens.typography.titleLarge.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.space.sm),
                Text(
                  result.guardianName.isEmpty
                      ? l.guardianCreateSuccessFallback
                      : result.guardianName,
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.text.secondary,
                  ),
                ),
                SizedBox(height: tokens.space.lg),
                Row(
                  children: [
                    Expanded(
                      child: LsButton.secondary(
                        label: l.guardianCreateAnotherAction,
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
                        label: l.guardianCreateOpenRecordAction,
                        icon: Icons.arrow_forward,
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          context
                              .go('/shell/guardians/${result.schoolGuardian}');
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
    _nameController.clear();
    _relationController.clear();
    _phoneController.clear();
    _emailController.clear();
    _occupationController.clear();
    _addressLine1Controller.clear();
    _addressLine2Controller.clear();
    _cityController.clear();
    _postalCodeController.clear();
    _countryController.clear();
    _nationalityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    _isWide = MediaQuery.sizeOf(context).width >= 720;
    final asyncContext = ref.watch(guardianSetupContextProvider(null));
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shell/guardians'),
        ),
        title: Text(
          l.guardianCreateScreenTitle,
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
              title: l.guardianCreateErrorTitle,
              message: error.message,
              action: LsButton.primary(
                label: l.commonTryAgain,
                expand: false,
                onPressed: () =>
                    ref.invalidate(guardianSetupContextProvider(null)),
              ),
            ),
        },
        loading: () => LsStateView.loading(
          title: l.guardianCreateLoadingTitle,
          message: l.guardianCreateLoadingMessage,
        ),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: l.guardianCreateErrorTitle,
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
          _SectionLabel(l.guardianCreateIdentityHeader, tokens: tokens),
          LsTextField(
            label: l.guardianCreateNameLabel,
            required: true,
            controller: _nameController,
            hint: defaults['guardian_name']?.toString() ?? '',
            errorText: _errorFor('guardian_name'),
            onChanged: (_) => _onFieldChanged(),
          ),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.guardianCreateRelationHeader, tokens: tokens),
          LsTextField(
            label: l.guardianCreateRelationLabel,
            controller: _relationController,
            hint: l.guardianCreateRelationHint,
            errorText: _errorFor('relation'),
            onChanged: (_) => _onFieldChanged(),
          ),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.guardianCreateContactHeader, tokens: tokens),
          _buildFieldsColumnOrRow([
            LsTextField(
              label: l.guardianCreatePhoneLabel,
              required: true,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              errorText: _errorFor('phone'),
              onChanged: (_) => _onFieldChanged(),
            ),
            LsTextField(
              label: l.guardianCreateEmailLabel,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              errorText: _errorFor('email'),
              onChanged: (_) => _onFieldChanged(),
            ),
          ], tokens),
          SizedBox(height: tokens.space.md),
          LsTextField(
            label: l.guardianCreateOccupationLabel,
            controller: _occupationController,
            errorText: _errorFor('occupation'),
            onChanged: (_) => _onFieldChanged(),
          ),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.guardianCreateAddressHeader, tokens: tokens),
          LsTextField(
            label: l.guardianCreateAddressLine1Label,
            controller: _addressLine1Controller,
            errorText: _errorFor('address_line_1'),
            onChanged: (_) => _onFieldChanged(),
          ),
          SizedBox(height: tokens.space.md),
          LsTextField(
            label: l.guardianCreateAddressLine2Label,
            controller: _addressLine2Controller,
            errorText: _errorFor('address_line_2'),
            onChanged: (_) => _onFieldChanged(),
          ),
          SizedBox(height: tokens.space.md),
          _buildFieldsColumnOrRow([
            LsTextField(
              label: l.guardianCreateCityLabel,
              controller: _cityController,
              errorText: _errorFor('city'),
              onChanged: (_) => _onFieldChanged(),
            ),
            LsTextField(
              label: l.guardianCreatePostalCodeLabel,
              controller: _postalCodeController,
              errorText: _errorFor('postal_code'),
              onChanged: (_) => _onFieldChanged(),
            ),
          ], tokens),
          SizedBox(height: tokens.space.md),
          _buildFieldsColumnOrRow([
            LsTextField(
              label: l.guardianCreateNationalityLabel,
              controller: _nationalityController,
              errorText: _errorFor('nationality'),
              onChanged: (_) => _onFieldChanged(),
            ),
            LsTextField(
              label: l.guardianCreateCountryLabel,
              controller: _countryController,
              errorText: _errorFor('country'),
              onChanged: (_) => _onFieldChanged(),
            ),
          ], tokens),
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
                ? l.guardianCreateSubmitLoading
                : l.guardianCreateSubmitAction,
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
