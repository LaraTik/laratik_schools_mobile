import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_text_field.dart';
import '../data/academics_providers.dart';
import '../data/academics_repository.dart';

import '../../../ui/app_theme.dart';

class SubjectCreateScreen extends ConsumerStatefulWidget {
  const SubjectCreateScreen({super.key});

  @override
  ConsumerState<SubjectCreateScreen> createState() =>
      _SubjectCreateScreenState();
}

class _SubjectCreateScreenState extends ConsumerState<SubjectCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _departmentController;
  late final TextEditingController _gradeLevelController;
  late final TextEditingController _creditHoursController;
  late final TextEditingController _descriptionController;
  bool _submitting = false;
  String? _generalError;
  bool _isWide = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    _departmentController = TextEditingController();
    _gradeLevelController = TextEditingController();
    _creditHoursController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _departmentController.dispose();
    _gradeLevelController.dispose();
    _creditHoursController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _generalError = null;
    });
    final repo = ref.read(academicsRepositoryProvider);
    final creditHours = int.tryParse(_creditHoursController.text.trim());
    final result = await repo.createSubject(
      subjectName: _nameController.text.trim(),
      subjectCode: _codeController.text.trim().isEmpty
          ? null
          : _codeController.text.trim(),
      department: _departmentController.text.trim().isEmpty
          ? null
          : _departmentController.text.trim(),
      gradeLevel: _gradeLevelController.text.trim().isEmpty
          ? null
          : _gradeLevelController.text.trim(),
      creditHours: creditHours,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    switch (result) {
      case Ok(:final value):
        _showSuccess(value.subjectName);
      case Err(:final error):
        setState(() => _generalError = error.message);
    }
  }

  void _showSuccess(String name) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final tokens = sheetContext.laratik;
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
                      'Subject created',
                      style: tokens.typography.titleLarge.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.space.sm),
                Text(
                  name,
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.text.secondary,
                  ),
                ),
                SizedBox(height: tokens.space.lg),
                LsButton.primary(
                  label: 'Back to academics',
                  icon: Icons.arrow_back,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    context.go('/shell/academics');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    _isWide = MediaQuery.sizeOf(context).width >= 720;
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shell/academics'),
        ),
        title: Text(
          'New subject',
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(tokens.space.md),
          children: [
            LsTextField(
              label: 'Subject name',
              required: true,
              controller: _nameController,
              hint: 'Mathematics, Arabic, …',
              onChanged: (_) {},
            ),
            SizedBox(height: tokens.space.md),
            _buildFieldsColumnOrRow([
              LsTextField(
                label: 'Subject code',
                controller: _codeController,
                hint: 'MATH-101',
                onChanged: (_) {},
              ),
              LsTextField(
                label: 'Department',
                controller: _departmentController,
                hint: 'Sciences, Humanities, …',
                onChanged: (_) {},
              ),
            ], tokens),
            SizedBox(height: tokens.space.md),
            _buildFieldsColumnOrRow([
              LsTextField(
                label: 'Grade level',
                controller: _gradeLevelController,
                hint: 'Grade 3',
                onChanged: (_) {},
              ),
              LsTextField(
                label: 'Credit hours',
                controller: _creditHoursController,
                keyboardType: TextInputType.number,
                onChanged: (_) {},
              ),
            ], tokens),
            SizedBox(height: tokens.space.md),
            LsTextField(
              label: 'Description',
              controller: _descriptionController,
              maxLines: 4,
              onChanged: (_) {},
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
              label: _submitting ? 'Creating…' : 'Create subject',
              icon: Icons.check,
              isLoading: _submitting,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
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
}
