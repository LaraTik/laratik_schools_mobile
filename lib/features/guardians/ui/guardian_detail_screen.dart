import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../../../core/result.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../../people/data/person_failure.dart';
import '../data/guardian_providers.dart';

class GuardianDetailScreen extends ConsumerWidget {
  const GuardianDetailScreen({required this.guardianId, super.key});

  final String guardianId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    final asyncProfile = ref.watch(guardianProfileProvider(guardianId));

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
          'Guardian',
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
              title: 'Could not load guardian',
              message: error.message,
              action: LsButton.primary(
                label: 'Try again',
                expand: false,
                onPressed: () =>
                    ref.invalidate(guardianProfileProvider(guardianId)),
              ),
            ),
        },
        loading: () => const LsStateView.loading(title: 'Loading guardian'),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: 'Could not load guardian',
          message: err.toString(),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    GuardianProfile profile,
    DesignTokens tokens,
  ) {
    final g = profile.guardian;
    final linked = g.linkedStudentNames;
    return ListView(
      padding: EdgeInsets.all(tokens.space.md),
      children: [
        _IdentityCard(profile: profile, tokens: tokens),
        SizedBox(height: tokens.space.md),
        if (linked.isNotEmpty) ...[
          _SectionHeader(title: 'Linked students', tokens: tokens),
          _LinkedStudentsList(students: g.linkedStudents, tokens: tokens),
          SizedBox(height: tokens.space.md),
        ],
        _SectionHeader(title: 'Contact', tokens: tokens),
        _KeyValueCard(
          entries: [
            _Entry('Phone', g.phone),
            _Entry('Email', g.email),
            _Entry('Occupation', g.occupation),
          ],
          tokens: tokens,
        ),
        SizedBox(height: tokens.space.md),
        _SectionHeader(title: 'Address', tokens: tokens),
        _KeyValueCard(
          entries: [
            _Entry('Address line 1', g.addressLine1),
            _Entry('Address line 2', g.addressLine2),
            _Entry('City', g.city),
            _Entry('Postal code', g.postalCode),
            _Entry('Country', g.country),
            _Entry('Nationality', g.nationality),
          ],
          tokens: tokens,
        ),
      ],
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile, required this.tokens});
  final GuardianProfile profile;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    final g = profile.guardian;
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
            child: Icon(
              Icons.shield_outlined,
              size: 24,
              color: tokens.brand.onPrimaryContainer,
            ),
          ),
          SizedBox(width: tokens.space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  g.guardianName.isEmpty ? '—' : g.guardianName,
                  style: tokens.typography.titleLarge.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
                SizedBox(height: tokens.space.xxs),
                Text(
                  '#${g.id.isEmpty ? '—' : g.id}',
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.text.tertiary,
                    fontFamily: tokens.typography.monoFamily,
                  ),
                ),
                SizedBox(height: tokens.space.xs),
                Wrap(
                  spacing: tokens.space.xs,
                  runSpacing: tokens.space.xs,
                  children: [
                    LsStatusChip(
                      label: g.status,
                      tone: g.isActive ? LsChipTone.success : LsChipTone.neutral,
                    ),
                    if (g.relation != null && g.relation!.isNotEmpty)
                      LsStatusChip(
                        label: g.relation!,
                        icon: Icons.family_restroom,
                        tone: LsChipTone.brand,
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
}

class _LinkedStudentsList extends StatelessWidget {
  const _LinkedStudentsList({required this.students, required this.tokens});
  final List<JsonMap> students;
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
          for (var i = 0; i < students.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: tokens.surface.outlineVariant),
            _LinkedStudentRow(student: students[i], tokens: tokens),
          ],
        ],
      ),
    );
  }
}

class _LinkedStudentRow extends StatelessWidget {
  const _LinkedStudentRow({required this.student, required this.tokens});
  final JsonMap student;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    final name = (student['student_name'] ?? student['name'] ?? '—').toString();
    final relation = (student['relation'] ?? '').toString();
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.space.md,
        vertical: tokens.space.xxs,
      ),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: tokens.brand.primaryContainer,
        child: Icon(
          Icons.school_outlined,
          color: tokens.brand.onPrimaryContainer,
          size: 16,
        ),
      ),
      title: Text(
        name,
        style: tokens.typography.titleSmall.copyWith(
          color: tokens.text.primary,
        ),
      ),
      subtitle: relation.isEmpty
          ? null
          : Text(
              relation,
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.text.secondary,
              ),
            ),
      trailing: Icon(
        Icons.chevron_right,
        color: tokens.text.tertiary,
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
  const _KeyValueCard({required this.entries, required this.tokens});
  final List<_Entry> entries;
  final DesignTokens tokens;

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
          'No data on file.',
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
              Divider(height: 1, color: tokens.surface.outlineVariant),
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
