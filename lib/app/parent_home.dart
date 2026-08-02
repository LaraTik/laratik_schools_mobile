import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/communication/data/communication_providers.dart';
import '../ui/app_theme.dart';
import '../ui/widgets/ls_button.dart';

/// Parent (guardian) home. A read-mostly surface for the legal
/// guardian of one or more students. Today's build is a
/// placeholder — the full "my children" picker with per-child
/// grade / attendance / report cards lands in the next release.
/// The plumbing is in place: the boot context exposes the
/// guardian record, the dashboard routes here, and the bottom
/// nav hides the registrar tabs for guardians.
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
          Container(
            padding: EdgeInsets.all(tokens.space.md),
            decoration: BoxDecoration(
              color: tokens.surface.surface,
              borderRadius: BorderRadius.circular(tokens.radius.md),
              border: Border.all(color: tokens.surface.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.family_restroom_outlined,
                  color: tokens.brand.primary,
                ),
                SizedBox(width: tokens.space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your linked children',
                        style: tokens.typography.titleSmall.copyWith(
                          color: tokens.text.primary,
                        ),
                      ),
                      SizedBox(height: tokens.space.xxs),
                      Text(
                        'When the school links you as a guardian, your '
                        "children's grades, attendance, and report cards "
                        'will appear here. The full picker lands in the '
                        'next release.',
                        style: tokens.typography.bodySmall.copyWith(
                          color: tokens.text.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.space.lg),
          Text(
            'Inbox',
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          Container(
            padding: EdgeInsets.all(tokens.space.md),
            decoration: BoxDecoration(
              color: tokens.surface.surface,
              borderRadius: BorderRadius.circular(tokens.radius.md),
              border: Border.all(color: tokens.surface.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: tokens.text.secondary,
                      size: 18,
                    ),
                    SizedBox(width: tokens.space.xs),
                    Text(
                      unread == 0
                          ? 'No new messages'
                          : '$unread unread message${unread == 1 ? '' : 's'}',
                      style: tokens.typography.titleSmall.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.space.xs),
                Text(
                  'Announcements from the school land here, plus '
                  "anything addressed to your children (absence notes, "
                  'grade releases, fee reminders).',
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.text.secondary,
                  ),
                ),
                SizedBox(height: tokens.space.md),
                LsButton.secondary(
                  label: 'Open inbox',
                  icon: Icons.inbox_outlined,
                  expand: false,
                  onPressed: () => context.go('/shell/notifications'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
