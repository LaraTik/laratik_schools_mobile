// SPDX-License-Identifier: Proprietary
// Admin "Grading" surface — read-only overview + policies +
// write flows.
//
// The screen has two tabs:
//   * **Overview** — top-level KPIs (total / published /
//     draft grades + school-wide average + pass rate) + the
//     workflow stages (draft → submitted → promoted → ...)
//     as a chip strip + a feature / coverage sub-line.
//   * **Policies** — the list of subject grade policies
//     with the subject, grade band, pass threshold, and
//     approval status per row. Each row ships a per-policy
//     **Approve** action (calls
//     `approve_school_subject_grade_policy`); the AppBar
//     also ships a **Promote** action that opens a 2-field
//     prompt (assessment result id + policy name) and calls
//     `promote_school_assessment_result`.
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)]; the chevron mirrors itself
// under RTL so the visual flow stays consistent with the
// text direction.
//
// Reachable from a "Grading" tile on the admin home
// (capability-gated on `can_manage_branches` — same
// admin-only gate as the Operations + Governance tiles) at
// `/shell/grading`.

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
import '../data/grading_failure.dart';
import '../data/grading_overview.dart';
import '../data/grading_providers.dart';

/// Read-only grading admin surface. Two tabs (Overview /
/// Policies). Reachable from `/shell/grading`.
class GradingScreen extends ConsumerWidget {
  const GradingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: tokens.surface.canvas,
        appBar: AppBar(
          backgroundColor: tokens.surface.surface,
          elevation: 0,
          title: Text(
            l.gradingScreenTitle,
            style: tokens.typography.titleLarge.copyWith(
              color: tokens.text.primary,
            ),
          ),
          actions: [
            IconButton(
              tooltip: l.gradingCorrectionAction,
              icon: const Icon(Icons.assignment_turned_in_outlined),
              onPressed: () => _showGradeIdPrompt(context, l),
            ),
            IconButton(
              tooltip: l.gradingPromoteAction,
              icon: const Icon(Icons.upgrade_outlined),
              onPressed: () => _showPromoteResultPrompt(context, ref, l),
            ),
            IconButton(
              tooltip: l.commonRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(gradingOverviewProvider);
                ref.invalidate(gradingPoliciesProvider);
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
                  Tab(text: l.gradingTabOverview),
                  Tab(text: l.gradingTabPolicies),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _OverviewTab(),
            _PoliciesTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overview tab
// ---------------------------------------------------------------------------

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(gradingOverviewProvider);
    return async.when(
      data: (result) => switch (result) {
        Ok(:final value) => _buildBody(context, tokens, value),
        Err(:final error) => _buildError(
            context,
            tokens,
            ref,
            error,
            l.gradingErrorTitle,
          ),
      },
      loading: () => LsStateView.loading(
        title: l.gradingLoadingTitle,
        message: l.gradingLoadingMessage,
      ),
      error: (err, _) => LsStateView.error(
        icon: Icons.error_outline,
        title: l.gradingErrorTitle,
        message: err.toString(),
        action: LsButton.primary(
          label: l.commonTryAgain,
          expand: false,
          onPressed: () => ref.invalidate(gradingOverviewProvider),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DesignTokens tokens,
    GradingOverview overview,
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
        _KpiRow(tokens: tokens, overview: overview),
        SizedBox(height: tokens.space.lg),
        if (overview.workflowStages.isNotEmpty) ...[
          Text(
            l.gradingWorkflowHeader,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          _WorkflowStrip(tokens: tokens, stages: overview.workflowStages),
          SizedBox(height: tokens.space.lg),
        ],
        _FeatureCard(tokens: tokens, overview: overview),
      ],
    );
  }

  Widget _buildError(
    BuildContext context,
    DesignTokens tokens,
    WidgetRef ref,
    GradingFailure error,
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
        onPressed: () => ref.invalidate(gradingOverviewProvider),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.tokens, required this.overview});
  final DesignTokens tokens;
  final GradingOverview overview;

  @override
  Widget build(BuildContext context) {
    final items = <_KpiData>[
      _KpiData(
        label: context_localization_label(context, 'gradingKpiTotal'),
        value: overview.totalGrades.toString(),
        sub: context_localization_label(context, 'gradingKpiTotalSubtitle'),
        icon: Icons.assignment_outlined,
        tone: LsChipTone.brand,
      ),
      _KpiData(
        label: context_localization_label(context, 'gradingKpiPublished'),
        value: overview.publishedGrades.toString(),
        sub: context_localization_label(context, 'gradingKpiPublishedSubtitle'),
        icon: Icons.check_circle_outline,
        tone: LsChipTone.success,
      ),
      _KpiData(
        label: context_localization_label(context, 'gradingKpiDraft'),
        value: overview.draftGrades.toString(),
        sub: context_localization_label(context, 'gradingKpiDraftSubtitle'),
        icon: Icons.edit_outlined,
        tone: LsChipTone.warning,
      ),
      _KpiData(
        label: context_localization_label(context, 'gradingKpiAverage'),
        value: overview.publishedGrades == 0
            ? '—'
            : '${overview.averageScore.toStringAsFixed(0)}%',
        sub: context_localization_label(context, 'gradingKpiAverageSubtitle'),
        icon: Icons.percent_outlined,
        tone: overview.publishedGrades == 0
            ? LsChipTone.neutral
            : LsChipTone.info,
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

  /// Tiny forwarder so the KPI data construction can use a
  /// const label list (the actual `AppLocalizations` lookups
  /// happen inside [build]).
  String context_localization_label(BuildContext context, String key) {
    final l = AppLocalizations.of(context);
    return switch (key) {
      'gradingKpiTotal' => l.gradingKpiTotal,
      'gradingKpiTotalSubtitle' => l.gradingKpiTotalSubtitle,
      'gradingKpiPublished' => l.gradingKpiPublished,
      'gradingKpiPublishedSubtitle' => l.gradingKpiPublishedSubtitle,
      'gradingKpiDraft' => l.gradingKpiDraft,
      'gradingKpiDraftSubtitle' => l.gradingKpiDraftSubtitle,
      'gradingKpiAverage' => l.gradingKpiAverage,
      'gradingKpiAverageSubtitle' => l.gradingKpiAverageSubtitle,
      _ => key,
    };
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _WorkflowStrip extends StatelessWidget {
  const _WorkflowStrip({required this.tokens, required this.stages});
  final DesignTokens tokens;
  final List<GradingWorkflowStage> stages;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: tokens.space.xs,
      runSpacing: tokens.space.xxs,
      children: [
        for (final stage in stages)
          LsStatusChip(
            label: '${stage.label} · ${stage.count}',
            tone: _toneFor(stage.toneFamily),
            icon: _iconFor(stage.stageFamily),
          ),
      ],
    );
  }

  LsChipTone _toneFor(String family) {
    return switch (family) {
      'success' => LsChipTone.success,
      'warning' => LsChipTone.warning,
      'error' => LsChipTone.error,
      'info' => LsChipTone.info,
      _ => LsChipTone.neutral,
    };
  }

  IconData _iconFor(String stageFamily) {
    return switch (stageFamily) {
      'draft' => Icons.edit_outlined,
      'submitted' => Icons.hourglass_top_outlined,
      'promoted' => Icons.check_circle_outline,
      'corrected' => Icons.assignment_turned_in_outlined,
      'rejected' => Icons.cancel_outlined,
      _ => Icons.help_outline,
    };
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.tokens, required this.overview});
  final DesignTokens tokens;
  final GradingOverview overview;

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
            l.gradingFeatureHeader,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.xs),
          if (overview.feature.isNotEmpty)
            Text(
              l.gradingFeatureValue(overview.feature),
              style: tokens.typography.bodyMedium.copyWith(
                color: tokens.text.primary,
              ),
            ),
          if (overview.coverage.isNotEmpty) ...[
            SizedBox(height: tokens.space.xxs),
            Text(
              l.gradingCoverageValue(overview.coverage),
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.text.secondary,
              ),
            ),
          ],
          if (overview.recentStudents.isNotEmpty) ...[
            SizedBox(height: tokens.space.xxs),
            Text(
              l.gradingRecentStudentsValue(overview.recentStudents),
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.text.tertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Policies tab
// ---------------------------------------------------------------------------

class _PoliciesTab extends ConsumerWidget {
  const _PoliciesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(gradingPoliciesProvider);
    return async.when(
      data: (view) => _buildBody(context, ref, tokens, view),
      loading: () => LsStateView.loading(
        title: l.gradingLoadingTitle,
        message: l.gradingLoadingMessage,
      ),
      error: (err, _) => LsStateView.error(
        icon: Icons.error_outline,
        title: l.gradingErrorTitle,
        message: err.toString(),
        action: LsButton.primary(
          label: l.commonTryAgain,
          expand: false,
          onPressed: () => ref.read(gradingPoliciesProvider.notifier).refresh(),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DesignTokens tokens,
    GradingPoliciesView view,
  ) {
    final l = AppLocalizations.of(context);
    final policies = view.page.policies;
    return RefreshIndicator(
      color: tokens.brand.primary,
      onRefresh: () => ref.read(gradingPoliciesProvider.notifier).refresh(),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          tokens.space.md,
          tokens.space.md,
          tokens.space.md,
          tokens.space.xl,
        ),
        itemCount: policies.length + 1,
        separatorBuilder: (_, __) => SizedBox(height: tokens.space.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _PermissionsCard(
              tokens: tokens,
              setup: view.setup,
            );
          }
          return _PolicyRow(tokens: tokens, policy: policies[index - 1]);
        },
      ),
    );
  }
}

class _PermissionsCard extends StatelessWidget {
  const _PermissionsCard({required this.tokens, required this.setup});
  final DesignTokens tokens;
  final GradingPolicySetupContext setup;

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
              Icon(Icons.shield_outlined, color: tokens.brand.primary),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Text(
                  l.gradingPermissionsHeader,
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
              ),
            ],
          ),
          if (setup.managedDoctypes.isNotEmpty) ...[
            SizedBox(height: tokens.space.xs),
            Text(
              l.gradingPermissionsDoctypesValue(setup.managedDoctypes),
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.text.secondary,
              ),
            ),
          ],
          if (setup.readRoles.isNotEmpty) ...[
            SizedBox(height: tokens.space.sm),
            Text(
              l.gradingPermissionsReadRoles,
              style: tokens.typography.labelMedium.copyWith(
                color: tokens.text.secondary,
              ),
            ),
            SizedBox(height: tokens.space.xxs),
            Wrap(
              spacing: tokens.space.xs,
              runSpacing: tokens.space.xxs,
              children: [
                for (final role in setup.readRoles)
                  LsStatusChip(
                    label: role,
                    tone: LsChipTone.info,
                    icon: Icons.visibility_outlined,
                  ),
              ],
            ),
          ],
          if (setup.requiredRoles.isNotEmpty) ...[
            SizedBox(height: tokens.space.sm),
            Text(
              l.gradingPermissionsRequiredRoles,
              style: tokens.typography.labelMedium.copyWith(
                color: tokens.text.secondary,
              ),
            ),
            SizedBox(height: tokens.space.xxs),
            Wrap(
              spacing: tokens.space.xs,
              runSpacing: tokens.space.xxs,
              children: [
                for (final role in setup.requiredRoles)
                  LsStatusChip(
                    label: role,
                    tone: LsChipTone.warning,
                    icon: Icons.gavel_outlined,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PolicyRow extends ConsumerStatefulWidget {
  const _PolicyRow({required this.tokens, required this.policy});
  final DesignTokens tokens;
  final SubjectGradePolicy policy;

  @override
  ConsumerState<_PolicyRow> createState() => _PolicyRowState();
}

class _PolicyRowState extends ConsumerState<_PolicyRow> {
  bool _approving = false;

  bool get _isApprovable =>
      widget.policy.statusFamily != 'approved' &&
      widget.policy.statusFamily != 'rejected';

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final policy = widget.policy;
    final l = AppLocalizations.of(context);
    return Material(
      color: tokens.surface.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.surface.outlineVariant),
      ),
      child: Semantics(
        button: true,
        label: policy.name,
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tokens.brand.primaryContainer,
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.assignment_outlined,
                  color: tokens.brand.onPrimaryContainer,
                  size: 22,
                ),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      policy.name.isEmpty ? policy.id : policy.name,
                      style: tokens.typography.titleSmall.copyWith(
                        color: tokens.text.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (policy.subject.isNotEmpty) ...[
                      SizedBox(height: tokens.space.xxs),
                      Text(
                        policy.subject,
                        style: tokens.typography.bodySmall.copyWith(
                          color: tokens.text.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: tokens.space.xs),
                    Wrap(
                      spacing: tokens.space.xs,
                      runSpacing: tokens.space.xxs,
                      children: [
                        if (policy.gradeBand.isNotEmpty)
                          LsStatusChip(
                            label: policy.gradeBand,
                            tone: LsChipTone.info,
                            icon: Icons.layers_outlined,
                          ),
                        LsStatusChip(
                          label: l.gradingPassThresholdValue(
                            policy.passThreshold.toStringAsFixed(0),
                          ),
                          tone: LsChipTone.brand,
                          icon: Icons.percent_outlined,
                        ),
                        LsStatusChip(
                          label: policy.status,
                          tone: _toneFor(policy.statusFamily),
                          icon: _iconFor(policy.statusFamily),
                        ),
                      ],
                    ),
                    if (policy.approver.isNotEmpty ||
                        policy.approvedAt.isNotEmpty) ...[
                      SizedBox(height: tokens.space.xxs),
                      Text(
                        _approvalLine(policy),
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
              // Per-row "Approve" action. Disabled once the
              // policy is already approved or rejected so the
              // admin doesn't accidentally re-call the write
              // flow on a terminal state.
              if (_isApprovable)
                IconButton(
                  tooltip: l.gradingApprovePolicyAction,
                  icon: _approving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: tokens.brand.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  onPressed: _approving
                      ? null
                      : () => _onApprove(context, policy),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onApprove(
    BuildContext context,
    SubjectGradePolicy policy,
  ) async {
    final l = AppLocalizations.of(context);
    final tokens = widget.tokens;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _approving = true);
    final result = await approveSubjectGradePolicy(
      ref,
      policyName: policy.id,
    );
    if (!context.mounted) return;
    setState(() => _approving = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          switch (result) {
            Ok() => l.gradingApprovePolicySuccess(policy.name),
            Err(:final error) => l.gradingApprovePolicyError(
                (error as GradingFailure).message,
              ),
          },
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: switch (result) {
          Ok() => tokens.status.success,
          Err() => tokens.status.error,
        },
      ),
    );
  }

  String _approvalLine(SubjectGradePolicy policy) {
    final parts = <String>[];
    if (policy.approver.isNotEmpty) parts.add(policy.approver);
    if (policy.approvedAt.isNotEmpty) parts.add(policy.approvedAt);
    return parts.join(' · ');
  }

  LsChipTone _toneFor(String family) {
    return switch (family) {
      'approved' => LsChipTone.success,
      'rejected' => LsChipTone.error,
      'pending' => LsChipTone.warning,
      _ => LsChipTone.neutral,
    };
  }

  IconData _iconFor(String family) {
    return switch (family) {
      'approved' => Icons.check_circle_outline,
      'rejected' => Icons.cancel_outlined,
      'pending' => Icons.hourglass_top_outlined,
      _ => Icons.help_outline,
    };
  }
}

/// Show a quick prompt that asks the admin for the grade
/// id + pushes the correction form at
/// `/shell/grading/correct/:gradeName`. The v1 server
/// doesn't expose a "list grade records" endpoint on the
/// mobile SDK today, so the admin enters the grade id
/// (the same way the teacher exam manual-grade form
/// asks for the attempt id).
Future<void> _showGradeIdPrompt(
  BuildContext context,
  AppLocalizations l,
) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(l.gradingCorrectionPromptTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l.gradingCorrectionGradeLabel,
            hintText: l.gradingCorrectionPromptHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.commonCancel),
          ),
          FilledButton.tonal(
            onPressed: () {
              final id = controller.text.trim();
              if (id.isEmpty) return;
              Navigator.of(ctx).pop(id);
            },
            child: Text(l.commonContinue),
          ),
        ],
      );
    },
  );
  if (result == null || result.isEmpty || !context.mounted) return;
  context.go('/shell/grading/correct/$result');
}

/// Show a 2-field prompt that asks the admin for the
/// assessment result id + the policy name, then calls
/// `promote_school_assessment_result` on Continue. The
/// v1 SDK doesn't expose a "list assessment results"
/// endpoint on the mobile SDK today, so the admin
/// enters both ids (the same pattern as the
/// "Correct a grade" prompt + the teacher manual-grade
/// form).
Future<void> _showPromoteResultPrompt(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l,
) async {
  final resultController = TextEditingController();
  final policyController = TextEditingController();
  final result = await showDialog<(String, String)>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(l.gradingPromotePromptTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: resultController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l.gradingPromoteResultLabel,
                  hintText: l.gradingPromoteResultHint,
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: policyController,
                decoration: InputDecoration(
                  labelText: l.gradingPromotePolicyLabel,
                  hintText: l.gradingPromotePolicyHint,
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
              final result = resultController.text.trim();
              final policy = policyController.text.trim();
              if (result.isEmpty || policy.isEmpty) return;
              Navigator.of(ctx).pop((result, policy));
            },
            child: Text(l.commonContinue),
          ),
        ],
      );
    },
  );
  if (result == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  final tokens = context.laratik;
  final outcome = await promoteAssessmentResult(
    ref,
    assessmentResultName: result.$1,
    policyName: result.$2,
  );
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        switch (outcome) {
          Ok(:final value) => value.hasGradeRecord
              ? l.gradingPromoteSuccess(value.gradeRecord)
              : l.gradingPromoteSuccessFallback,
          Err(:final error) => l.gradingPromoteError(
              (error as GradingFailure).message,
            ),
        },
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: switch (outcome) {
        Ok() => tokens.status.success,
        Err() => tokens.status.error,
      },
    ),
  );
}
