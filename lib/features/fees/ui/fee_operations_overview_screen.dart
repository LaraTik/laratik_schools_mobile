// SPDX-License-Identifier: Proprietary
// Admin "Fee operations" KPI overview. Renders the aggregate
// totals (invoiced / collected / outstanding) + counts by status
// (paid / overdue / draft) + the collection rate as a single
// glance-friendly dashboard card.
//
// Reachable via the "Operations" tile on the admin home or
// directly from the "Fee plans" app bar.
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)].

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../data/fee_plan.dart';
import '../data/fees_failure.dart';
import '../data/fees_providers.dart';

class FeeOperationsOverviewScreen extends ConsumerWidget {
  const FeeOperationsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    // The yearKey family parameter is reserved for the future
    // "filter to a single academic year" affordance; today we
    // pass `''` so the provider returns the all-years aggregate.
    final async = ref.watch(feeOperationsOverviewProvider(''));
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/shell/fees/plans'),
        ),
        title: Text(
          l.feeOperationsScreenTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(feeOperationsOverviewProvider('')),
          ),
        ],
      ),
      body: async.when(
        data: (result) => switch (result) {
          Ok(:final value) => _buildBody(context, tokens, value),
          Err(:final error) => LsStateView.error(
              icon: Icons.error_outline,
              title: l.feeOperationsErrorTitle,
              message: error.message,
              action: LsButton.primary(
                label: l.commonTryAgain,
                expand: false,
                onPressed: () =>
                    ref.invalidate(feeOperationsOverviewProvider('')),
              ),
            ),
        },
        loading: () => LsStateView.loading(
          title: l.feeOperationsLoadingTitle,
          message: l.feeOperationsLoadingMessage,
        ),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: l.feeOperationsErrorTitle,
          message: err is FeesFailure ? err.message : err.toString(),
          action: LsButton.primary(
            label: l.commonTryAgain,
            expand: false,
            onPressed: () => ref.invalidate(feeOperationsOverviewProvider('')),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DesignTokens tokens,
    FeeOperationsOverview overview,
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
        _CollectionRateCard(tokens: tokens, overview: overview),
        SizedBox(height: tokens.space.lg),
        _KpiRow(tokens: tokens, overview: overview),
        SizedBox(height: tokens.space.lg),
        _StatusChipsRow(tokens: tokens, overview: overview),
        SizedBox(height: tokens.space.lg),
        LsButton.secondary(
          label: l.feeOperationsViewPlansAction,
          icon: Icons.receipt_long_outlined,
          expand: false,
          onPressed: () => context.go('/shell/fees/plans'),
        ),
      ],
    );
  }
}

class _CollectionRateCard extends StatelessWidget {
  const _CollectionRateCard({required this.tokens, required this.overview});
  final DesignTokens tokens;
  final FeeOperationsOverview overview;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rate = overview.collectionRate;
    final color = rate == null
        ? tokens.text.tertiary
        : (rate >= 80
            ? tokens.status.success
            : (rate >= 50 ? tokens.status.warning : tokens.status.error));
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
              Icon(Icons.percent_outlined, color: tokens.brand.primary),
              SizedBox(width: tokens.space.md),
              Text(
                l.feeOperationsCollectionRate,
                style: tokens.typography.titleSmall.copyWith(
                  color: tokens.text.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space.sm),
          Text(
            rate == null
                ? l.feeOperationsNoInvoices
                : '${rate.toStringAsFixed(0)}%',
            style: tokens.typography.displayMedium.copyWith(
              color: color,
            ),
          ),
          SizedBox(height: tokens.space.xxs),
          Text(
            rate == null
                ? l.feeOperationsNoInvoicesMessage
                : l.feeOperationsCollectedOfTotal(
                    overview.currency,
                    _format(overview.totalCollected),
                    overview.currency,
                    _format(overview.totalInvoiced),
                  ),
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
        ],
      ),
    );
  }

  String _format(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

class _KpiData {
  const _KpiData({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.tone,
  });
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final LsChipTone tone;
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.tokens, required this.overview});
  final DesignTokens tokens;
  final FeeOperationsOverview overview;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = <_KpiData>[
      _KpiData(
        label: l.feeOperationsInvoiced,
        value: '${overview.currency} ${_format(overview.totalInvoiced)}',
        sub: l.feeOperationsInvoicedSub,
        icon: Icons.outgoing_mail,
        tone: LsChipTone.info,
      ),
      _KpiData(
        label: l.feeOperationsCollected,
        value: '${overview.currency} ${_format(overview.totalCollected)}',
        sub: l.feeOperationsCollectedSub,
        icon: Icons.payments_outlined,
        tone: LsChipTone.success,
      ),
      _KpiData(
        label: l.feeOperationsOutstanding,
        value: '${overview.currency} ${_format(overview.totalOutstanding)}',
        sub: l.feeOperationsOutstandingSub,
        icon: Icons.account_balance_wallet_outlined,
        tone: overview.totalOutstanding > 0
            ? LsChipTone.warning
            : LsChipTone.success,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        if (isWide) {
          return Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Expanded(child: _KpiCard(tokens: tokens, data: items[i])),
                if (i < items.length - 1) SizedBox(width: tokens.space.sm),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _KpiCard(tokens: tokens, data: items[i]),
              if (i < items.length - 1) SizedBox(height: tokens.space.sm),
            ],
          ],
        );
      },
    );
  }

  String _format(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.tokens, required this.data});
  final DesignTokens tokens;
  final _KpiData data;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (data.tone) {
      LsChipTone.success => (
          tokens.status.successContainer,
          tokens.status.success,
        ),
      LsChipTone.warning => (
          tokens.status.warningContainer,
          tokens.status.warning,
        ),
      LsChipTone.error => (
          tokens.status.errorContainer,
          tokens.status.error,
        ),
      LsChipTone.info => (
          tokens.status.infoContainer,
          tokens.status.info,
        ),
      LsChipTone.brand => (
          tokens.brand.primaryContainer,
          tokens.brand.onPrimaryContainer,
        ),
      LsChipTone.neutral => (
          tokens.surface.surfaceContainerHigh,
          tokens.text.secondary,
        ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
            child: Icon(data.icon, color: fg, size: 18),
          ),
          SizedBox(height: tokens.space.sm),
          Text(
            data.value,
            style: tokens.typography.titleLarge.copyWith(
              color: tokens.text.primary,
            ),
          ),
          SizedBox(height: tokens.space.xxs),
          Text(
            data.label,
            style: tokens.typography.labelMedium.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.xxs),
          Text(
            data.sub,
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.text.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChipsRow extends StatelessWidget {
  const _StatusChipsRow({required this.tokens, required this.overview});
  final DesignTokens tokens;
  final FeeOperationsOverview overview;

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
          Text(
            l.feeOperationsByStatus,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.primary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          Wrap(
            spacing: tokens.space.xs,
            runSpacing: tokens.space.xxs,
            children: [
              LsStatusChip(
                label: l.feeOperationsPaidCountChip(overview.paidCount),
                tone: LsChipTone.success,
                icon: Icons.check_circle_outline,
              ),
              LsStatusChip(
                label: l.feeOperationsOverdueCountChip(overview.overdueCount),
                tone: overview.overdueCount > 0
                    ? LsChipTone.error
                    : LsChipTone.neutral,
                icon: Icons.warning_amber_outlined,
              ),
              LsStatusChip(
                label: l.feeOperationsDraftCountChip(overview.draftCount),
                tone: LsChipTone.neutral,
                icon: Icons.edit_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
