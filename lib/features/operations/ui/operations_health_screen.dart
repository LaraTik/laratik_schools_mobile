// SPDX-License-Identifier: Proprietary
// Admin "Operations" surface — read + write operations health +
// delivery health + auth audit events + delivery write flows.
//
// The screen has three tabs:
//   * **Health** — top-level status (healthy / degraded /
//     unhealthy) + the per-module KPI maps (analytics, audit,
//     delivery, imports, outbox) flattened into a single
//     grid so the operator can scan them at a glance.
//   * **Delivery** — per-status counts of outbound events
//     (pending / completed / failed) + a stacked bar +
//     per-status chips + the **Replay** and **Receive
//     callback** admin write actions.
//   * **Audit** — recent auth audit events (login / logout /
//     token refresh / device register) with the event
//     family, user, timestamp, and source IP.
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)]; the chevron mirrors itself
// under RTL so the visual flow stays consistent with the
// text direction.
//
// Reachable from a "Operations" tile on the admin home
// (capability-gated on the operations capability) at
// `/shell/operations`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../data/operations_failure.dart';
import '../data/operations_health.dart';
import '../data/operations_providers.dart';

/// Read-only operations surface. Three tabs (Health / Delivery /
/// Audit). Reachable from `/shell/operations`.
class OperationsHealthScreen extends ConsumerWidget {
  const OperationsHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: tokens.surface.canvas,
        appBar: AppBar(
          backgroundColor: tokens.surface.surface,
          elevation: 0,
          title: Text(
            l.operationsScreenTitle,
            style: tokens.typography.titleLarge.copyWith(
              color: tokens.text.primary,
            ),
          ),
          actions: [
            IconButton(
              tooltip: l.commonRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(operationsHealthProvider);
                ref.invalidate(deliveryHealthProvider);
                ref.invalidate(authAuditEventsProvider);
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: tokens.surface.surface,
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: tokens.brand.primary,
                labelColor: tokens.brand.primary,
                unselectedLabelColor: tokens.text.secondary,
                labelStyle: tokens.typography.labelLarge,
                tabs: [
                  Tab(text: l.operationsTabHealth),
                  Tab(text: l.operationsTabDelivery),
                  Tab(text: l.operationsTabAudit),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _HealthTab(),
            _DeliveryTab(),
            _AuditTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Health tab
// ---------------------------------------------------------------------------

class _HealthTab extends ConsumerWidget {
  const _HealthTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(operationsHealthProvider);
    return async.when(
      data: (result) => switch (result) {
        Ok(:final value) => _buildBody(context, tokens, value),
        Err(:final error) => _buildError(
            context,
            tokens,
            ref,
            error,
            l.operationsErrorTitle,
          ),
      },
      loading: () => LsStateView.loading(
        title: l.operationsLoadingTitle,
        message: l.operationsLoadingMessage,
      ),
      error: (err, _) => LsStateView.error(
        icon: Icons.error_outline,
        title: l.operationsErrorTitle,
        message: err.toString(),
        action: LsButton.primary(
          label: l.commonTryAgain,
          expand: false,
          onPressed: () => ref.invalidate(operationsHealthProvider),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DesignTokens tokens,
    OperationsHealth health,
  ) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        tokens.space.md,
        tokens.space.md,
        tokens.space.md,
        tokens.space.xl,
      ),
      children: [
        _StatusCard(tokens: tokens, health: health),
        SizedBox(height: tokens.space.lg),
        Text(
          l.operationsModulesHeader,
          style: tokens.typography.titleSmall.copyWith(
            color: tokens.text.secondary,
          ),
        ),
        SizedBox(height: tokens.space.sm),
        if (health.moduleKpis.isEmpty)
          LsStateView.empty(
            icon: Icons.insights_outlined,
            title: l.operationsModulesEmptyTitle,
            message: l.operationsModulesEmptyMessage,
          )
        else
          _KpiGrid(tokens: tokens, kpis: health.moduleKpis),
      ],
    );
  }

  Widget _buildError(
    BuildContext context,
    DesignTokens tokens,
    WidgetRef ref,
    OperationsFailure error,
    String title,
  ) {
    final l = AppLocalizations.of(context);
    return LsStateView.error(
      icon: Icons.error_outline,
      title: title,
      message: error.message,
      action: LsButton.primary(
        label: l.commonTryAgain,
        expand: false,
        onPressed: () => ref.invalidate(operationsHealthProvider),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.tokens, required this.health});
  final DesignTokens tokens;
  final OperationsHealth health;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (String label, LsChipTone tone) = switch (health.status) {
      'healthy' => (l.operationsStatusHealthy, LsChipTone.success),
      'degraded' => (l.operationsStatusDegraded, LsChipTone.warning),
      'unhealthy' => (l.operationsStatusUnhealthy, LsChipTone.error),
      _ => (health.status, LsChipTone.neutral),
    };
    return Container(
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
                health.isHealthy
                    ? Icons.check_circle_outline
                    : health.isUnhealthy
                        ? Icons.error_outline
                        : Icons.warning_amber_outlined,
                color: switch (tone) {
                  LsChipTone.success => tokens.status.success,
                  LsChipTone.warning => tokens.status.warning,
                  LsChipTone.error => tokens.status.error,
                  _ => tokens.text.secondary,
                },
                size: 28,
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Text(
                  l.operationsSystemHealth,
                  style: tokens.typography.titleMedium.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
              ),
              LsStatusChip(
                label: label,
                tone: tone,
                icon: health.isHealthy
                    ? Icons.check_circle_outline
                    : health.isUnhealthy
                        ? Icons.error_outline
                        : Icons.warning_amber_outlined,
              ),
            ],
          ),
          if (health.generatedAt.isNotEmpty) ...[
            SizedBox(height: tokens.space.xs),
            Text(
              l.operationsGeneratedAt(health.generatedAt),
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.text.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.tokens, required this.kpis});
  final DesignTokens tokens;
  final List<ModuleKpi> kpis;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final byModule = <String, List<ModuleKpi>>{};
    for (final k in kpis) {
      byModule.putIfAbsent(k.module, () => []).add(k);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final module in const [
          'analytics',
          'audit',
          'delivery',
          'imports',
          'outbox',
        ]) ...[
          if (byModule[module] != null && byModule[module]!.isNotEmpty) ...[
            Text(
              _moduleLabel(module, l),
              style: tokens.typography.titleSmall.copyWith(
                color: tokens.text.secondary,
              ),
            ),
            SizedBox(height: tokens.space.xs),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                final cols = isWide ? 3 : 2;
                final items = byModule[module]!;
                return Column(
                  children: [
                    for (var r = 0; r * cols < items.length; r++) ...[
                      if (r > 0) SizedBox(height: tokens.space.sm),
                      Row(
                        children: [
                          for (var c = 0; c < cols; c++) ...[
                            if (c > 0) SizedBox(width: tokens.space.sm),
                            if (r * cols + c < items.length)
                              Expanded(
                                child: _KpiTile(
                                  tokens: tokens,
                                  kpi: items[r * cols + c],
                                ),
                              )
                            else
                              const Expanded(child: SizedBox.shrink()),
                          ],
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
            SizedBox(height: tokens.space.md),
          ],
        ],
      ],
    );
  }

  String _moduleLabel(String module, AppLocalizations l) {
    return switch (module) {
      'analytics' => l.operationsModuleAnalytics,
      'audit' => l.operationsModuleAudit,
      'delivery' => l.operationsModuleDelivery,
      'imports' => l.operationsModuleImports,
      'outbox' => l.operationsModuleOutbox,
      _ => module,
    };
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.tokens, required this.kpi});
  final DesignTokens tokens;
  final ModuleKpi kpi;

  @override
  Widget build(BuildContext context) {
    final value = _formatValue(kpi.value);
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: tokens.typography.titleLarge.copyWith(
              color: tokens.text.primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: tokens.space.xxs),
          Text(
            _humanize(kpi.key),
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.text.secondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatValue(Object? value) {
    if (value == null) return '—';
    if (value is bool) return value ? '✓' : '✗';
    if (value is num) {
      if (value == value.roundToDouble()) return value.toInt().toString();
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  String _humanize(String key) {
    // Best-effort humanizer. "last_30d_failed" -> "Last 30D Failed".
    final parts = key.split('_');
    return parts
        .map((p) => p.isEmpty ? p : (p[0].toUpperCase() + p.substring(1)))
        .join(' ');
  }
}

// ---------------------------------------------------------------------------
// Delivery tab
// ---------------------------------------------------------------------------

class _DeliveryTab extends ConsumerWidget {
  const _DeliveryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(deliveryHealthProvider);
    return async.when(
      data: (result) => switch (result) {
        Ok(:final value) => _buildBody(context, ref, tokens, value),
        Err(:final error) => LsStateView.error(
            icon: Icons.error_outline,
            title: l.operationsErrorTitle,
            message: error.message,
            action: LsButton.primary(
              label: l.commonTryAgain,
              expand: false,
              onPressed: () => ref.invalidate(deliveryHealthProvider),
            ),
          ),
      },
      loading: () => LsStateView.loading(
        title: l.operationsDeliveryLoadingTitle,
        message: l.operationsDeliveryLoadingMessage,
      ),
      error: (err, _) => LsStateView.error(
        icon: Icons.error_outline,
        title: l.operationsErrorTitle,
        message: err.toString(),
        action: LsButton.primary(
          label: l.commonTryAgain,
          expand: false,
          onPressed: () => ref.invalidate(deliveryHealthProvider),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DesignTokens tokens,
    DeliveryHealth health,
  ) {
    final l = AppLocalizations.of(context);
    final counts = health.sortedCounts();
    return ListView(
      padding: EdgeInsets.fromLTRB(
        tokens.space.md,
        tokens.space.md,
        tokens.space.md,
        tokens.space.xl,
      ),
      children: [
        _DeliverySummaryCard(tokens: tokens, health: health),
        SizedBox(height: tokens.space.md),
        Row(
          children: [
            Expanded(
              child: LsButton.secondary(
                label: l.operationsReplayAction,
                icon: Icons.refresh,
                expand: false,
                onPressed: () => _showReplayEventKeyPrompt(context, ref, l),
              ),
            ),
            SizedBox(width: tokens.space.sm),
            Expanded(
              child: LsButton.secondary(
                label: l.operationsReceiveCallbackAction,
                icon: Icons.outgoing_mail,
                expand: false,
                onPressed: () => _showReceiveCallbackPrompt(context, ref, l),
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.space.lg),
        Text(
          l.operationsDeliveryByStatus,
          style: tokens.typography.titleSmall.copyWith(
            color: tokens.text.secondary,
          ),
        ),
        SizedBox(height: tokens.space.sm),
        if (counts.isEmpty)
          LsStateView.empty(
            icon: Icons.outgoing_mail,
            title: l.operationsDeliveryEmptyTitle,
            message: l.operationsDeliveryEmptyMessage,
          )
        else
          _DeliveryBar(tokens: tokens, counts: counts),
        if (counts.isNotEmpty) ...[
          SizedBox(height: tokens.space.sm),
          Wrap(
            spacing: tokens.space.xs,
            runSpacing: tokens.space.xxs,
            children: [
              for (final entry in counts)
                LsStatusChip(
                  label: '${_humanize(entry.key)} · ${entry.value}',
                  tone: _toneForStatus(entry.key, tokens),
                  icon: _iconForStatus(entry.key),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _showReplayEventKeyPrompt(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
  ) async {
    final tokens = context.laratik;
    final controller = TextEditingController();
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l.operationsReplayPromptTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l.operationsReplayEventKeyLabel,
                  hintText: l.operationsReplayEventKeyHint,
                ),
              ),
              SizedBox(height: tokens.space.sm),
              TextField(
                controller: reasonController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l.operationsReplayReasonLabel,
                  hintText: l.operationsReplayReasonHint,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.commonCancel),
            ),
            FilledButton.tonal(
              onPressed: () {
                final key = controller.text.trim();
                if (key.isEmpty) return;
                Navigator.of(ctx).pop(key);
              },
              child: Text(l.operationsReplayAction),
            ),
          ],
        );
      },
    );
    if (result == null || result.isEmpty || !context.mounted) return;
    final reason = reasonController.text.trim();
    final replayResult = await ref
        .read(replayDeliveryEventProvider.notifier)
        .submit(eventKey: result, reason: reason.isEmpty ? null : reason);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    switch (replayResult) {
      case Ok(:final value):
        if (value.isSuccess) {
          messenger.showSnackBar(
            SnackBar(content: Text(l.operationsReplaySuccessSnack(value.eventKey))),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text(l.operationsReplayStatusSnack(
                value.status ?? 'unknown',
              )),
            ),
          );
        }
      case Err(:final error):
        messenger.showSnackBar(
          SnackBar(content: Text(l.operationsReplayErrorSnack(error.message))),
        );
    }
  }

  Future<void> _showReceiveCallbackPrompt(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
  ) async {
    final tokens = context.laratik;
    final providerController = TextEditingController();
    final signatureController = TextEditingController();
    final bodyController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l.operationsReceiveCallbackPromptTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: providerController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l.operationsReceiveCallbackProviderLabel,
                    hintText: l.operationsReceiveCallbackProviderHint,
                  ),
                ),
                SizedBox(height: tokens.space.sm),
                TextField(
                  controller: signatureController,
                  decoration: InputDecoration(
                    labelText: l.operationsReceiveCallbackSignatureLabel,
                    hintText: l.operationsReceiveCallbackSignatureHint,
                  ),
                ),
                SizedBox(height: tokens.space.sm),
                TextField(
                  controller: bodyController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l.operationsReceiveCallbackBodyLabel,
                    hintText: l.operationsReceiveCallbackBodyHint,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.commonCancel),
            ),
            FilledButton.tonal(
              onPressed: () {
                final provider = providerController.text.trim();
                if (provider.isEmpty) return;
                Navigator.of(ctx).pop(provider);
              },
              child: Text(l.operationsReceiveCallbackAction),
            ),
          ],
        );
      },
    );
    if (result == null || result.isEmpty || !context.mounted) return;
    final signature = signatureController.text.trim();
    final body = bodyController.text.trim();
    final cbResult = await ref
        .read(receiveDeliveryCallbackProvider.notifier)
        .submit(
          provider: result,
          signature: signature.isEmpty ? null : signature,
          body: body.isEmpty ? null : body,
        );
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    switch (cbResult) {
      case Ok(:final value):
        if (value.isAccepted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(l.operationsReceiveCallbackSuccessSnack(
                value.deliveryIdentity,
              )),
            ),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text(l.operationsReceiveCallbackStatusSnack(
                value.status ?? 'unknown',
              )),
            ),
          );
        }
      case Err(:final error):
        messenger.showSnackBar(
          SnackBar(
            content: Text(l.operationsReceiveCallbackErrorSnack(error.message)),
          ),
        );
    }
  }

  IconData _iconForStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('pending')) return Icons.hourglass_top_outlined;
    if (s.contains('completed') || s.contains('delivered')) {
      return Icons.check_circle_outline;
    }
    if (s.contains('failed')) return Icons.error_outline;
    if (s.contains('retry')) return Icons.refresh;
    if (s.contains('dead') || s.contains('dropped')) {
      return Icons.block_outlined;
    }
    return Icons.help_outline;
  }

  LsChipTone _toneForStatus(String status, DesignTokens tokens) {
    final s = status.toLowerCase();
    if (s.contains('completed') || s.contains('delivered')) {
      return LsChipTone.success;
    }
    if (s.contains('failed') || s.contains('dead') || s.contains('dropped')) {
      return LsChipTone.error;
    }
    if (s.contains('pending') || s.contains('retry')) {
      return LsChipTone.warning;
    }
    return LsChipTone.neutral;
  }

  String _humanize(String key) {
    if (key.isEmpty) return key;
    return key[0].toUpperCase() + key.substring(1);
  }
}

class _DeliverySummaryCard extends StatelessWidget {
  const _DeliverySummaryCard({required this.tokens, required this.health});
  final DesignTokens tokens;
  final DeliveryHealth health;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
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
              Icon(Icons.outgoing_mail, color: tokens.brand.primary),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Text(
                  l.operationsDeliveryTotal,
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space.sm),
          Text(
            health.total.toString(),
            style: tokens.typography.displayMedium.copyWith(
              color: tokens.text.primary,
            ),
          ),
          SizedBox(height: tokens.space.xxs),
          Text(
            l.operationsDeliveryTotalSubtitle,
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryBar extends StatelessWidget {
  const _DeliveryBar({required this.tokens, required this.counts});
  final DesignTokens tokens;
  final List<MapEntry<String, int>> counts;

  @override
  Widget build(BuildContext context) {
    final total = counts.fold<int>(0, (sum, e) => sum + e.value);
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius.md),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            for (final entry in counts)
              Expanded(
                flex: total == 0 ? 0 : entry.value,
                child: Container(
                  color: _colorForStatus(entry.key, tokens),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _colorForStatus(String status, DesignTokens tokens) {
    final s = status.toLowerCase();
    if (s.contains('completed') || s.contains('delivered')) {
      return tokens.status.success;
    }
    if (s.contains('failed') || s.contains('dead') || s.contains('dropped')) {
      return tokens.status.error;
    }
    if (s.contains('pending') || s.contains('retry')) {
      return tokens.status.warning;
    }
    return tokens.brand.primary;
  }
}

// ---------------------------------------------------------------------------
// Audit tab
// ---------------------------------------------------------------------------

class _AuditTab extends ConsumerWidget {
  const _AuditTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(authAuditEventsProvider);
    return async.when(
      data: (page) {
        if (page.events.isEmpty) {
          return RefreshIndicator(
            color: tokens.brand.primary,
            onRefresh: () =>
                ref.read(authAuditEventsProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: LsStateView.empty(
                    icon: Icons.history_outlined,
                    title: l.operationsAuditEmptyTitle,
                    message: l.operationsAuditEmptyMessage,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: tokens.brand.primary,
          onRefresh: () => ref.read(authAuditEventsProvider.notifier).refresh(),
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              tokens.space.md,
              tokens.space.md,
              tokens.space.md,
              tokens.space.xl,
            ),
            itemCount: page.events.length,
            separatorBuilder: (_, __) => SizedBox(height: tokens.space.sm),
            itemBuilder: (context, index) =>
                _AuditRow(tokens: tokens, event: page.events[index]),
          ),
        );
      },
      loading: () => LsStateView.loading(
        title: l.operationsAuditLoadingTitle,
        message: l.operationsAuditLoadingMessage,
      ),
      error: (err, _) => LsStateView.error(
        icon: Icons.error_outline,
        title: l.operationsErrorTitle,
        message: err.toString(),
        action: LsButton.primary(
          label: l.commonTryAgain,
          expand: false,
          onPressed: () => ref.invalidate(authAuditEventsProvider),
        ),
      ),
    );
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.tokens, required this.event});
  final DesignTokens tokens;
  final AuthAuditEvent event;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Row(
        children: [
          _Family(tokens: tokens, event: event),
          SizedBox(width: tokens.space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.user.isEmpty
                      ? l.operationsAuditUnknownUser
                      : event.user,
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.text.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (event.timestamp.isNotEmpty) ...[
                  SizedBox(height: tokens.space.xxs),
                  Text(
                    event.timestamp,
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.text.secondary,
                    ),
                  ),
                ],
                if (event.ipAddress.isNotEmpty) ...[
                  SizedBox(height: tokens.space.xxs),
                  Text(
                    l.operationsAuditFromIp(event.ipAddress),
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.text.tertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Family extends StatelessWidget {
  const _Family({required this.tokens, required this.event});
  final DesignTokens tokens;
  final AuthAuditEvent event;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, LsChipTone tone) = _visualFor(event.family, tokens);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _bgFor(tone, tokens),
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: _fgFor(tone, tokens), size: 22),
    );
  }

  (IconData, LsChipTone) _visualFor(String family, DesignTokens tokens) {
    return switch (family) {
      'login' => (Icons.login_outlined, LsChipTone.success),
      'logout' => (Icons.logout_outlined, LsChipTone.neutral),
      'token_refresh' => (Icons.refresh_outlined, LsChipTone.info),
      'device_register' => (Icons.devices_outlined, LsChipTone.brand),
      _ => (Icons.event_note_outlined, LsChipTone.warning),
    };
  }

  Color _bgFor(LsChipTone tone, DesignTokens tokens) {
    return switch (tone) {
      LsChipTone.success => tokens.status.successContainer,
      LsChipTone.warning => tokens.status.warningContainer,
      LsChipTone.error => tokens.status.errorContainer,
      LsChipTone.info => tokens.status.infoContainer,
      LsChipTone.brand => tokens.brand.primaryContainer,
      LsChipTone.neutral => tokens.surface.surfaceContainerHigh,
    };
  }

  Color _fgFor(LsChipTone tone, DesignTokens tokens) {
    return switch (tone) {
      LsChipTone.success => tokens.status.success,
      LsChipTone.warning => tokens.status.warning,
      LsChipTone.error => tokens.status.error,
      LsChipTone.info => tokens.status.info,
      LsChipTone.brand => tokens.brand.onPrimaryContainer,
      LsChipTone.neutral => tokens.text.secondary,
    };
  }
}
