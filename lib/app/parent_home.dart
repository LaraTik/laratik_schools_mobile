// SPDX-License-Identifier: Proprietary
// Parent (guardian) home. Read-mostly surface for the legal
// guardian of one or more students.
//
// The role-aware shell routes here when [LaratikRole.guardian] is
// the active role (see `dashboard_screen.dart`). The home shows
// the unread notifications count, a hero "My children" tile that
// jumps straight into the family picker, and the inbox shortcut.
//
// The actual children list lives at `/shell/family` (the
// FamilyHomeScreen widget). This surface is the lightweight
// launcher; the picker is the place where the user picks a child
// and drills into the per-child records.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/communication/data/communication_providers.dart';
import '../features/family/data/family_providers.dart';
import '../l10n/app_localizations.dart';
import '../ui/app_theme.dart';
import '../ui/design_tokens.dart';
import '../ui/widgets/ls_status_chip.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final unread = ref
            .watch(notificationsListProvider)
            .value
            ?.items
            .where((n) => !n.read)
            .length ??
        0;
    // Eagerly watch the family list so the "My children" hero card
    // shows the live count rather than a generic placeholder. The
    // picker screen re-fetches on its own; this is a read-only
    // peek to keep the home calm.
    final familyAsync = ref.watch(familyListProvider);

    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.homeParentMyFamily,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.a11yNotificationsTooltip,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                if (unread > 0)
                  // PositionedDirectional so the badge stays in
                  // the top-trailing corner in both LTR (top-right)
                  // and RTL (top-left) layouts. The literal
                  // `right: -2` would have left the badge in the
                  // top-right under RTL, which reads wrong for
                  // users who expect a mirrored UI.
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    top: -2,
                    end: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: tokens.status.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => context.go('/shell/notifications'),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          _HeroFamilyCard(tokens: tokens, familyAsync: familyAsync),
          SizedBox(height: tokens.space.lg),
          // Fee invoices for the parent's children. Shown to
          // every parent — the v1 server is expected to filter
          // `get_school_student_fee_plans` to the current user's
          // children when the session is a parent role, so the
          // tile is safe to render for all parents regardless
          // of capability set. The "Fees" bottom-nav tab
          // remains capability-gated on `can_view_fees`
          // (admin-only) so the surface is launched from here
          // for parents, not from the bottom nav.
          _FeeInvoicesCard(
            tokens: tokens,
            title: l.homeParentFeeInvoicesTitle,
            subtitle: l.homeParentFeeInvoicesSubtitle,
          ),
          SizedBox(height: tokens.space.lg),
          Text(
            l.homeParentInbox,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          _InboxCard(
            tokens: tokens,
            unread: unread,
            onTap: () => context.go('/shell/notifications'),
          ),
        ],
      ),
    );
  }
}

/// Compact "Fee invoices" tile. Reused by both the parent
/// home and the student home — the v1 server filters
/// `get_school_student_fee_plans` to the current user
/// (parent's children / the student's own plans) so the
/// tile is safe to render for any role that has its own
/// server-side fee scope.
class _FeeInvoicesCard extends StatelessWidget {
  const _FeeInvoicesCard({
    required this.tokens,
    required this.title,
    required this.subtitle,
  });
  final DesignTokens tokens;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tokens.surface.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.surface.outlineVariant),
      ),
      child: InkWell(
        onTap: () => context.go('/shell/fees/plans'),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tokens.status.warningContainer,
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: tokens.status.warning,
                  size: 22,
                ),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tokens.typography.titleSmall.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                    SizedBox(height: tokens.space.xxs),
                    Text(
                      subtitle,
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.text.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                // Chevron points the same way as the text flow
                // in both LTR and RTL. `chevron_right` is the
                // canonical Material 3 chevron for list rows; in
                // RTL layouts Material's `ListTile` mirrors it
                // automatically, but a raw Icon doesn't, so we
                // pick the right one per direction.
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                color: tokens.text.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero "My children" card. Shows the live count from
/// [familyListProvider] when available, otherwise a calm loading
/// placeholder. Tap → /shell/family.
class _HeroFamilyCard extends StatelessWidget {
  const _HeroFamilyCard({required this.tokens, required this.familyAsync});
  final DesignTokens tokens;
  final AsyncValue<dynamic> familyAsync;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final summary = _summaryFor(familyAsync, l);
    return Material(
      color: tokens.brand.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: InkWell(
        onTap: () => context.go('/shell/family'),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: tokens.surface.surface,
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Icon(
                  Icons.family_restroom_outlined,
                  color: tokens.brand.primary,
                  size: 28,
                ),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.homeParentMyChildren,
                      style: tokens.typography.titleMedium.copyWith(
                        color: tokens.brand.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(height: tokens.space.xxs),
                    Text(
                      summary.message,
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.brand.onPrimaryContainer,
                      ),
                    ),
                    if (summary.chip != null) ...[
                      SizedBox(height: tokens.space.xs),
                      LsStatusChip(
                        label: summary.chip!,
                        tone: LsChipTone.brand,
                        icon: Icons.people_outline,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                color: tokens.brand.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _HeroSummary _summaryFor(AsyncValue<dynamic> async, AppLocalizations l) {
    return async.when(
      data: (page) {
        final members = (page as dynamic).members as List<dynamic>? ?? const [];
        if (members.isEmpty) {
          return _HeroSummary(
            message: l.homeParentNoChildrenMessage,
            chip: null,
          );
        }
        final active =
            members.where((m) => (m as dynamic).isActive as bool).length;
        final count = members.length;
        return _HeroSummary(
          message: count == 0
              ? l.homeParentLinkedChildren(0)
              : (active == count
                  ? l.homeParentLinkedChildrenActive(count, active)
                  : l.homeParentLinkedChildrenActive(count, active)),
          chip: l.homeParentLinkedChildren(count),
        );
      },
      loading: () => _HeroSummary(
        message: l.homeParentHeroLoadingMessage,
        chip: l.homeParentHeroLoadingChip,
      ),
      error: (_, __) => _HeroSummary(
        message: l.homeParentHeroErrorMessage,
        chip: l.homeParentHeroErrorChip,
      ),
    );
  }
}

class _HeroSummary {
  const _HeroSummary({required this.message, required this.chip});
  final String message;
  final String? chip;
}

class _InboxCard extends StatelessWidget {
  const _InboxCard({
    required this.tokens,
    required this.unread,
    required this.onTap,
  });
  final DesignTokens tokens;
  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: tokens.surface.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.surface.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tokens.surface.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Icon(
                  unread == 0
                      ? Icons.notifications_none_outlined
                      : Icons.notifications_active_outlined,
                  color: tokens.text.secondary,
                  size: 22,
                ),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.homeParentInbox,
                      style: tokens.typography.titleSmall.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                    SizedBox(height: tokens.space.xxs),
                    Text(
                      l.homeParentInboxUnread(unread),
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.text.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                color: tokens.text.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
