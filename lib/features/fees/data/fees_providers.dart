// SPDX-License-Identifier: Proprietary
// Riverpod wiring for the Fees feature.
//
// Today (read-only slice):
//   * `feesRepositoryProvider` — single instance per app session.
//   * `feePlansController` — async controller for the per-student
//     fee plan list. Re-fetches on refresh; no pagination today
//     (the v1 SDK doesn't expose a cursor on
//     `get_school_student_fee_plans`).
//   * `feeOperationsOverviewProvider` — single-shot FutureProvider
//     for the admin KPI card. AutoDispose so navigating away
//     releases the fetch.
//   * `feePlanDetailProvider` — family FutureProvider for the
//     per-plan detail. The current `listFeePlans` returns the
//     full list; the detail page reads from the same list when
//     possible and re-fetches the whole list otherwise (the v1
//     SDK does not expose a single-plan `get` endpoint today).
//
// Future (deferred to docs/PROD_READINESS_AUDIT.md #7 follow-up):
//   * `createFeePlan` — admin / accountant create flow.
//   * `previewFeeInvoice` — preview the invoice before draft
//     creation.
//   * `createFeeInvoiceDraft` — submit the draft to the server.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../people/data/person_providers.dart';
import 'fee_plan.dart';
import 'fees_failure.dart';
import 'fees_repository.dart';

/// Single fees repository per app session. All Fees feature code
/// reads it from this provider.
final feesRepositoryProvider = Provider<FeesRepository>((ref) {
  return FeesRepository(api: ref.watch(apiClientProvider));
});

/// Fee plan list. Async notifier so the screen can `ref.watch`
/// and receive loading / data / error transitions from a single
/// source of truth. Manual [refresh] for pull-to-refresh.
class FeePlansController extends AutoDisposeAsyncNotifier<FeePlanPage> {
  @override
  Future<FeePlanPage> build() async {
    final repo = ref.read(feesRepositoryProvider);
    final result = await repo.listFeePlans();
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<FeePlanPage>(() async {
      final repo = ref.read(feesRepositoryProvider);
      final result = await repo.listFeePlans();
      return switch (result) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
    });
  }
}

final feePlansProvider =
    AsyncNotifierProvider.autoDispose<FeePlansController, FeePlanPage>(
  FeePlansController.new,
);

/// Admin "Operations" KPI card. AutoDispose so navigating away
/// releases the fetch. Family-scoped on a string key (the
/// current academic year id, or `''` for "all") so a future
/// per-year overview can drop in without a model change.
final feeOperationsOverviewProvider = FutureProvider.autoDispose
    .family<Result<FeeOperationsOverview, FeesFailure>, String>(
        (ref, yearKey) async {
  final repo = ref.watch(feesRepositoryProvider);
  return repo.fetchOperationsOverview();
});

/// Per-plan detail. Re-fetches the full list and picks the
/// matching row. The v1 SDK does not expose a single-plan `get`
/// endpoint today, so this is the cheapest honest way to render
/// the detail without server-side changes. Family-scoped on the
/// plan id; autoDispose so navigating away releases the fetch.
final feePlanDetailProvider = FutureProvider.autoDispose
    .family<Result<FeePlan?, FeesFailure>, String>((ref, planId) async {
  final repo = ref.watch(feesRepositoryProvider);
  final result = await repo.listFeePlans(limit: 200);
  return switch (result) {
    Ok(:final value) => Ok<FeePlan?, FeesFailure>(
        value: value.plans
            .where((p) => p.id == planId)
            .cast<FeePlan?>()
            .firstWhere((_) => true, orElse: () => null),
      ),
    Err(:final error) => Err(error: error),
  };
});
