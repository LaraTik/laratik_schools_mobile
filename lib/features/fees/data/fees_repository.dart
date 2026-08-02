// SPDX-License-Identifier: Proprietary
// Fees repository — wraps the v1 endpoints the read-only Fees
// surface needs.
//
// Today (read-only "Fee plans" + "Operations overview"):
//   * `get_school_student_fee_plans` → list of fee plans. The
//     server is expected to filter to the current user when the
//     session is a parent role; the admin sees the full catalog.
//   * `get_school_fee_operations_overview` → aggregate totals
//     (invoiced / collected / outstanding) + counts by status
//     (paid / overdue / draft). Admin-only surface; the parent
//     uses the per-plan list instead.
//   * `preview_school_fee_invoice` (write-style) — only used for
//     showing the "what would this invoice look like?" preview
//     before draft creation. Deferred to a follow-up turn.
//   * `create_school_fee_invoice_draft` (write) — deferred.
//   * `create_school_student_fee_plan` (write) — deferred.
//   * `create_school_fee_policy` (write) — deferred.
//   * `get_school_fee_policies` (read) — read-only catalog of
//     fee policies. Useful as a reference for the future
//     "plan authoring" surface; not consumed by the read-only
//     list today.

import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import 'fee_plan.dart';
import 'fees_failure.dart';

class FeesRepository {
  FeesRepository({required LaratikSchoolsApiClient api, Uuid? uuid})
      : _api = api,
        // Kept for parity with the other repositories; not
        // currently used because the read-only fees APIs do not
        // take an idempotency key.
        // ignore: unused_field
        _uuid = uuid ?? const Uuid();

  final LaratikSchoolsApiClient _api;
  // ignore: unused_field
  final Uuid _uuid;

  /// List the current user's fee plans. The v1 server is
  /// expected to filter to the current user when the session is
  /// a parent role (so the parent sees only their children's
  /// plans); the admin sees the full catalog.
  Future<Result<FeePlanPage, FeesFailure>> listFeePlans({
    String? cursor,
    int? limit,
    String? sinceDate,
  }) async {
    try {
      final response = await _api.getSchoolStudentFeePlans(
        cursor: cursor,
        limit: limit ?? 100,
        sinceDate: sinceDate,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
            error: FeesFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no fee plan data.',
        ));
      }
      final rows = data.plans ?? const <JsonMap>[];
      final plans = rows.map(FeePlan.fromJson).toList(growable: false);
      return Ok(value: FeePlanPage(plans: plans));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Aggregate totals + counts for the admin "Operations" KPI
  /// card. The wire shape is opaque; the [FeeOperationsOverview]
  /// factory pulls the canonical fields with safe fallbacks.
  Future<Result<FeeOperationsOverview, FeesFailure>>
      fetchOperationsOverview() async {
    try {
      final response = await _api.getSchoolFeeOperationsOverview();
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
            error: FeesFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no operations overview data.',
        ));
      }
      // The endpoint returns `branches`, `schema`, and `summary`.
      // The mobile uses the `summary` map for the KPI card;
      // `branches` and `schema` are preserved on [raw] for a
      // future per-branch drill-down.
      final summary = data.summary ?? const <String, Object?>{};
      final overview = FeeOperationsOverview.fromJson(summary);
      return Ok(value: overview);
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  FeesFailure _failureFromApi(ApiError? error) {
    if (error == null) {
      return const FeesFailure(
        code: 'EMPTY_RESPONSE',
        message: 'The server returned no data.',
      );
    }
    return FeesFailure(
      code: error.code,
      message: error.message,
      fieldErrors: error.fieldErrors,
    );
  }

  FeesFailure _exceptionFailure(Exception e) {
    return FeesFailure(
      code: 'EXCEPTION',
      message: e.toString(),
    );
  }
}
