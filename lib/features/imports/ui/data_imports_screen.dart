// SPDX-License-Identifier: Proprietary
// Admin "Data imports" surface — read-only data imports +
// score imports catalog.
//
// The screen has two tabs:
//   * **Batches** — past data import batches (each row
//     shows status chip, source label, package hash, row
//     count chip strip, created-at sub-line). Each row
//     tappable into the per-batch reconciliation detail
//     (`/shell/imports/:batchId`).
//   * **Score imports** — past score imports (each row
//     shows status chip, source label, file hash, column
//     count, created-at sub-line). Each row tappable into
//     the per-import detail
//     (`/shell/imports/scores/:scoreImportId`).
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)]; the chevron mirrors itself
// under RTL so the visual flow stays consistent with the
// text direction.
//
// The full upload + dry-run + review + approve + commit
// wizard for the data import slice is deferred to a follow-
// up turn (the v1 SDK's
// `upload_school_data_import_package` expects a pre-uploaded
// `package_file` which is outside the SDK scope today).
// The score import slice DOES ship "Validate" + "Commit"
// buttons on the detail screen because the v1 SDK already
// exposes those write endpoints.
//
// Reachable from a "Data imports" tile on the admin home
// (capability-gated on `can_manage_branches` — admin-only;
// the v1 server does not yet expose a dedicated
// `can_view_imports` capability) at `/shell/imports`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../data/data_import.dart';
import '../data/data_import_providers.dart';

/// Read-only data imports surface. Two tabs (Batches / Score
/// imports). Reachable from `/shell/imports`.
class DataImportsScreen extends ConsumerWidget {
  const DataImportsScreen({super.key});

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
            l.dataImportsScreenTitle,
            style: tokens.typography.titleLarge.copyWith(
              color: tokens.text.primary,
            ),
          ),
          actions: [
            IconButton(
              tooltip: l.commonRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(dataImportBatchesProvider);
                ref.invalidate(scoreImportsProvider);
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
                  Tab(text: l.dataImportsTabBatches),
                  Tab(text: l.dataImportsTabScoreImports),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _BatchesTab(),
            _ScoreImportsTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Batches tab
// ---------------------------------------------------------------------------

class _BatchesTab extends ConsumerWidget {
  const _BatchesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(dataImportBatchesProvider);
    return async.when(
      data: (page) {
        if (page.isEmpty) {
          return LsStateView.empty(
            icon: Icons.archive_outlined,
            title: l.dataImportsBatchesEmptyTitle,
            message: l.dataImportsBatchesEmptyMessage,
          );
        }
        return RefreshIndicator(
          color: tokens.brand.primary,
          onRefresh: () =>
              ref.read(dataImportBatchesProvider.notifier).refresh(),
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              tokens.space.md,
              tokens.space.md,
              tokens.space.md,
              tokens.space.xl,
            ),
            itemCount: page.batches.length,
            separatorBuilder: (_, __) => SizedBox(height: tokens.space.sm),
            itemBuilder: (context, index) {
              return _BatchCard(
                tokens: tokens,
                batch: page.batches[index],
              );
            },
          ),
        );
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
          onPressed: () =>
              ref.read(dataImportBatchesProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  const _BatchCard({required this.tokens, required this.batch});
  final DesignTokens tokens;
  final DataImportBatch batch;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (LsChipTone tone, IconData icon) = _toneForStatus(batch);
    return Material(
      color: tokens.surface.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.surface.outlineVariant),
      ),
      child: InkWell(
        onTap: () => context.go(
          '/shell/imports/${Uri.encodeComponent(batch.name)}',
        ),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _toneContainer(tokens, tone),
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Icon(icon, color: _toneFg(tokens, tone), size: 22),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            batch.name,
                            style: tokens.typography.titleSmall.copyWith(
                              color: tokens.text.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: tokens.space.xs),
                        LsStatusChip(
                          label: batch.status,
                          tone: tone,
                          icon: icon,
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.space.xxs),
                    if (batch.sourceLabel.isNotEmpty)
                      Text(
                        batch.sourceLabel,
                        style: tokens.typography.bodySmall.copyWith(
                          color: tokens.text.secondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (batch.createdAt.isNotEmpty) ...[
                      SizedBox(height: tokens.space.xxs),
                      Text(
                        l.dataImportsBatchCreatedAt(batch.createdAt),
                        style: tokens.typography.labelSmall.copyWith(
                          color: tokens.text.tertiary,
                        ),
                      ),
                    ],
                    if (batch.shortHash.isNotEmpty ||
                        batch.rowCounts.isNotEmpty) ...[
                      SizedBox(height: tokens.space.xs),
                      Wrap(
                        spacing: tokens.space.xs,
                        runSpacing: tokens.space.xxs,
                        children: [
                          if (batch.shortHash.isNotEmpty)
                            LsStatusChip(
                              label: l.dataImportsHashChip(batch.shortHash),
                              tone: LsChipTone.neutral,
                              icon: Icons.tag,
                            ),
                          for (final entry
                              in batch.rowCounts.entries.take(4))
                            LsStatusChip(
                              label: _formatCountChip(
                                context,
                                key: entry.key,
                                value: entry.value,
                              ),
                              tone: LsChipTone.info,
                              icon: Icons.numbers_outlined,
                            ),
                        ],
                      ),
                    ],
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

  String _formatCountChip(
    BuildContext context, {
    required String key,
    required Object? value,
  }) {
    final l = AppLocalizations.of(context);
    final v = value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;
    return l.dataImportsRowCountChip(key, v);
  }
}

(LsChipTone, IconData) _toneForStatus(DataImportBatch batch) {
  switch (batch.statusFamily) {
    case 'success':
      return (LsChipTone.success, Icons.check_circle_outline);
    case 'error':
      return (LsChipTone.error, Icons.error_outline);
    case 'info':
      return (LsChipTone.info, Icons.hourglass_top_outlined);
    case 'warning':
      return (LsChipTone.warning, Icons.warning_amber_outlined);
    default:
      return (LsChipTone.neutral, Icons.archive_outlined);
  }
}

Color _toneContainer(DesignTokens tokens, LsChipTone tone) {
  return switch (tone) {
    LsChipTone.success => tokens.status.successContainer,
    LsChipTone.warning => tokens.status.warningContainer,
    LsChipTone.error => tokens.status.errorContainer,
    LsChipTone.info => tokens.status.infoContainer,
    LsChipTone.brand => tokens.brand.primaryContainer,
    LsChipTone.neutral => tokens.surface.surfaceContainer,
  };
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

// ---------------------------------------------------------------------------
// Score imports tab
// ---------------------------------------------------------------------------

class _ScoreImportsTab extends ConsumerWidget {
  const _ScoreImportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(scoreImportsProvider);
    return async.when(
      data: (page) {
        if (page.isEmpty) {
          return LsStateView.empty(
            icon: Icons.scoreboard_outlined,
            title: l.dataImportsScoreEmptyTitle,
            message: l.dataImportsScoreEmptyMessage,
          );
        }
        return RefreshIndicator(
          color: tokens.brand.primary,
          onRefresh: () =>
              ref.read(scoreImportsProvider.notifier).refresh(),
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              tokens.space.md,
              tokens.space.md,
              tokens.space.md,
              tokens.space.xl,
            ),
            itemCount: page.scoreImports.length,
            separatorBuilder: (_, __) => SizedBox(height: tokens.space.sm),
            itemBuilder: (context, index) {
              return _ScoreImportCard(
                tokens: tokens,
                scoreImport: page.scoreImports[index],
              );
            },
          ),
        );
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
          onPressed: () =>
              ref.read(scoreImportsProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _ScoreImportCard extends StatelessWidget {
  const _ScoreImportCard({required this.tokens, required this.scoreImport});
  final DesignTokens tokens;
  final ScoreImport scoreImport;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (LsChipTone tone, IconData icon) = _toneForScoreImport(scoreImport);
    return Material(
      color: tokens.surface.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.surface.outlineVariant),
      ),
      child: InkWell(
        onTap: () => context.go(
          '/shell/imports/scores/${Uri.encodeComponent(scoreImport.name)}',
        ),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _toneContainer(tokens, tone),
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Icon(icon, color: _toneFg(tokens, tone), size: 22),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            scoreImport.name,
                            style: tokens.typography.titleSmall.copyWith(
                              color: tokens.text.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: tokens.space.xs),
                        LsStatusChip(
                          label: scoreImport.status,
                          tone: tone,
                          icon: icon,
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.space.xxs),
                    if (scoreImport.sourceLabel.isNotEmpty)
                      Text(
                        scoreImport.sourceLabel,
                        style: tokens.typography.bodySmall.copyWith(
                          color: tokens.text.secondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (scoreImport.createdAt.isNotEmpty) ...[
                      SizedBox(height: tokens.space.xxs),
                      Text(
                        l.dataImportsScoreCreatedAt(scoreImport.createdAt),
                        style: tokens.typography.labelSmall.copyWith(
                          color: tokens.text.tertiary,
                        ),
                      ),
                    ],
                    if (scoreImport.shortHash.isNotEmpty ||
                        scoreImport.columns.isNotEmpty) ...[
                      SizedBox(height: tokens.space.xs),
                      Wrap(
                        spacing: tokens.space.xs,
                        runSpacing: tokens.space.xxs,
                        children: [
                          if (scoreImport.shortHash.isNotEmpty)
                            LsStatusChip(
                              label: l.dataImportsHashChip(
                                scoreImport.shortHash,
                              ),
                              tone: LsChipTone.neutral,
                              icon: Icons.tag,
                            ),
                          LsStatusChip(
                            label: l.dataImportsScoreColumnsChip(
                              scoreImport.columns.length,
                            ),
                            tone: LsChipTone.info,
                            icon: Icons.view_column_outlined,
                          ),
                        ],
                      ),
                    ],
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

(LsChipTone, IconData) _toneForScoreImport(ScoreImport scoreImport) {
  switch (scoreImport.statusFamily) {
    case 'success':
      return (LsChipTone.success, Icons.check_circle_outline);
    case 'error':
      return (LsChipTone.error, Icons.error_outline);
    case 'info':
      return (LsChipTone.info, Icons.verified_outlined);
    case 'warning':
      return (LsChipTone.warning, Icons.edit_outlined);
    default:
      return (LsChipTone.neutral, Icons.scoreboard_outlined);
  }
}
