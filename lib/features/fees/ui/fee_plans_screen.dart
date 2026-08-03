// SPDX-License-Identifier: Proprietary
// Fee plans list — read-only "Fee invoices" surface.
//
// Lists the fee plans owned by the current user. The v1 server
// is expected to filter to the current user when the session is
// a parent role (so the parent sees only their children's
// plans); the admin sees the full catalog. Each row tappable
// into the per-plan detail.
//
// UX:
//   * Each row shows student name, academic year, status chip,
//     total / paid / outstanding amounts.
//   * "Paid" rows render at a reduced opacity so the user can
//     see the lifecycle at a glance.
//   * Empty / loading / error / retry paths use [LsStateView].
//   * Per-status summary header so the user doesn't have to
//     count rows to know how many are overdue.
//   * Every user-facing string is locale-aware via
//     [AppLocalizations.of(context)]; the chevron mirrors itself
//     under RTL so the visual "next →" stays consistent with the
//     text direction.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../data/fee_plan.dart';
import '../data/fees_providers.dart';

class FeePlansScreen extends ConsumerWidget {
  const FeePlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(feePlansProvider);
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.feePlansScreenTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(feePlansProvider.notifier).refresh(),
          ),
        ],
      ),
      body: async.when(
        data: (page) => _buildBody(context, ref, tokens, page),
        loading: () => LsStateView.loading(
          title: l.feePlansLoadingTitle,
          message: l.feePlansLoadingMessage,
        ),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: l.feePlansErrorTitle,
          message: err.toString(),
          action: LsButton.primary(
            label: l.commonTryAgain,
            expand: false,
            onPressed: () => ref.read(feePlansProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DesignTokens tokens,
    FeePlanPage page,
  ) {
    if (page.plans.isEmpty) {
      return LsStateView.empty(
        icon: Icons.receipt_long_outlined,
        title: l_empty(context),
        message: l_empty_msg(context),
      );
    }
    // Open first (overdue + partially paid), then draft, then
    // paid. Stable order inside each group by student name.
    final sorted = [...page.plans]..sort((a, b) {
        int weight(FeePlan p) {
          switch (p.invoiceStatus.toLowerCase()) {
            case 'overdue':
            case 'partially paid':
              return 0;
            case 'issued':
              return 1;
            case 'draft':
              return 2;
            case 'paid':
            case 'cancelled':
              return 3;
            default:
              return 4;
          }
        }

        final w = weight(a).compareTo(weight(b));
        if (w != 0) return w;
        return a.studentName
            .toLowerCase()
            .compareTo(b.studentName.toLowerCase());
      });
    return RefreshIndicator(
      color: tokens.brand.primary,
      onRefresh: () => ref.read(feePlansProvider.notifier).refresh(),
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
            return _Header(tokens: tokens, plans: page.plans);
          }
          return _PlanCard(tokens: tokens, plan: sorted[index - 1]);
        },
      ),
    );
  }
}

// Forwarders so the empty-state LsStateView can stay inline without
// a long conditional in the call site.
String l_empty(BuildContext context) =>
    AppLocalizations.of(context).feePlansEmptyTitle;
String l_empty_msg(BuildContext context) =>
    AppLocalizations.of(context).feePlansEmptyMessage;

class _Header extends StatelessWidget {
  const _Header({required this.tokens, required this.plans});
  final DesignTokens tokens;
  final List<FeePlan> plans;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final overdue =
        plans.where((p) => p.invoiceStatus.toLowerCase() == 'overdue').length;
    final partiallyPaid = plans
        .where((p) => p.invoiceStatus.toLowerCase() == 'partially paid')
        .length;
    final paid = plans.where((p) => p.isPaid).length;
    final total = plans.length;
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
              Icon(Icons.receipt_long_outlined, color: tokens.brand.primary),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Text(
                  l.feePlansHeaderTotal(total),
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space.xs),
          Wrap(
            spacing: tokens.space.xs,
            runSpacing: tokens.space.xxs,
            children: [
              if (overdue > 0)
                LsStatusChip(
                  label: l.feePlansOverdueChip(overdue),
                  tone: LsChipTone.error,
                  icon: Icons.warning_amber_outlined,
                ),
              if (partiallyPaid > 0)
                LsStatusChip(
                  label: l.feePlansPartialChip(partiallyPaid),
                  tone: LsChipTone.warning,
                  icon: Icons.pie_chart_outline,
                ),
              if (paid > 0)
                LsStatusChip(
                  label: l.feePlansPaidChip(paid),
                  tone: LsChipTone.success,
                  icon: Icons.check_circle_outline,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.tokens, required this.plan});
  final DesignTokens tokens;
  final FeePlan plan;

  @override
  Widget build(BuildContext context) {
    final (LsChipTone tone, IconData icon) = _toneForStatus(plan);
    final paid = plan.isPaid;
    final amountLine = _amountLine(context);
    return Opacity(
      opacity: paid ? 0.62 : 1.0,
      child: Material(
        color: tokens.surface.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.md),
          side: BorderSide(color: tokens.surface.outlineVariant),
        ),
        child: InkWell(
          onTap: plan.id.isEmpty
              ? null
              : () => context.go(
                    '/shell/fees/plans/${Uri.encodeComponent(plan.id)}',
                  ),
          borderRadius: BorderRadius.circular(tokens.radius.md),
          child: Semantics(
            button: true,
            label: plan.studentName.isEmpty ? plan.student : plan.studentName,
            child: Padding(
              padding: EdgeInsets.all(tokens.space.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(tokens: tokens, plan: plan),
                  SizedBox(width: tokens.space.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          plan.studentName.isEmpty
                              ? plan.student
                              : plan.studentName,
                          style: tokens.typography.titleSmall.copyWith(
                            color: tokens.text.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: tokens.space.xxs),
                        Text(
                          amountLine,
                          style: tokens.typography.bodySmall.copyWith(
                            color: tokens.text.secondary,
                          ),
                        ),
                        SizedBox(height: tokens.space.xs),
                        Wrap(
                          spacing: tokens.space.xs,
                          runSpacing: tokens.space.xxs,
                          children: [
                            LsStatusChip(
                              label: _capitalize(plan.invoiceStatus),
                              tone: tone,
                              icon: icon,
                            ),
                            if (plan.academicYear.isNotEmpty)
                              LsStatusChip(
                                label: plan.academicYear,
                                tone: LsChipTone.neutral,
                                icon: Icons.calendar_today_outlined,
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

  String _amountLine(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currency = plan.currency;
    final total = _formatAmount(plan.totalAmount);
    final outstanding = _formatAmount(plan.outstandingAmount);
    if (plan.paidAmount > 0 && !plan.isPaid) {
      return l.feePlansAmountLine(currency, total, outstanding);
    }
    return l.feePlansAmountOnly(currency, total);
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

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.tokens, required this.plan});
  final DesignTokens tokens;
  final FeePlan plan;

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFrom(
      plan.studentName.isEmpty ? plan.student : plan.studentName,
    );
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: plan.isPaid
            ? tokens.surface.surfaceContainerHigh
            : tokens.brand.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: tokens.typography.titleSmall.copyWith(
          color: plan.isPaid
              ? tokens.text.secondary
              : tokens.brand.onPrimaryContainer,
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
