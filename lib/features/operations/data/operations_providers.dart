// SPDX-License-Identifier: Proprietary
// Riverpod wiring for the Operations feature.
//
// Today (read + write operations health + delivery + audit):
//   * `operationsRepositoryProvider` — single instance per app
//     session.
//   * `operationsHealthProvider` — FutureProvider.autoDispose for
//     the top-level health snapshot.
//   * `deliveryHealthProvider` — FutureProvider.autoDispose for
//     the delivery-health per-status counts.
//   * `authAuditEventsController` — Async notifier for the
//     auth-audit list. Manual [refresh] for pull-to-refresh.
//   * `replayDeliveryEventController` — Async notifier for
//     the `replay_school_delivery_event` write flow. Mints
//     a fresh UUID for the `Idempotency-Key` header;
//     invalidates the delivery-health provider on success
//     so the next ref.watch re-fetches the new per-status
//     counts.
//   * `receiveDeliveryCallbackController` — Async notifier
//     for the `receive_school_delivery_callback` write
//     flow. The v1 SDK exposes this as a top-level write
//     without an `Idempotency-Key` header (callbacks are
//     idempotent on the server).
//
// Future (deferred to docs/PROD_READINESS_AUDIT.md #9 follow-up):
//   * `uploadDataImportPackage` / `dryRunDataImport` /
//     `approveDataImport` / `commitDataImport` — data-import
//     write flows.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../people/data/person_providers.dart';
import 'operations_failure.dart';
import 'operations_health.dart';
import 'operations_repository.dart';
import 'operations_write.dart';

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

/// Controller for the `replay_school_delivery_event` write
/// flow. Mints a fresh UUID for the `Idempotency-Key` header
/// inside the repository (not the controller) so a retry
/// of the same replay is safe to send again. On success
/// the delivery-health provider is invalidated so the next
/// ref.watch re-fetches the new per-status counts.
class ReplayDeliveryEventController
    extends AutoDisposeAsyncNotifier<ReplayedDeliveryEvent?> {
  @override
  Future<ReplayedDeliveryEvent?> build() async => null;

  Future<Result<ReplayedDeliveryEvent, OperationsFailure>> submit({
    required String eventKey,
    String? reason,
  }) async {
    if (eventKey.isEmpty) {
      return const Err(
        error: OperationsFailure(
          code: 'EMPTY_EVENT_KEY',
          message: 'An event key is required to replay a delivery event.',
        ),
      );
    }
    state = const AsyncValue.loading();
    final repo = ref.read(operationsRepositoryProvider);
    final result = await repo.replayDeliveryEvent(
      eventKey: eventKey,
      reason: reason,
    );
    switch (result) {
      case Ok(:final value):
        // Invalidate the delivery-health provider so the
        // next ref.watch re-fetches the new per-status
        // counts.
        ref.invalidate(deliveryHealthProvider);
        state = AsyncValue.data(value);
      case Err():
        state = const AsyncValue.data(null);
    }
    return result;
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final replayDeliveryEventProvider = AsyncNotifierProvider.autoDispose<
    ReplayDeliveryEventController, ReplayedDeliveryEvent?>(
  ReplayDeliveryEventController.new,
);

/// Controller for the `receive_school_delivery_callback` write
/// flow. The v1 SDK exposes this as a top-level write
/// without an `Idempotency-Key` header (callbacks are
/// idempotent on the server).
class ReceiveDeliveryCallbackController
    extends AutoDisposeAsyncNotifier<DeliveryCallbackReceipt?> {
  @override
  Future<DeliveryCallbackReceipt?> build() async => null;

  Future<Result<DeliveryCallbackReceipt, OperationsFailure>> submit({
    required String provider,
    String? signature,
    String? body,
  }) async {
    if (provider.isEmpty) {
      return const Err(
        error: OperationsFailure(
          code: 'EMPTY_PROVIDER',
          message: 'A provider is required to receive a delivery callback.',
        ),
      );
    }
    state = const AsyncValue.loading();
    final repo = ref.read(operationsRepositoryProvider);
    final result = await repo.receiveDeliveryCallback(
      provider: provider,
      signature: signature,
      body: body,
    );
    switch (result) {
      case Ok(:final value):
        ref.invalidate(deliveryHealthProvider);
        state = AsyncValue.data(value);
      case Err():
        state = const AsyncValue.data(null);
    }
    return result;
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final receiveDeliveryCallbackProvider = AsyncNotifierProvider.autoDispose<
    ReceiveDeliveryCallbackController, DeliveryCallbackReceipt?>(
  ReceiveDeliveryCallbackController.new,
);
