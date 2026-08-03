// SPDX-License-Identifier: Proprietary
// Parent "My children" surface.
//
// Lists the de-duplicated children the current guardian is linked to,
// each row tappable into the per-child detail screen (Overview /
// Grades / Attendance / Report cards). The list reuses the
// [FamilyMember] rows already resolved by [FamilyRepository] — the
// same row also powers the parent home card count.
//
// UX:
//   * Each child row is a 48dp-tall minimum-tap target per the
//     Laratik UI rules.
//   * A "Withdrawn" / "Inactive" status chip fades the row so the
//     user knows the link is stale without hiding it entirely.
//   * Empty / loading / error / retry paths are all LsStateView-based
//     so the operator gets the same shape as every other list.
//   * Every user-facing string is locale-aware via
//     [AppLocalizations.of(context)]; the chevron mirrors itself
//     under RTL so the visual flow stays consistent with the text
//     direction.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../data/family_providers.dart';
import '../data/family_repository.dart';

/// Parent "My children" picker. Read-only surface; no per-row
/// context menu (the family is read-only on v1). The screen is
/// the parent role's primary home for the family surface and
/// also deep-linkable at `/shell/family`.
class FamilyHomeScreen extends ConsumerWidget {
  const FamilyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(familyListProvider);
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.homeParentMyChildren,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(familyListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: async.when(
        data: (page) => _buildBody(context, ref, tokens, page),
        loading: () => LsStateView.loading(
          title: l.familyHomeLoadingTitle,
          message: l.homeParentHeroLoadingMessage,
        ),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: l.familyHomeErrorTitle,
          message: err.toString(),
          action: LsButton.primary(
            label: l.commonTryAgain,
            expand: false,
            onPressed: () => ref.read(familyListProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DesignTokens tokens,
    FamilyPage page,
  ) {
    final l = AppLocalizations.of(context);
    if (page.members.isEmpty) {
      return RefreshIndicator(
        color: tokens.brand.primary,
        onRefresh: () => ref.read(familyListProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.5,
              child: LsStateView.empty(
                icon: Icons.family_restroom_outlined,
                title: l.homeParentNoChildrenTitle,
                message: l.homeParentNoChildrenMessage,
              ),
            ),
          ],
        ),
      );
    }
    // Active children first; the inactive tail is still rendered but
    // faded. Stable order inside each group by display name.
    final sorted = [...page.members]..sort((a, b) {
        if (a.isActive != b.isActive) {
          return a.isActive ? -1 : 1;
        }
        return a.studentName.toLowerCase().compareTo(
              b.studentName.toLowerCase(),
            );
      });
    return RefreshIndicator(
      color: tokens.brand.primary,
      onRefresh: () => ref.read(familyListProvider.notifier).refresh(),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          tokens.space.md,
          tokens.space.md,
          tokens.space.md,
          tokens.space.xl,
        ),
        itemCount: sorted.length + 1,
        separatorBuilder: (_, __) => SizedBox(height: tokens.space.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Header(
              tokens: tokens,
              total: page.members.length,
              active: page.members.where((m) => m.isActive).length,
            );
          }
          final child = sorted[index - 1];
          return _ChildCard(tokens: tokens, member: child);
        },
      ),
    );
  }
}

/// Page-level summary card so the parent doesn't have to count rows
/// to know "you have N children".
class _Header extends StatelessWidget {
  const _Header({
    required this.tokens,
    required this.total,
    required this.active,
  });
  final DesignTokens tokens;
  final int total;
  final int active;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final inactive = total - active;
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.family_restroom_outlined, color: tokens.brand.primary),
          SizedBox(width: tokens.space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.myChildrenHeaderTotal(total),
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
                SizedBox(height: tokens.space.xxs),
                Text(
                  inactive == 0
                      ? l.myChildrenHeaderAllActive
                      : l.myChildrenHeaderActive(active, inactive),
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.text.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One tappable row per linked child. Inactive rows render at a
/// reduced opacity so the user sees the relationship is stale
/// without losing access to historical records.
class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.tokens, required this.member});
  final DesignTokens tokens;
  final FamilyMember member;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final subtitle = _subtitle(context);
    final active = member.isActive;
    return Opacity(
      opacity: active ? 1.0 : 0.62,
      child: Material(
        color: tokens.surface.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.md),
          side: BorderSide(color: tokens.surface.outlineVariant),
        ),
        child: InkWell(
          onTap: () => context.go('/shell/family/${member.studentId}'),
          borderRadius: BorderRadius.circular(tokens.radius.md),
          child: Semantics(
            button: true,
            label: member.studentName,
            child: Padding(
              padding: EdgeInsets.all(tokens.space.md),
              child: Row(
                children: [
                  _Avatar(
                    tokens: tokens,
                    name: member.studentName,
                    active: active,
                  ),
                  SizedBox(width: tokens.space.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          member.studentName,
                          style: tokens.typography.titleSmall.copyWith(
                            color: tokens.text.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: tokens.space.xxs),
                        Row(
                          children: [
                            if (subtitle.isNotEmpty) ...[
                              Flexible(
                                child: Text(
                                  subtitle,
                                  style: tokens.typography.bodySmall.copyWith(
                                    color: tokens.text.secondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: tokens.space.xs),
                            ],
                            if (active)
                              LsStatusChip(
                                label: l.myChildrenChildActive,
                                tone: LsChipTone.success,
                                icon: Icons.check_circle_outline,
                              )
                            else
                              LsStatusChip(
                                label: member.status,
                                tone: LsChipTone.neutral,
                                icon: Icons.archive_outlined,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    // Mirror the chevron under RTL so the visual
                    // "next →" stays consistent with the text flow.
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                    color: tokens.text.tertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _subtitle(BuildContext context) {
    final l = AppLocalizations.of(context);
    final parts = <String>[];
    if (member.grade != null && member.grade!.isNotEmpty) {
      parts.add(member.grade!);
    }
    if (member.relation != null && member.relation!.isNotEmpty) {
      parts.add(l.familyChildRowRelation(member.relation!));
    }
    if (member.studentCode != null && member.studentCode!.isNotEmpty) {
      parts.add(l.familyChildRowId(member.studentCode!));
    } else if (member.studentId.isNotEmpty) {
      parts.add(l.familyChildRowId(member.studentId));
    }
    return parts.join(' · ');
  }
}

/// Compact circular avatar (initials) so the user can scan the list
/// without reading each name in full. Falls back to the first
/// character of the student name when no photo is on the wire.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.tokens,
    required this.name,
    required this.active,
  });
  final DesignTokens tokens;
  final String name;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFrom(name);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: active
            ? tokens.brand.primaryContainer
            : tokens.surface.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: tokens.typography.titleSmall.copyWith(
          color:
              active ? tokens.brand.onPrimaryContainer : tokens.text.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _initialsFrom(String value) {
    final parts =
        value.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
