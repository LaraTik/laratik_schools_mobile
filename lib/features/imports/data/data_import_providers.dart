// SPDX-License-Identifier: Proprietary
// Riverpod wiring for the Data Imports feature.
//
// Today (read-only data imports + score imports):
//   * `dataImportRepositoryProvider` — single instance per
//     app session.
//   * `dataImportBatchesProvider` — Async notifier for the
//     batches list. Manual [refresh] for pull-to-refresh.
//   * `dataImportReconciliationProvider` — family-keyed
//     AsyncNotifier keyed on the batch name. Manual
//     [refresh] for pull-to-refresh.
//   * `scoreImportsProvider` — Async notifier for the
//     score imports list. Manual [refresh] for pull-to-
//     refresh.
//   * `scoreImportDetailProvider` — family-keyed
//     AsyncNotifier keyed on the score import name. The
//     single record is the current list entry — refresh()
//     re-fetches the list and re-resolves the entry. This
//     keeps the detail surface forward-compat with the
//     future per-score-import "preview" / "commit" write
//     flows that grow the per-row payload.
//
// Future (deferred to docs/PROD_READINESS_AUDIT.md #9
// follow-up):
//   * `uploadDataImportPackage` / `dryRunDataImport` /
//     `reviewDataImportRecords` / `approveDataImport` /
//     `commitDataImport` — the data import write flows.
//     These are deferred because the underlying
//     `upload_school_data_import_package` endpoint expects
//     a pre-uploaded `package_file` (Frappe's file API)
//     which is outside the v1 SDK scope today.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../../../core/result.dart';
import '../../people/data/person_providers.dart';
import 'data_import.dart';
import 'data_import_failure.dart';
import 'data_import_repository.dart';

/// Single data imports repository per app session. All Data
/// Imports feature code reads it from this provider.
final dataImportRepositoryProvider = Provider<DataImportRepository>((ref) {
  return DataImportRepository(api: ref.watch(apiClientProvider));
});

// ---------------------------------------------------------------------------
// Data import batches
// ---------------------------------------------------------------------------

/// Data import batches list. AsyncNotifier so the screen can
/// `ref.watch` and receive loading / data / error transitions
/// from a single source of truth. Manual [refresh] for
/// pull-to-refresh.
class DataImportBatchesController
    extends AutoDisposeAsyncNotifier<DataImportBatchPage> {
  @override
  Future<DataImportBatchPage> build() async {
    final repo = ref.read(dataImportRepositoryProvider);
    final result = await repo.listBatches();
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<DataImportBatchPage>(() async {
      final repo = ref.read(dataImportRepositoryProvider);
      final result = await repo.listBatches();
      return switch (result) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
    });
  }
}

final dataImportBatchesProvider = AsyncNotifierProvider.autoDispose<
    DataImportBatchesController, DataImportBatchPage>(
  DataImportBatchesController.new,
);

// ---------------------------------------------------------------------------
// Data import reconciliation (per batch)
// ---------------------------------------------------------------------------

/// Per-batch reconciliation records. Family-keyed so the
/// detail screen can refetch the records for a single batch
/// without reloading every other batch's reconciliation in
/// the app.
class DataImportReconciliationController extends AutoDisposeFamilyAsyncNotifier<
    DataImportRecordPage, String> {
  @override
  Future<DataImportRecordPage> build(String batch) async {
    final repo = ref.read(dataImportRepositoryProvider);
    final result = await repo.listReconciliation(batch: batch);
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };
  }

  Future<void> refresh() async {
    final batch = arg;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<DataImportRecordPage>(() async {
      final repo = ref.read(dataImportRepositoryProvider);
      final result = await repo.listReconciliation(batch: batch);
      return switch (result) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
    });
  }
}

final dataImportReconciliationProvider = AsyncNotifierProvider.autoDispose
    .family<DataImportReconciliationController, DataImportRecordPage, String>(
  DataImportReconciliationController.new,
);

// ---------------------------------------------------------------------------
// Score imports
// ---------------------------------------------------------------------------

/// Score imports list. AsyncNotifier so the screen can
/// `ref.watch` and receive loading / data / error transitions
/// from a single source of truth. Manual [refresh] for
/// pull-to-refresh.
class ScoreImportsController
    extends AutoDisposeAsyncNotifier<ScoreImportPage> {
  @override
  Future<ScoreImportPage> build() async {
    final repo = ref.read(dataImportRepositoryProvider);
    final result = await repo.listScoreImports();
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<ScoreImportPage>(() async {
      final repo = ref.read(dataImportRepositoryProvider);
      final result = await repo.listScoreImports();
      return switch (result) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
    });
  }
}

final scoreImportsProvider =
    AsyncNotifierProvider.autoDispose<ScoreImportsController, ScoreImportPage>(
  ScoreImportsController.new,
);

/// Per-score-import detail (a single entry resolved from the
/// list). Family-keyed so the detail screen can refetch the
/// list and re-resolve the entry without holding a parallel
/// "get one" provider. The refresh action also runs the
/// validate flow so the per-stage counts stay current.
class ScoreImportDetailController extends AutoDisposeFamilyAsyncNotifier<
    ScoreImport?, String> {
  @override
  Future<ScoreImport?> build(String scoreImportId) async {
    final repo = ref.read(dataImportRepositoryProvider);
    final result = await repo.listScoreImports();
    return switch (result) {
      Ok(:final value) =>
        value.scoreImports.where((s) => s.name == scoreImportId).firstOrNull,
      Err(:final error) => throw error,
    };
  }

  Future<void> refresh() async {
    final id = arg;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<ScoreImport?>(() async {
      final repo = ref.read(dataImportRepositoryProvider);
      final result = await repo.listScoreImports();
      return switch (result) {
        Ok(:final value) =>
          value.scoreImports.where((s) => s.name == id).firstOrNull,
        Err(:final error) => throw error,
      };
    });
  }

  /// Run the validate flow against the server. On success,
  /// refetches the list so the per-stage counts reflect the
  /// freshest state.
  Future<Result<JsonMap, DataImportFailure>> validate() async {
    final id = arg;
    final repo = ref.read(dataImportRepositoryProvider);
    final result = await repo.validateScoreImport(scoreImport: id);
    if (result is Ok<JsonMap, DataImportFailure>) {
      // Refresh the list so the detail's counts + status chip
      // reflect the new state.
      ref.invalidate(scoreImportsProvider);
    }
    return result;
  }

  /// Run the commit flow against the server. On success,
  /// refetches the list so the status chip flips to
  /// `committed`.
  Future<Result<JsonMap, DataImportFailure>> commit() async {
    final id = arg;
    final repo = ref.read(dataImportRepositoryProvider);
    final result = await repo.commitScoreImport(scoreImport: id);
    if (result is Ok<JsonMap, DataImportFailure>) {
      ref.invalidate(scoreImportsProvider);
    }
    return result;
  }
}

final scoreImportDetailProvider = AsyncNotifierProvider.autoDispose
    .family<ScoreImportDetailController, ScoreImport?, String>(
  ScoreImportDetailController.new,
);
