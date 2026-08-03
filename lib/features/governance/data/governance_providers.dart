// SPDX-License-Identifier: Proprietary
// Riverpod wiring for the Governance feature.
//
// Today (read-only privacy requests + admin approve / process /
// set legal hold + retention + requester submit):
//   * `governanceRepositoryProvider` — single instance per app
//     session.
//   * `privacyRequestsController` — async notifier for the
//     privacy list. Manual [refresh] for pull-to-refresh +
//     after a successful approve / process / set-legal-hold.
//   * `approvePrivacyRequest` / `processPrivacyRequest` /
//     `setPrivacyLegalHold` / `evaluateRetention` — top-level
//     helper functions that the screen calls; they delegate
//     to the repository and invalidate
//     `privacyRequestsProvider` on success so the list
//     re-fetches the latest state.
//   * `submitPrivacyRequest` — top-level helper for the
//     requester flow (parent or student submits their own
//     request). Mints a fresh UUID for the
//     `Idempotency-Key` header + a fresh `client_request_id`
//     so a retry of the same submit is safe to send again.
//
// Future (deferred to a follow-up turn):
//   * `approveDataGovernanceSettings` — admin approves a
//     settings change (retention window + legal hold
//     defaults).
//   * `createDataArchiveManifest` — admin exports the school's
//     data archive for a specific date range.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../people/data/person_providers.dart';
import 'approved_settings.dart';
import 'governance_failure.dart';
import 'governance_request.dart';
import 'governance_repository.dart';

/// Single governance repository per app session. All
/// Governance feature code reads it from this provider.
final governanceRepositoryProvider = Provider<GovernanceRepository>((ref) {
  return GovernanceRepository(api: ref.watch(apiClientProvider));
});

/// Privacy requests list. Async notifier so the screen can
/// `ref.watch` and receive loading / data / error transitions
/// from a single source of truth. Manual [refresh] for
/// pull-to-refresh and after every approve / process /
/// set-legal-hold action.
class PrivacyRequestsController
    extends AutoDisposeAsyncNotifier<PrivacyRequestPage> {
  @override
  Future<PrivacyRequestPage> build() async {
    final repo = ref.read(governanceRepositoryProvider);
    final result = await repo.listPrivacyRequests();
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<PrivacyRequestPage>(() async {
      final repo = ref.read(governanceRepositoryProvider);
      final result = await repo.listPrivacyRequests();
      return switch (result) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
    });
  }
}

final privacyRequestsProvider = AsyncNotifierProvider.autoDispose<
    PrivacyRequestsController, PrivacyRequestPage>(
  PrivacyRequestsController.new,
);

/// Top-level helper to approve a privacy request. Returns
/// `Ok` on success, `Err` with the typed failure on
/// rejection. Inverts `privacyRequestsProvider` on success so
/// the list re-fetches the latest state.
///
/// Takes a [WidgetRef] (not a [Ref]) because the only callers
/// are widget-side helpers — the Riverpod `Ref` type lives
/// inside a provider closure, not in a widget's build
/// method. Using [WidgetRef] keeps the call sites clean.
Future<Result<void, GovernanceFailure>> approvePrivacyRequest(
  WidgetRef ref, {
  required String requestName,
  String? reason,
}) async {
  final repo = ref.read(governanceRepositoryProvider);
  final result = await repo.approvePrivacyRequest(
    requestName: requestName,
    reason: reason,
  );
  if (result is Ok) {
    ref.invalidate(privacyRequestsProvider);
  }
  return result;
}

/// Top-level helper to mark a request as "Under Review".
Future<Result<void, GovernanceFailure>> processPrivacyRequest(
  WidgetRef ref, {
  required String requestName,
  String? note,
}) async {
  final repo = ref.read(governanceRepositoryProvider);
  final result = await repo.processPrivacyRequest(
    requestName: requestName,
    note: note,
  );
  if (result is Ok) {
    ref.invalidate(privacyRequestsProvider);
  }
  return result;
}

/// Top-level helper to set or release a legal hold.
Future<Result<void, GovernanceFailure>> setPrivacyLegalHold(
  WidgetRef ref, {
  required String requestName,
  required bool hold,
  String? reason,
}) async {
  final repo = ref.read(governanceRepositoryProvider);
  final result = await repo.setLegalHold(
    requestName: requestName,
    hold: hold,
    reason: reason,
  );
  if (result is Ok) {
    ref.invalidate(privacyRequestsProvider);
  }
  return result;
}

/// Top-level helper to trigger a retention evaluation across
/// the school. Refreshes the list when complete so any
/// retention-driven status changes show up.
Future<Result<void, GovernanceFailure>> evaluateRetention(WidgetRef ref) async {
  final repo = ref.read(governanceRepositoryProvider);
  final result = await repo.evaluateRetention();
  if (result is Ok) {
    ref.invalidate(privacyRequestsProvider);
  }
  return result;
}

/// Top-level helper to approve a pending data governance
/// settings change. The repository mints a fresh UUID for
/// the `Idempotency-Key` header. Takes a [WidgetRef] (not
/// a [Ref]) because the only callers are widget-side
/// helpers.
///
/// On success the list provider is invalidated so the
/// privacy list re-fetches the latest state (some
/// governance settings changes cascade into the per-row
/// retention policy).
Future<Result<ApprovedGovernanceSettings, GovernanceFailure>>
    approveDataGovernanceSettings(
  WidgetRef ref, {
  int? policyVersion,
  String? reason,
}) async {
  final repo = ref.read(governanceRepositoryProvider);
  final result = await repo.approveDataGovernanceSettings(
    policyVersion: policyVersion,
    reason: reason,
  );
  if (result is Ok) {
    ref.invalidate(privacyRequestsProvider);
  }
  return result;
}

/// Top-level helper to submit a new privacy request from
/// a parent or student. The repository mints a fresh UUID
/// for the `Idempotency-Key` header + a fresh
/// `client_request_id` so a retry of the same submit is
/// safe to send again. The list provider is invalidated
/// on success so the admin's privacy list (when re-loaded
/// by the same school session) re-fetches the new row.
Future<Result<SubmittedPrivacyRequest, GovernanceFailure>> submitPrivacyRequest(
  WidgetRef ref, {
  required String requestType,
  required String requesterType,
  required String subjectType,
  required String subject,
  required List<String> requestedCategories,
  required String schoolBranch,
  required String authorityReference,
  String? schemaVersion,
}) async {
  final repo = ref.read(governanceRepositoryProvider);
  final result = await repo.submitPrivacyRequest(
    requestType: requestType,
    requesterType: requesterType,
    subjectType: subjectType,
    subject: subject,
    requestedCategories: requestedCategories,
    schoolBranch: schoolBranch,
    authorityReference: authorityReference,
    schemaVersion: schemaVersion,
  );
  if (result is Ok) {
    ref.invalidate(privacyRequestsProvider);
  }
  return result;
}
