// SPDX-License-Identifier: Proprietary
// Riverpod wiring for the Operations feature.
//
// Today (read-only operations health + delivery + audit):
//   * `operationsRepositoryProvider` — single instance per app
//     session.
//   * `operationsHealthProvider` — FutureProvider.autoDispose for
//     the top-level health snapshot.
//   * `deliveryHealthProvider` — FutureProvider.autoDispose for
//     the delivery-health per-status counts.
//   * `authAuditEventsController` — Async notifier for the
//     auth-audit list. Manual [refresh] for pull-to-refresh.
//
// Future (deferred to docs/PROD_READINESS_AUDIT.md #9 follow-up):
//   * `replayDeliveryEvent` — admin "Replay" write flow.
//   * `processPrivacyRequest` / `approvePrivacyRequest` /
//     `setPrivacyLegalHold` — governance write flows.
//   * `uploadDataImportPackage` / `dryRunDataImport` /
//     `approveDataImport` / `commitDataImport` — data-import
//     write flows.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../people/data/person_providers.dart';
import 'operations_failure.dart';
import 'operations_health.dart';
import 'operations_repository.dart';

/// Single operations repository per app session. All Operations
/// feature code reads it from this provider.
final operationsRepositoryProvider = Provider<OperationsRepository>((ref) {
  return OperationsRepository(api: ref.watch(apiClientProvider));
});

/// Top-level operations health snapshot. AutoDispose so
/// navigating away releases the fetch.
final operationsHealthProvider =
    FutureProvider.autoDispose<Result<OperationsHealth, OperationsFailure>>(
        (ref) async {
  final repo = ref.watch(operationsRepositoryProvider);
  return repo.fetchOperationsHealth();
});

/// Per-status delivery health counts. AutoDispose so navigating
/// away releases the fetch.
final deliveryHealthProvider =
    FutureProvider.autoDispose<Result<DeliveryHealth, OperationsFailure>>(
        (ref) async {
  final repo = ref.watch(operationsRepositoryProvider);
  return repo.fetchDeliveryHealth();
});

/// Auth audit list. Async notifier so the screen can `ref.watch`
/// and receive loading / data / error transitions from a single
/// source of truth. Manual [refresh] for pull-to-refresh.
class AuthAuditEventsController
    extends AutoDisposeAsyncNotifier<AuthAuditPage> {
  @override
  Future<AuthAuditPage> build() async {
    final repo = ref.read(operationsRepositoryProvider);
    final result = await repo.listAuthAuditEvents();
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<AuthAuditPage>(() async {
      final repo = ref.read(operationsRepositoryProvider);
      final result = await repo.listAuthAuditEvents();
      return switch (result) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
    });
  }
}

final authAuditEventsProvider =
    AsyncNotifierProvider.autoDispose<AuthAuditEventsController, AuthAuditPage>(
  AuthAuditEventsController.new,
);
