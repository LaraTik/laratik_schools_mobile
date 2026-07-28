import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../../people/data/person_failure.dart';
import '../data/staff_providers.dart';
import '../data/staff_repository.dart';

class StaffDetailScreen extends ConsumerWidget {
  const StaffDetailScreen({required this.staffId, super.key});

  final String staffId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    final asyncProfile = ref.watch(staffProfileProvider(staffId));

    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shell/staff'),
        ),
        title: Text(
          'Staff',
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
              title: 'Could not load staff',
              message: error.message,
              action: LsButton.primary(
                label: 'Try again',
                expand: false,
                onPressed: () =>
                    ref.invalidate(staffProfileProvider(staffId)),
              ),
            ),
        },
        loading: () => const LsStateView.loading(title: 'Loading staff'),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: 'Could not load staff',
          message: err.toString(),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    StaffProfile profile,
    DesignTokens tokens,
  ) {
    final m = profile.member;
    return ListView(
      padding: EdgeInsets.all(tokens.space.md),
      children: [
        _IdentityCard(member: m, tokens: tokens),
        SizedBox(height: tokens.space.md),
        _SectionHeader(title: 'Role & branch', tokens: tokens),
        _KeyValueCard(
          entries: [
            _Entry('Role', m.staffRole),
            _Entry('Branch', m.branch),
            _Entry('Status', m.status),
            _Entry('Date of joining', m.dateOfJoining),
            _Entry('User account', m.user),
          ],
          tokens: tokens,
        ),
        SizedBox(height: tokens.space.md),
        _SectionHeader(title: 'Identity & contact', tokens: tokens),
        _KeyValueCard(
          entries: [
            _Entry('Gender', m.gender),
            _Entry('Nationality', m.nationality),
            _Entry('Country', m.country),
            _Entry('ERPNext employee', m.erpnextEmployee),
          ],
          tokens: tokens,
        ),
      ],
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.member, required this.tokens});
  final dynamic member;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    final fullName = (member.fullName as String).isEmpty
        ? '—'
        : member.fullName as String;
    final id = member.id as String;
    final status = member.status as String;
    final role = member.staffRole as String?;
    final isActive = (member.isActive as bool);
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
            backgroundColor: tokens.brand.secondaryContainer,
            child: Text(
              _initials(fullName),
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
                  fullName,
                  style: tokens.typography.titleLarge.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
                SizedBox(height: tokens.space.xxs),
                Text(
                  '#${id.isEmpty ? '—' : id}',
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
                      label: status,
                      tone: isActive ? LsChipTone.success : LsChipTone.neutral,
                    ),
                    if (role != null && role.isNotEmpty)
                      LsStatusChip(
                        label: role,
                        icon: Icons.work_outline,
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
