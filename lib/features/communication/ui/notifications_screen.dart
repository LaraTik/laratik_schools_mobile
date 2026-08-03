import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../../people/data/person_failure.dart';
import '../data/communication_providers.dart';
import '../data/communication_repository.dart';
import '../data/notification.dart';

import '../../../ui/app_theme.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      ref.read(notificationsListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final asyncPage = ref.watch(notificationsListProvider);
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          tooltip: l.commonBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shell'),
        ),
        title: Text(
          l.notificationsTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(notificationsListProvider.notifier).refresh(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space.md,
              0,
              tokens.space.md,
              tokens.space.sm,
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: l.notificationsFilterAll,
                  selected: true,
                  onTap: () => ref
                      .read(notificationsListProvider.notifier)
                      .setUnreadOnly(false),
                ),
                SizedBox(width: tokens.space.xs),
                _FilterChip(
                  label: l.notificationsFilterUnread,
                  selected: false,
                  onTap: () => ref
                      .read(notificationsListProvider.notifier)
                      .setUnreadOnly(true),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsListProvider.notifier).refresh(),
        child: asyncPage.when(
          data: (page) => _buildList(page, tokens),
          loading: () => LsStateView.loading(
            title: l.notificationsLoadingTitle,
            message: l.notificationsLoadingMessage,
          ),
          error: (err, _) => _buildError(err, tokens, l),
        ),
      ),
    );
  }

  Widget _buildList(NotificationPage page, DesignTokens tokens) {
    final items = page.items;
    if (items.isEmpty) {
      final l = AppLocalizations.of(context);
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: tokens.space.xxxl * 2),
          LsStateView.empty(
            icon: Icons.notifications_none,
            title: l.notificationsEmptyTitle,
            message: l.notificationsEmptyMessage,
          ),
        ],
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: tokens.space.xl),
      itemCount: items.length + (page.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: tokens.surface.outlineVariant,
      ),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return Padding(
            padding: EdgeInsets.all(tokens.space.md),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: tokens.brand.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }
        final n = items[index];
        return ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: tokens.space.md,
            vertical: tokens.space.sm,
          ),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: n.read
                ? tokens.surface.surfaceContainer
                : tokens.brand.primaryContainer,
            child: Icon(
              n.isHighPriority ? Icons.priority_high : Icons.notifications,
              color: n.read
                  ? tokens.text.tertiary
                  : tokens.brand.onPrimaryContainer,
              size: 18,
            ),
          ),
          title: Text(
            n.title.isEmpty ? '—' : n.title,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.primary,
              fontWeight: n.read ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
          subtitle: Text(
            [
              n.body,
              if ((n.sentAt ?? '').isNotEmpty) n.sentAt!,
            ].where((s) => s.isNotEmpty).join(' · '),
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.text.secondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: LsStatusChip(
            label: n.category,
            tone: n.isHighPriority
                ? LsChipTone.warning
                : (n.read ? LsChipTone.neutral : LsChipTone.brand),
          ),
        );
      },
    );
  }

  Widget _buildError(Object err, DesignTokens tokens, AppLocalizations l) {
    final failure = err is PersonFailure ? err : null;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: tokens.space.xxxl * 2),
        LsStateView.error(
          icon: Icons.error_outline,
          title: l.notificationsErrorTitle,
          message: failure?.message ?? err.toString(),
          action: LsButton.primary(
            label: l.commonTryAgain,
            icon: Icons.refresh,
            expand: false,
            onPressed: () =>
                ref.read(notificationsListProvider.notifier).refresh(),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    return Material(
      color: selected
          ? tokens.brand.primaryContainer
          : tokens.surface.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.pill),
        side: BorderSide(
          color: selected ? tokens.brand.primary : tokens.surface.outline,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radius.pill),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space.md,
            vertical: tokens.space.xs,
          ),
          child: Text(
            label,
            style: tokens.typography.labelMedium.copyWith(
              color: selected
                  ? tokens.brand.onPrimaryContainer
                  : tokens.text.primary,
            ),
          ),
        ),
      ),
    );
  }
}
