// SPDX-License-Identifier: Proprietary
// Per-batch reconciliation detail — read-only.
//
// Renders the batch's row-level reconciliation records
// (one row per attempted create / update) with the
// per-row status (pending / approved / rejected / skipped /
// error) + the server's note + the first 3 payload
// key/value pairs. The detail surface is read-only today;
// the future per-row approve / skip write flow is part of
// the data import wizard follow-up.
//
// The screen also surfaces the batch's top-line summary
// (status, source label, package hash, created-at) as a
// sticky header so the operator has the context at hand
// when scanning the rows.
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)]; the chevron mirrors itself
// under RTL so the visual flow stays consistent with the
// text direction.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../data/data_import.dart';
import '../data/data_import_providers.dart';

class DataImportBatchDetailScreen extends ConsumerWidget {
  const DataImportBatchDetailScreen({required this.batch, super.key});
  final String batch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final reconciliationAsync =
        ref.watch(dataImportReconciliationProvider(batch));
    final batchesAsync = ref.watch(dataImportBatchesProvider);
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.dataImportsBatchDetailTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(dataImportReconciliationProvider(batch));
              ref.invalidate(dataImportBatchesProvider);
            },
          ),
        ],
      ),
      body: reconciliationAsync.when(
        data: (page) {
          // Resolve the batch summary from the (refreshed) list
          // so the header reflects the current server state.
          final DataImportBatch? summary = batchesAsync.value
              ?.batches
              .where((b) => b.name == batch)
              .firstOrNull;
          return _buildBody(
            context,
            ref,
            tokens,
            page,
            summary,
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
            onPressed: () => ref
                .read(dataImportReconciliationProvider(batch).notifier)
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
    DataImportRecordPage page,
    DataImportBatch? summary,
  ) {
    final l = AppLocalizations.of(context);
    return RefreshIndicator(
      color: tokens.brand.primary,
      onRefresh: () => ref
          .read(dataImportReconciliationProvider(batch).notifier)
          .refresh(),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.space.md,
          tokens.space.md,
          tokens.space.md,
          tokens.space.xl,
        ),
        children: [
          _Header(tokens: tokens, batch: summary),
          SizedBox(height: tokens.space.lg),
          Text(
            l.dataImportsReconciliationHeader(page.records.length),
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          if (page.isEmpty)
            LsStateView.empty(
              icon: Icons.checklist_outlined,
              title: l.dataImportsReconciliationEmptyTitle,
              message: l.dataImportsReconciliationEmptyMessage,
            )
          else
            for (var i = 0; i < page.records.length; i++) ...[
              if (i > 0) SizedBox(height: tokens.space.sm),
              _RecordCard(tokens: tokens, record: page.records[i]),
            ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.tokens, required this.batch});
  final DesignTokens tokens;
  final DataImportBatch? batch;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (batch == null) {
      // Fallback when the list hasn't loaded yet — show a
      // minimal header with the batch id so the operator can
      // at least confirm they're on the right page.
      return Container(
        padding: EdgeInsets.all(tokens.space.md),
        decoration: BoxDecoration(
          color: tokens.surface.surface,
          borderRadius: BorderRadius.circular(tokens.radius.md),
          border: Border.all(color: tokens.surface.outlineVariant),
        ),
        child: Text(
          l.dataImportsBatchFallbackHeader,
          style: tokens.typography.bodyMedium.copyWith(
            color: tokens.text.secondary,
          ),
        ),
      );
    }
    final (LsChipTone tone, IconData icon) = switch (batch!.statusFamily) {
      'success' => (LsChipTone.success, Icons.check_circle_outline),
      'error' => (LsChipTone.error, Icons.error_outline),
      'info' => (LsChipTone.info, Icons.hourglass_top_outlined),
      'warning' => (LsChipTone.warning, Icons.warning_amber_outlined),
      _ => (LsChipTone.neutral, Icons.archive_outlined),
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
              Icon(icon, color: _toneFg(tokens, tone), size: 22),
              SizedBox(width: tokens.space.sm),
              Expanded(
                child: Text(
                  batch!.name,
                  style: tokens.typography.titleMedium.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
              ),
              LsStatusChip(
                label: batch!.status,
                tone: tone,
                icon: icon,
              ),
            ],
          ),
          if (batch!.sourceLabel.isNotEmpty) ...[
            SizedBox(height: tokens.space.xs),
            Text(
              batch!.sourceLabel,
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.text.secondary,
              ),
            ),
          ],
          if (batch!.createdAt.isNotEmpty) ...[
            SizedBox(height: tokens.space.xxs),
            Text(
              l.dataImportsBatchCreatedAt(batch!.createdAt),
              style: tokens.typography.labelSmall.copyWith(
                color: tokens.text.tertiary,
              ),
            ),
          ],
          if (batch!.shortHash.isNotEmpty) ...[
            SizedBox(height: tokens.space.xs),
            LsStatusChip(
              label: l.dataImportsHashChip(batch!.shortHash),
              tone: LsChipTone.neutral,
              icon: Icons.tag,
            ),
          ],
        ],
      ),
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

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.tokens, required this.record});
  final DesignTokens tokens;
  final DataImportRecord record;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (LsChipTone tone, IconData icon) = switch (record.statusFamily) {
      'success' => (LsChipTone.success, Icons.check_circle_outline),
      'error' => (LsChipTone.error, Icons.error_outline),
      'warning' => (LsChipTone.warning, Icons.skip_next_outlined),
      'info' => (LsChipTone.info, Icons.hourglass_top_outlined),
      _ => (LsChipTone.neutral, Icons.help_outline),
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
              Icon(icon, color: _toneFg(tokens, tone), size: 18),
              SizedBox(width: tokens.space.xs),
              Expanded(
                child: Text(
                  record.doctype.isEmpty
                      ? l.dataImportsReconciliationDoctypeFallback
                      : record.doctype,
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
              ),
              LsStatusChip(
                label: record.status,
                tone: tone,
                icon: icon,
              ),
            ],
          ),
          SizedBox(height: tokens.space.xxs),
          if (record.rowIndex > 0)
            Text(
              l.dataImportsReconciliationRowIndex(record.rowIndex),
              style: tokens.typography.labelSmall.copyWith(
                color: tokens.text.tertiary,
              ),
            ),
          if (record.message.isNotEmpty) ...[
            SizedBox(height: tokens.space.xs),
            Text(
              record.message,
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.text.secondary,
              ),
            ),
          ],
          if (record.payload.isNotEmpty) ...[
            SizedBox(height: tokens.space.xs),
            Wrap(
              spacing: tokens.space.xs,
              runSpacing: tokens.space.xxs,
              children: [
                for (final entry in record.payload.entries.take(3))
                  LsStatusChip(
                    label: l.dataImportsPayloadChip(
                      entry.key,
                      entry.value?.toString() ?? '',
                    ),
                    tone: LsChipTone.neutral,
                    icon: Icons.data_object_outlined,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
