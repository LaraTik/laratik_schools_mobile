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

import '../features/boot/boot_provider.dart';
import '../features/communication/data/communication_providers.dart';
import '../features/family/data/family_providers.dart';
import '../ui/app_theme.dart';
import '../ui/design_tokens.dart';
import '../ui/widgets/ls_status_chip.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
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
          'My family',
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                if (unread > 0)
                  Positioned(
                    right: -2,
                    top: -2,
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
          // Fee invoices for the parent's children. Capability-
          // gated on `can_view_fees` — the v1 server only grants
          // that capability to fee-management roles today, so
          // most parents will not see this tile. When the
          // backend grows a `can_view_own_fees` capability the
          // tile can drop in for every parent; the read path
          // (the v1 `get_school_student_fee_plans` endpoint,
          // filtered to the current user on the server) is
          // already in place.
          if (hasCapability(ref, 'can_view_fees')) ...[
            _FeeInvoicesCard(tokens: tokens),
            SizedBox(height: tokens.space.lg),
          ],
          Text(
            'Inbox',
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

/// Compact "Fee invoices" tile for the parent home. Capability-
/// gated on `can_view_fees` by the parent home; the tap opens
/// the same fee-plans list the admin uses (the v1 server is
/// expected to filter to the current user's children when the
/// session is a parent role).
class _FeeInvoicesCard extends StatelessWidget {
  const _FeeInvoicesCard({required this.tokens});
  final DesignTokens tokens;

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
                      'Fee invoices',
                      style: tokens.typography.titleSmall.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                    SizedBox(height: tokens.space.xxs),
                    Text(
                      "Review your children's fee plans and payment status.",
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.text.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: tokens.text.tertiary),
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
    final summary = _summaryFor(familyAsync);
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
                      'My children',
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
                Icons.chevron_right,
                color: tokens.brand.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _HeroSummary _summaryFor(AsyncValue<dynamic> async) {
    return async.when(
      data: (page) {
        final members = (page as dynamic).members as List<dynamic>? ?? const [];
        if (members.isEmpty) {
          return const _HeroSummary(
            message: "When the school links you as a guardian, your "
                "children's grades, attendance, and report cards "
                'will appear here.',
            chip: null,
          );
        }
        final active =
            members.where((m) => (m as dynamic).isActive as bool).length;
        final count = members.length;
        return _HeroSummary(
          message: count == 1
              ? '1 linked child · tap to see grades, attendance, and '
                  'report cards.'
              : '$count linked children · $active active. Tap to see '
                  'grades, attendance, and report cards.',
          chip: count == 1 ? '1 child' : '$count children',
        );
      },
      loading: () => const _HeroSummary(
        message: 'Looking up the students you are linked to.',
        chip: 'Loading…',
      ),
      error: (_, __) => const _HeroSummary(
        message: "We couldn't load your children just now. "
            'Tap to retry.',
        chip: 'Try again',
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
                      'Inbox',
                      style: tokens.typography.titleSmall.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                    SizedBox(height: tokens.space.xxs),
                    Text(
                      unread == 0
                          ? 'No new messages'
                          : '$unread unread message${unread == 1 ? '' : 's'}',
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.text.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: tokens.text.tertiary),
            ],
          ),
        ),
      ),
    );
  }
}
