// SPDX-License-Identifier: Proprietary
// Student detail. Renders the four sections the v1 profile response
// already returns: identity, current enrollment, attendance, and
// guardians. The §1.3 country warnings surface as visible chips; the
// country/nationality pair is shown side-by-side.
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)]; the section headers + entry
// labels + warning copy + error / loading / empty titles all
// resolve through the ARB-driven localizer. RTL mirrors the
// `TextDirection` per row.

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
import '../data/person.dart';
import '../data/person_providers.dart';
import '../data/person_repository.dart';

import '../../../ui/app_theme.dart';

class StudentDetailScreen extends ConsumerWidget {
  const StudentDetailScreen({required this.studentId, super.key});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final asyncProfile = ref.watch(studentProfileProvider(studentId));

    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          tooltip: l.commonBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shell/students'),
        ),
        title: Text(
          l.studentDetailScreenTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
      ),
      body: asyncProfile.when(
        data: (result) => switch (result) {
          Ok(:final value) => _buildBody(context, value, tokens),
          Err(:final error) => LsStateView.error(
              icon: Icons.error_outline,
              title: l.studentDetailErrorTitle,
              message: error.message,
              action: LsButton.primary(
                label: l.commonTryAgain,
                expand: false,
                onPressed: () =>
                    ref.invalidate(studentProfileProvider(studentId)),
              ),
            ),
        },
        loading: () => LsStateView.loading(
          title: l.studentDetailLoadingTitle,
        ),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: l.studentDetailErrorTitle,
          message: err.toString(),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PersonProfile profile,
    DesignTokens tokens,
  ) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.all(tokens.space.md),
      children: [
        _IdentityCard(person: profile.person, tokens: tokens),
        SizedBox(height: tokens.space.md),
        if (profile.person.hasCountryWarning)
          _CountryWarningCard(person: profile.person, tokens: tokens),
        _SectionHeader(
          title: l.studentDetailEnrollmentHeader,
          tokens: tokens,
        ),
        _KeyValueCard(
          entries: [
            _Entry(l.studentDetailGradeLabel, profile.person.grade),
            _Entry(
              l.studentDetailClassGroupLabel,
              profile.person.classGroup,
            ),
            _Entry(
              l.studentDetailAcademicYearLabel,
              profile.person.academicYear,
            ),
            _Entry(l.studentDetailStatusLabel, profile.person.status),
            _Entry(
              l.studentDetailEnrollmentStatusLabel,
              profile.person.enrollmentStatus,
            ),
            _Entry(
              l.studentDetailActivationLabel,
              profile.person.activationStatus,
            ),
          ],
          emptyLabel: l.studentDetailNoDataLabel,
          tokens: tokens,
        ),
        SizedBox(height: tokens.space.md),
        _SectionHeader(
          title: l.studentDetailIdentityHeader,
          tokens: tokens,
        ),
        _KeyValueCard(
          entries: [
            _Entry(
              l.studentDetailNationalityLabel,
              profile.person.nationality,
            ),
            _Entry(l.studentDetailCountryLabel, profile.person.country),
            _Entry(
              l.studentDetailErpnextCustomerLabel,
              profile.person.erpnextCustomer,
            ),
          ],
          emptyLabel: l.studentDetailNoDataLabel,
          tokens: tokens,
        ),
        SizedBox(height: tokens.space.md),
        if (profile.guardians.isNotEmpty) ...[
          _SectionHeader(
            title: l.studentDetailGuardiansHeader,
            tokens: tokens,
          ),
          _GuardianList(guardians: profile.guardians, tokens: tokens),
          SizedBox(height: tokens.space.md),
        ],
        if (profile.gradeRecords.isNotEmpty) ...[
          _SectionHeader(
            title: l.studentDetailRecentGradesHeader,
            tokens: tokens,
          ),
          _GradeList(records: profile.gradeRecords, tokens: tokens),
        ],
        SizedBox(height: tokens.space.lg),
      ],
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.person, required this.tokens});

  final Person person;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: tokens.brand.primaryContainer,
            child: Text(
              _initials(person.fullName),
              style: tokens.typography.titleMedium.copyWith(
                color: tokens.brand.onPrimaryContainer,
              ),
            ),
          ),
          SizedBox(width: tokens.space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.fullName.isEmpty ? '—' : person.fullName,
                  style: tokens.typography.titleLarge.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
                SizedBox(height: tokens.space.xxs),
                Text(
                  '#${person.id.isEmpty ? '—' : person.id}',
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.text.tertiary,
                    fontFamily: tokens.typography.monoFamily,
                  ),
                ),
                SizedBox(height: tokens.space.xs),
                Row(
                  children: [
                    LsStatusChip(
                      label: person.status,
                      tone: person.isActive
                          ? LsChipTone.success
                          : LsChipTone.neutral,
                    ),
                    SizedBox(width: tokens.space.xs),
                    if (person.hasGuardianWarning)
                      LsStatusChip(
                        label: l.studentDetailNoGuardianChip,
                        icon: Icons.warning_amber,
                        tone: LsChipTone.warning,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String fullName) {
    if (fullName.isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _CountryWarningCard extends StatelessWidget {
  const _CountryWarningCard({required this.person, required this.tokens});

  final Person person;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: tokens.space.md),
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.status.warningContainer,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.status.warning),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: tokens.status.warning,
                size: 18,
              ),
              SizedBox(width: tokens.space.xs),
              Text(
                l.studentDetailCountryWarningTitle,
                style: tokens.typography.titleSmall.copyWith(
                  color: tokens.status.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space.xs),
          if (person.countryWasDefaulted)
            Text(
              l.studentDetailCountryDefaultedMessage,
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.status.warning,
              ),
            ),
          if (person.residentialCountryMismatch)
            Text(
              l.studentDetailCountryMismatchMessage,
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.status.warning,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.tokens});
  final String title;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.space.sm),
      child: Text(
        title,
        style: tokens.typography.titleSmall.copyWith(
          color: tokens.text.secondary,
        ),
      ),
    );
  }
}

class _Entry {
  const _Entry(this.label, this.value);
  final String label;
  final String? value;
}

class _KeyValueCard extends StatelessWidget {
  const _KeyValueCard({
    required this.entries,
    required this.tokens,
    required this.emptyLabel,
  });
  final List<_Entry> entries;
  final DesignTokens tokens;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final visible = entries
        .where((e) => e.value != null && e.value!.isNotEmpty)
        .toList(growable: false);
    if (visible.isEmpty) {
      return Container(
        padding: EdgeInsets.all(tokens.space.md),
        decoration: BoxDecoration(
          color: tokens.surface.surface,
          borderRadius: BorderRadius.circular(tokens.radius.md),
          border: Border.all(color: tokens.surface.outlineVariant),
        ),
        child: Text(
          emptyLabel,
          style: tokens.typography.bodyMedium.copyWith(
            color: tokens.text.tertiary,
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: tokens.surface.outlineVariant,
              ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.space.md,
                vertical: tokens.space.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      visible[i].label,
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.text.secondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      visible[i].value!,
                      style: tokens.typography.bodyMedium.copyWith(
                        color: tokens.text.primary,
                      ),
                      textAlign: TextAlign.end,
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
}

class _GuardianList extends StatelessWidget {
  const _GuardianList({required this.guardians, required this.tokens});
  final List<JsonMap> guardians;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < guardians.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: tokens.surface.outlineVariant,
              ),
            _GuardianRow(guardian: guardians[i], tokens: tokens),
          ],
        ],
      ),
    );
  }
}

class _GuardianRow extends StatelessWidget {
  const _GuardianRow({required this.guardian, required this.tokens});
  final JsonMap guardian;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    final name = (guardian['guardian_name'] ?? '—').toString();
    final relation = (guardian['relation'] ?? '').toString();
    final phone = (guardian['phone'] ?? '').toString();
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.space.md,
        vertical: tokens.space.xxs,
      ),
      title: Text(
        name,
        style: tokens.typography.titleSmall.copyWith(
          color: tokens.text.primary,
        ),
      ),
      subtitle: Text(
        [
          if (relation.isNotEmpty) relation,
          if (phone.isNotEmpty) phone,
        ].join(' · '),
        style: tokens.typography.bodySmall.copyWith(
          color: tokens.text.secondary,
        ),
      ),
      trailing: Icon(
        // Chevron points the same way as the text flow in
        // both LTR + RTL. A raw Icon doesn't auto-mirror under
        // RTL like ListTile does, so we pick the right one per
        // direction.
        Directionality.of(context) == TextDirection.rtl
            ? Icons.chevron_left
            : Icons.chevron_right,
        color: tokens.text.tertiary,
      ),
    );
  }
}

class _GradeList extends StatelessWidget {
  const _GradeList({required this.records, required this.tokens});
  final List<JsonMap> records;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < records.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: tokens.surface.outlineVariant,
              ),
            _GradeRow(record: records[i], tokens: tokens),
          ],
        ],
      ),
    );
  }
}

class _GradeRow extends StatelessWidget {
  const _GradeRow({required this.record, required this.tokens});
  final JsonMap record;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    final subject = (record['subject'] ?? '—').toString();
    final term = (record['academic_term'] ?? record['term'] ?? '').toString();
    final score = (record['score'] ?? record['grade'] ?? '').toString();
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.space.md,
        vertical: tokens.space.xxs,
      ),
      title: Text(
        subject,
        style: tokens.typography.titleSmall.copyWith(
          color: tokens.text.primary,
        ),
      ),
      subtitle: term.isEmpty
          ? null
          : Text(
              term,
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.text.secondary,
              ),
            ),
      trailing: Text(
        score,
        style: tokens.typography.titleMedium.copyWith(
          color: tokens.brand.primary,
          fontFamily: tokens.typography.monoFamily,
        ),
      ),
    );
  }
}
