// SPDX-License-Identifier: Proprietary
// Privacy request submit form (parent / student surface).
//
// Reachable from the parent + student homes ("Submit a
// privacy request" tile) and from the family picker
// (per-child context). The v1 server requires
// `require_privacy_requester_access()` (parent or student
// role). The form submits via `submit_school_privacy_request`.
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)]; the per-field error
// chips + the success card use the same patterns as the
// student + staff + guardian create screens.
//
// The repository mints a fresh UUID for the
// `Idempotency-Key` header and a fresh `client_request_id`
// on the payload so a retry of the same submit is safe to
// send again. On success the privacy-list provider is
// invalidated so the admin's view of the school
// re-fetches the new row.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_text_field.dart';
import '../data/governance_failure.dart';
import '../data/governance_providers.dart';
import '../data/governance_request.dart';

import '../../../ui/app_theme.dart';

class PrivacyRequestSubmitScreen extends ConsumerStatefulWidget {
  const PrivacyRequestSubmitScreen({
    required this.requesterType,
    required this.subjectType,
    required this.subject,
    super.key,
  });

  /// "guardian" or "student". Defaults to "guardian" on
  /// the parent home; defaults to "student" on the student
  /// home.
  final String requesterType;

  /// "student" / "family" / "staff". Defaults to the
  /// current child for the parent; defaults to the
  /// active student for the student home.
  final String subjectType;

  /// The subject name / id (the student's name + id, the
  /// family's account id, etc.). The mobile passes this
  /// in from the home screen so the form doesn't ask the
  /// user to re-pick it.
  final String subject;

  @override
  ConsumerState<PrivacyRequestSubmitScreen> createState() =>
      _PrivacyRequestSubmitScreenState();
}

class _PrivacyRequestSubmitScreenState
    extends ConsumerState<PrivacyRequestSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _authorityController;
  late final TextEditingController _branchController;
  late final TextEditingController _noteController;
  String _requestType = 'access';
  final Set<String> _categories = <String>{'personal', 'attendance'};
  bool _submitting = false;
  bool _submitted = false;
  GovernanceFailure? _error;
  SubmittedPrivacyRequest? _result;

  @override
  void initState() {
    super.initState();
    _authorityController = TextEditingController();
    _branchController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _authorityController.dispose();
    _branchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await submitPrivacyRequest(
      ref,
      requestType: _requestType,
      requesterType: widget.requesterType,
      subjectType: widget.subjectType,
      subject: widget.subject,
      requestedCategories: _categories.toList(growable: false),
      schoolBranch: _branchController.text.trim(),
      authorityReference: _authorityController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _submitted = result is Ok;
      _result = result.isOk
          ? (result as Ok<SubmittedPrivacyRequest, GovernanceFailure>).value
          : null;
      _error = result.isErr
          ? (result as Err<SubmittedPrivacyRequest, GovernanceFailure>).error
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shell/governance'),
        ),
        title: Text(
          l.privacyRequestSubmitScreenTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
      ),
      body: _buildBody(tokens, l),
    );
  }

  Widget _buildBody(DesignTokens tokens, AppLocalizations l) {
    if (_submitted && _result != null) {
      return _buildSuccess(tokens, l);
    }
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          _SectionLabel(l.privacyRequestSubmitTypeHeader, tokens: tokens),
          _buildRequestTypeChips(tokens, l),
          SizedBox(height: tokens.space.md),
          _SectionLabel(
            l.privacyRequestSubmitCategoriesHeader,
            tokens: tokens,
          ),
          _buildCategoryChips(tokens, l),
          SizedBox(height: tokens.space.md),
          _SectionLabel(
            l.privacyRequestSubmitAuthorityHeader,
            tokens: tokens,
          ),
          LsTextField(
            label: l.privacyRequestSubmitAuthorityLabel,
            required: true,
            controller: _authorityController,
            hint: l.privacyRequestSubmitAuthorityHint,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l.privacyRequestSubmitAuthorityRequired;
              }
              return null;
            },
          ),
          SizedBox(height: tokens.space.md),
          _SectionLabel(
            l.privacyRequestSubmitBranchHeader,
            tokens: tokens,
          ),
          LsTextField(
            label: l.privacyRequestSubmitBranchLabel,
            required: true,
            controller: _branchController,
            hint: l.privacyRequestSubmitBranchHint,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l.privacyRequestSubmitBranchRequired;
              }
              return null;
            },
            onChanged: (_) {},
          ),
          SizedBox(height: tokens.space.md),
          _SectionLabel(
            l.privacyRequestSubmitNoteHeader,
            tokens: tokens,
          ),
          LsTextField(
            label: l.privacyRequestSubmitNoteLabel,
            controller: _noteController,
            maxLines: 3,
            hint: l.privacyRequestSubmitNoteHint,
            onChanged: (_) {},
          ),
          SizedBox(height: tokens.space.lg),
          if (_error != null)
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
                      _error!.message,
                      style: tokens.typography.bodyMedium.copyWith(
                        color: tokens.status.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_error != null) SizedBox(height: tokens.space.md),
          LsButton.primary(
            label: _submitting
                ? l.privacyRequestSubmitLoading
                : l.privacyRequestSubmitAction,
            icon: Icons.send,
            isLoading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
          SizedBox(height: tokens.space.lg),
          _SummaryCard(
            requesterType: widget.requesterType,
            subject: widget.subject,
            schoolBranch: _branchController.text,
            tokens: tokens,
            l: l,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(DesignTokens tokens, AppLocalizations l) {
    return Padding(
      padding: EdgeInsets.all(tokens.space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: tokens.status.success),
              SizedBox(width: tokens.space.sm),
              Text(
                l.privacyRequestSubmitSuccessTitle,
                style: tokens.typography.titleLarge.copyWith(
                  color: tokens.text.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space.sm),
          Text(
            _result!.hasName
                ? l.privacyRequestSubmitSuccessLabel(_result!.privacyRequest)
                : l.privacyRequestSubmitSuccessFallback,
            style: tokens.typography.bodyMedium.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.lg),
          LsButton.primary(
            label: l.privacyRequestSubmitBackAction,
            icon: Icons.arrow_forward,
            onPressed: () => context.go('/shell/governance'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTypeChips(DesignTokens tokens, AppLocalizations l) {
    final types = <String, String>{
      'access': l.privacyRequestTypeAccess,
      'rectification': l.privacyRequestTypeRectification,
      'erasure': l.privacyRequestTypeErasure,
      'consent_withdrawal': l.privacyRequestTypeConsentWithdrawal,
      'legal_hold': l.privacyRequestTypeLegalHold,
    };
    return Wrap(
      spacing: tokens.space.xs,
      runSpacing: tokens.space.xxs,
      children: [
        for (final entry in types.entries)
          ChoiceChip(
            label: Text(entry.value),
            selected: _requestType == entry.key,
            onSelected: (selected) {
              if (selected) {
                setState(() => _requestType = entry.key);
              }
            },
          ),
      ],
    );
  }

  Widget _buildCategoryChips(DesignTokens tokens, AppLocalizations l) {
    const categories = <String>[
      'personal',
      'attendance',
      'grades',
      'fees',
      'health',
      'communications',
    ];
    String labelFor(String key) {
      return switch (key) {
        'personal' => l.privacyRequestCategoryPersonal,
        'attendance' => l.privacyRequestCategoryAttendance,
        'grades' => l.privacyRequestCategoryGrades,
        'fees' => l.privacyRequestCategoryFees,
        'health' => l.privacyRequestCategoryHealth,
        'communications' => l.privacyRequestCategoryCommunications,
        _ => key,
      };
    }

    return Wrap(
      spacing: tokens.space.xs,
      runSpacing: tokens.space.xxs,
      children: [
        for (final category in categories)
          FilterChip(
            label: Text(labelFor(category)),
            selected: _categories.contains(category),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _categories.add(category);
                } else {
                  _categories.remove(category);
                }
              });
            },
          ),
      ],
    );
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.requesterType,
    required this.subject,
    required this.schoolBranch,
    required this.tokens,
    required this.l,
  });

  final String requesterType;
  final String subject;
  final String schoolBranch;
  final DesignTokens tokens;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface.surfaceContainerLow,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.privacyRequestSubmitSummaryHeader,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.xs),
          _row(l.privacyRequestSubmitSummaryRequester, requesterType),
          _row(l.privacyRequestSubmitSummarySubject, subject),
          _row(l.privacyRequestSubmitSummaryBranch, schoolBranch),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: tokens.space.xxs),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.text.tertiary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '—' : value,
              style: tokens.typography.bodyMedium.copyWith(
                color: tokens.text.primary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
