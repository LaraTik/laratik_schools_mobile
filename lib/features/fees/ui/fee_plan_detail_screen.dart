// SPDX-License-Identifier: Proprietary
// Per-plan detail screen. Renders the fee plan's identity, the
// per-line breakdown, and the payment status. The data layer
// ([feePlanDetailProvider]) refetches the full fee plan list
// and picks the matching row by id; the v1 SDK does not expose
// a single-plan `get` endpoint today.
//
// UX:
//   * Identity card: student name, academic year, currency,
//     status chip, totals (total / paid / outstanding).
//   * Per-line breakdown: each item rendered as a row with the
//     description, category, frequency, and amount.
//   * Empty / loading / error / retry paths reuse [LsStateView].
//   * "Record a payment" tile is reserved for the future
//     teller / cashier surface (deferred to a follow-up turn).
//   * Every user-facing string is locale-aware via
//     [AppLocalizations.of(context)].

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

class FeePlanDetailScreen extends ConsumerWidget {
  const FeePlanDetailScreen({required this.planId, super.key});
  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(feePlanDetailProvider(planId));
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          tooltip: l.commonBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/shell/fees/plans'),
        ),
        title: Text(
          l.feePlanDetailTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
      ),
      body: async.when(
        data: (result) => switch (result) {
          Ok(:final value) => value == null
              ? _buildNotFound(context, tokens)
              : _buildBody(context, tokens, value),
          Err(:final error) => _buildError(
              context,
              tokens,
              ref,
              error,
              l.feePlanErrorTitle,
            ),
        },
        loading: () => LsStateView.loading(
          title: l.feePlanLoadingTitle,
          message: l.feePlanLoadingMessage,
        ),
        error: (err, _) => _buildError(
          context,
          tokens,
          ref,
          err is FeesFailure
              ? err
              : FeesFailure(code: 'EXCEPTION', message: err.toString()),
          l.feePlanErrorTitle,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DesignTokens tokens, FeePlan plan) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        tokens.space.md,
        tokens.space.md,
        tokens.space.md,
        tokens.space.xl,
      ),
      children: [
        _IdentityCard(tokens: tokens, plan: plan),
        SizedBox(height: tokens.space.lg),
        Text(
          l.feePlansBreakdown,
          style: tokens.typography.titleSmall.copyWith(
            color: tokens.text.secondary,
          ),
        ),
        SizedBox(height: tokens.space.sm),
        if (plan.items.isEmpty)
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
                  Icons.info_outline,
                  color: tokens.text.tertiary,
                  size: 20,
                ),
                SizedBox(width: tokens.space.md),
                Expanded(
                  child: Text(
                    l.feePlanNoBreakdownMessage,
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.text.secondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          for (final item in plan.items) ...[
            _ItemRow(tokens: tokens, item: item, currency: plan.currency),
            SizedBox(height: tokens.space.xs),
          ],
      ],
    );
  }

  Widget _buildNotFound(BuildContext context, DesignTokens tokens) {
    final l = AppLocalizations.of(context);
    return LsStateView.empty(
      icon: Icons.receipt_long_outlined,
      title: l.feePlanNotFoundTitle,
      message: l.feePlanNotFoundMessage,
      action: LsButton.primary(
        label: l.feePlanNotFoundAction,
        icon: Icons.arrow_back,
        expand: false,
        onPressed: () => context.go('/shell/fees/plans'),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    DesignTokens tokens,
    WidgetRef ref,
    FeesFailure error,
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
        onPressed: () => ref.invalidate(feePlanDetailProvider(planId)),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.tokens, required this.plan});
  final DesignTokens tokens;
  final FeePlan plan;

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
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: plan.isPaid
                      ? tokens.surface.surfaceContainerHigh
                      : tokens.brand.primaryContainer,
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: plan.isPaid
                      ? tokens.text.secondary
                      : tokens.brand.onPrimaryContainer,
                  size: 28,
                ),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.studentName.isEmpty
                          ? plan.student
                          : plan.studentName,
                      style: tokens.typography.titleMedium.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                    SizedBox(height: tokens.space.xxs),
                    Text(
                      l.feePlanIdentitySubtitle(plan.id),
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.text.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space.md),
          Wrap(
            spacing: tokens.space.xs,
            runSpacing: tokens.space.xxs,
            children: [
              Builder(
                builder: (context) {
                  final (tone, icon) = _toneForStatus(plan);
                  return LsStatusChip(
                    label: _capitalize(plan.invoiceStatus),
                    tone: tone,
                    icon: icon,
                  );
                },
              ),
              if (plan.academicYear.isNotEmpty)
                LsStatusChip(
                  label: plan.academicYear,
                  tone: LsChipTone.neutral,
                  icon: Icons.calendar_today_outlined,
                ),
              if (plan.dueDate != null && plan.dueDate!.isNotEmpty)
                LsStatusChip(
                  label: l.feePlanDueDateChip(plan.dueDate!),
                  tone: LsChipTone.warning,
                  icon: Icons.event_outlined,
                ),
            ],
          ),
          SizedBox(height: tokens.space.md),
          _TotalsRow(tokens: tokens, plan: plan),
        ],
      ),
    );
  }

  (LsChipTone, IconData) _toneForStatus(FeePlan p) {
    switch (p.invoiceStatus.toLowerCase()) {
      case 'paid':
        return (LsChipTone.success, Icons.check_circle_outline);
      case 'overdue':
        return (LsChipTone.error, Icons.warning_amber_outlined);
      case 'partially paid':
        return (LsChipTone.warning, Icons.pie_chart_outline);
      case 'issued':
        return (LsChipTone.info, Icons.outgoing_mail);
      case 'draft':
        return (LsChipTone.neutral, Icons.edit_outlined);
      case 'cancelled':
        return (LsChipTone.neutral, Icons.block_outlined);
      default:
        return (LsChipTone.neutral, Icons.help_outline);
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.tokens, required this.plan});
  final DesignTokens tokens;
  final FeePlan plan;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _TotalCell(
            tokens: tokens,
            label: l.feePlanTotalLabel,
            value: '${plan.currency} ${_format(plan.totalAmount)}',
            tone: LsChipTone.neutral,
          ),
        ),
        SizedBox(width: tokens.space.xs),
        Expanded(
          child: _TotalCell(
            tokens: tokens,
            label: l.feePlanPaidLabel,
            value: '${plan.currency} ${_format(plan.paidAmount)}',
            tone: LsChipTone.success,
          ),
        ),
        SizedBox(width: tokens.space.xs),
        Expanded(
          child: _TotalCell(
            tokens: tokens,
            label: l.feePlanOutstandingLabel,
            value: '${plan.currency} ${_format(plan.outstandingAmount)}',
            tone: plan.isPaid ? LsChipTone.neutral : LsChipTone.error,
          ),
        ),
      ],
    );
  }

  String _format(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

class _TotalCell extends StatelessWidget {
  const _TotalCell({
    required this.tokens,
    required this.label,
    required this.value,
    required this.tone,
  });
  final DesignTokens tokens;
  final String label;
  final String value;
  final LsChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (tone) {
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
      _ => (
          tokens.surface.surfaceContainerHigh,
          tokens.text.secondary,
        ),
    };
    return Container(
      padding: EdgeInsets.all(tokens.space.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tokens.typography.labelSmall.copyWith(color: fg),
          ),
          SizedBox(height: tokens.space.xxs),
          Text(
            value,
            style: tokens.typography.titleSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.tokens,
    required this.item,
    required this.currency,
  });
  final DesignTokens tokens;
  final FeePlanItem item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tokens.brand.primaryContainer,
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
            child: Icon(
              Icons.receipt_outlined,
              color: tokens.brand.onPrimaryContainer,
              size: 18,
            ),
          ),
          SizedBox(width: tokens.space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
                if (item.category.isNotEmpty || item.frequency.isNotEmpty) ...[
                  SizedBox(height: tokens.space.xxs),
                  Text(
                    [
                      if (item.category.isNotEmpty) item.category,
                      if (item.frequency.isNotEmpty) item.frequency,
                    ].join(' · '),
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.text.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: tokens.space.sm),
          Text(
            '$currency ${_format(item.amount)}',
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.primary,
              fontWeight: FontWeight.w600,
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
