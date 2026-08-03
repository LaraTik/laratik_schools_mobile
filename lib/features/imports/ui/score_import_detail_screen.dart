// SPDX-License-Identifier: Proprietary
// Per-score-import detail — read-only summary + Validate /
// Commit action buttons.
//
// The detail surface shows:
//   * Status chip + source label + file hash + created-at.
//   * The mapped columns (source → target) as a chip strip
//     so the operator can audit the mapping at a glance.
//   * The per-stage counts from the validate step (if the
//     server returned any) as a small KPI strip.
//   * **Validate** button — re-runs
//     `validate_school_score_import` to refresh the counts.
//   * **Commit** button — promotes the validated score
//     import via `commit_school_score_import` and refreshes
//     the list.
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)]; the chevron mirrors itself
// under RTL so the visual flow stays consistent with the
// text direction.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../data/data_import.dart';
import '../data/data_import_providers.dart';

class ScoreImportDetailScreen extends ConsumerWidget {
  const ScoreImportDetailScreen({required this.scoreImport, super.key});
  final String scoreImport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(scoreImportDetailProvider(scoreImport));
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.dataImportsScoreDetailTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(scoreImportDetailProvider(scoreImport).notifier)
                .refresh(),
          ),
        ],
      ),
      body: async.when(
        data: (entry) {
          if (entry == null) {
            return LsStateView.empty(
              icon: Icons.scoreboard_outlined,
              title: l.dataImportsScoreNotFoundTitle,
              message: l.dataImportsScoreNotFoundMessage,
            );
          }
          return _buildBody(context, ref, tokens, entry);
        },
        loading: () => LsStateView.loading(
          title: l.dataImportsLoadingTitle,
          message: l.dataImportsLoadingMessage,
        ),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: l.dataImportsErrorTitle,
          message: err.toString(),
          action: LsButton.primary(
            label: l.commonTryAgain,
            expand: false,
            onPressed: () => ref
                .read(scoreImportDetailProvider(scoreImport).notifier)
                .refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DesignTokens tokens,
    ScoreImport entry,
  ) {
    final l = AppLocalizations.of(context);
    final (LsChipTone tone, IconData icon) = switch (entry.statusFamily) {
      'success' => (LsChipTone.success, Icons.check_circle_outline),
      'error' => (LsChipTone.error, Icons.error_outline),
      'info' => (LsChipTone.info, Icons.verified_outlined),
      'warning' => (LsChipTone.warning, Icons.edit_outlined),
      _ => (LsChipTone.neutral, Icons.scoreboard_outlined),
    };
    return ListView(
      padding: EdgeInsets.fromLTRB(
        tokens.space.md,
        tokens.space.md,
        tokens.space.md,
        tokens.space.xl,
      ),
      children: [
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
                  Icon(icon, color: _toneFg(tokens, tone), size: 22),
                  SizedBox(width: tokens.space.sm),
                  Expanded(
                    child: Text(
                      entry.name,
                      style: tokens.typography.titleMedium.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                  ),
                  LsStatusChip(
                    label: entry.status,
                    tone: tone,
                    icon: icon,
                  ),
                ],
              ),
              if (entry.sourceLabel.isNotEmpty) ...[
                SizedBox(height: tokens.space.xs),
                Text(
                  entry.sourceLabel,
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.text.secondary,
                  ),
                ),
              ],
              if (entry.createdAt.isNotEmpty) ...[
                SizedBox(height: tokens.space.xxs),
                Text(
                  l.dataImportsScoreCreatedAt(entry.createdAt),
                  style: tokens.typography.labelSmall.copyWith(
                    color: tokens.text.tertiary,
                  ),
                ),
              ],
              if (entry.shortHash.isNotEmpty) ...[
                SizedBox(height: tokens.space.xs),
                LsStatusChip(
                  label: l.dataImportsHashChip(entry.shortHash),
                  tone: LsChipTone.neutral,
                  icon: Icons.tag,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: tokens.space.lg),
        if (entry.columns.isNotEmpty) ...[
          Text(
            l.dataImportsScoreColumnsHeader(entry.columns.length),
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          Wrap(
            spacing: tokens.space.xs,
            runSpacing: tokens.space.xxs,
            children: [
              for (final col in entry.columns)
                LsStatusChip(
                  label: l.dataImportsScoreColumnChip(
                    col.source,
                    col.target,
                  ),
                  tone: LsChipTone.info,
                  icon: Icons.swap_horiz,
                ),
            ],
          ),
          SizedBox(height: tokens.space.lg),
        ],
        if (entry.counts.isNotEmpty) ...[
          Text(
            l.dataImportsScoreCountsHeader,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          Wrap(
            spacing: tokens.space.xs,
            runSpacing: tokens.space.xxs,
            children: [
              for (final e in entry.counts.entries.take(6))
                LsStatusChip(
                  label: l.dataImportsScoreCountChip(
                    e.key,
                    e.value.toString(),
                  ),
                  tone: LsChipTone.warning,
                  icon: Icons.numbers_outlined,
                ),
            ],
          ),
          SizedBox(height: tokens.space.lg),
        ],
        Row(
          children: [
            Expanded(
              child: LsButton.secondary(
                label: l.dataImportsScoreValidateAction,
                onPressed: () async {
                  final result = await ref
                      .read(scoreImportDetailProvider(scoreImport).notifier)
                      .validate();
                  if (!context.mounted) return;
                  switch (result) {
                    case Ok():
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.dataImportsScoreValidatedSnack)),
                      );
                    case Err(:final error):
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l.dataImportsScoreErrorSnack(error.message),
                          ),
                        ),
                      );
                  }
                },
              ),
            ),
            SizedBox(width: tokens.space.sm),
            Expanded(
              child: LsButton.primary(
                label: l.dataImportsScoreCommitAction,
                onPressed: () async {
                  final result = await ref
                      .read(scoreImportDetailProvider(scoreImport).notifier)
                      .commit();
                  if (!context.mounted) return;
                  switch (result) {
                    case Ok():
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.dataImportsScoreCommittedSnack)),
                      );
                    case Err(:final error):
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l.dataImportsScoreErrorSnack(error.message),
                          ),
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Color _toneFg(DesignTokens tokens, LsChipTone tone) {
  return switch (tone) {
    LsChipTone.success => tokens.status.success,
    LsChipTone.warning => tokens.status.warning,
    LsChipTone.error => tokens.status.error,
    LsChipTone.info => tokens.status.info,
    LsChipTone.brand => tokens.brand.onPrimaryContainer,
    LsChipTone.neutral => tokens.text.secondary,
  };
}
