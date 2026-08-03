import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../../people/data/person_failure.dart';
import '../data/staff_providers.dart';
import '../data/staff_repository.dart';

import '../../../ui/app_theme.dart';

class StaffDetailScreen extends ConsumerWidget {
  const StaffDetailScreen({required this.staffId, super.key});

  final String staffId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
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
          l.staffDetailScreenTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
      ),
      body: asyncProfile.when(
        data: (result) => switch (result) {
          Ok(:final value) => _buildBody(context, value, tokens, l),
          Err(:final error) => LsStateView.error(
              icon: Icons.error_outline,
              title: l.staffDetailErrorTitle,
              message: error.message,
              action: LsButton.primary(
                label: l.commonTryAgain,
                expand: false,
                onPressed: () => ref.invalidate(staffProfileProvider(staffId)),
              ),
            ),
        },
        loading: () => LsStateView.loading(title: l.staffDetailLoadingTitle),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: l.staffDetailErrorTitle,
          message: err.toString(),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    StaffProfile profile,
    DesignTokens tokens,
    AppLocalizations l,
  ) {
    final m = profile.member;
    return ListView(
      padding: EdgeInsets.all(tokens.space.md),
      children: [
        _IdentityCard(member: m, tokens: tokens),
        SizedBox(height: tokens.space.md),
        _SectionHeader(title: l.staffDetailRoleBranchHeader, tokens: tokens),
        _KeyValueCard(
          entries: [
            _Entry(l.staffDetailRoleLabel, m.staffRole),
            _Entry(l.staffDetailBranchLabel, m.branch),
            _Entry(l.staffDetailStatusLabel, m.status),
            _Entry(l.staffDetailDateOfJoiningLabel, m.dateOfJoining),
            _Entry(l.staffDetailUserAccountLabel, m.user),
          ],
          tokens: tokens,
        ),
        SizedBox(height: tokens.space.md),
        _SectionHeader(title: l.staffDetailIdentityHeader, tokens: tokens),
        _KeyValueCard(
          entries: [
            _Entry(l.staffDetailGenderLabel, m.gender),
            _Entry(l.staffDetailNationalityLabel, m.nationality),
            _Entry(l.staffDetailCountryLabel, m.country),
            _Entry(l.staffDetailErpnextEmployeeLabel, m.erpnextEmployee),
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
    final fullName =
        (member.fullName as String).isEmpty ? '—' : member.fullName as String;
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
    final l = AppLocalizations.of(context);
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
          l.staffDetailNoDataLabel,
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
            if (i > 0) Divider(height: 1, color: tokens.surface.outlineVariant),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
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
