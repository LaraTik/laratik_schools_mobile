// SPDX-License-Identifier: Proprietary
// Grading repository — wraps the v1 endpoints the read-only
// Grading admin surface needs.
//
// Today (read-only overview + policies + setup context):
//   * `get_grading_overview_context` → coverage + feature +
//     recent-students + summary + workflow stages. The
//     mobile flattens the summary + workflow stages into
//     a [GradingOverview] for the overview tab.
//   * `get_grading_policy_setup_context` → the role sets
//     that govern the grading surface. The mobile renders
//     the read / required roles as a "Permissions" section
//     on the policies tab.
//   * `get_school_grading_operations_overview` → per-branch
//     summary. The mobile currently flattens the summary
//     into the same [GradingOverview]; the per-branch
//     drill-down is deferred to a follow-up turn.
//   * `get_school_subject_grade_policies` → the list of
//     subject grade policies. The mobile renders each as
//     a row with the subject, grade band, pass threshold,
//     and approval status.
//
// Write flows (deferred to follow-up turns):
//   * `correct_school_grade_record` — admin corrects an
//     existing grade record.
//   * `promote_school_assessment_result` — admin promotes
//     a grade from an assessment result to a grade record.
//   * `approve_school_subject_grade_policy` — admin approves
//     a pending policy.

import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

import '../../../core/result.dart';
import 'grading_failure.dart';
import 'grading_overview.dart';

class GradingRepository {
  GradingRepository({required LaratikSchoolsApiClient api}) : _api = api;

  final LaratikSchoolsApiClient _api;

  /// Top-level grading overview snapshot. Combines the
  /// `get_grading_overview_context` (workflow stages) +
  /// `get_school_grading_operations_overview` (per-branch
  /// summary) into a single [GradingOverview] for the
  /// surface. Returns an [Err] with the first typed
  /// failure if either endpoint errors.
  Future<Result<GradingOverview, GradingFailure>> fetchOverview() async {
    try {
      final overviewFuture = _api.getGradingOverviewContext();
      final operationsFuture = _api.getSchoolGradingOperationsOverview();
      final overviewResponse = await overviewFuture;
      final operationsResponse = await operationsFuture;

      // Fail fast on either error; the surface shows a single
      // error state.
      if (overviewResponse.error != null) {
        return Err(error: _failureFromApi(overviewResponse.error));
      }
      if (operationsResponse.error != null) {
        return Err(error: _failureFromApi(operationsResponse.error));
      }
      if (overviewResponse.data == null || operationsResponse.data == null) {
        return const Err(
          error: GradingFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no grading overview data.',
          ),
        );
      }
      // The mobile flattens the operations summary (per-
      // branch totals) into the same map the overview
      // context returns. Per-branch drill-down is deferred
      // to a follow-up turn.
      final operations = operationsResponse.data!;
      final summary = operations.summary ?? const <String, Object?>{};
      final merged = <String, Object?>{
        ...summary,
        if (overviewResponse.data!.coverage != null)
          'coverage': overviewResponse.data!.coverage!,
        if (overviewResponse.data!.feature != null)
          'feature': overviewResponse.data!.feature!,
        if (overviewResponse.data!.recentStudents != null)
          'recent_students': overviewResponse.data!.recentStudents!,
        if (overviewResponse.data!.workflowStages != null)
          'workflow_stages': overviewResponse.data!.workflowStages!,
      };
      return Ok(value: GradingOverview.fromJson(merged));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// List the school's subject grade policies. The v1 SDK
  /// exposes a cursor on `get_school_subject_grade_policies`;
  /// the mobile pages via cursor when the server returns
  /// one and falls through to the first page when it does
  /// not.
  Future<Result<SubjectGradePolicyPage, GradingFailure>> listPolicies({
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _api.getSchoolSubjectGradePolicies(
        cursor: cursor,
        limit: limit ?? 50,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: GradingFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no grading policy data.',
          ),
        );
      }
      final rows = data.policies ?? const <JsonMap>[];
      final policies =
          rows.map(SubjectGradePolicy.fromJson).toList(growable: false);
      return Ok(value: SubjectGradePolicyPage(policies: policies));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Get the grading policy setup context. The mobile
  /// renders the read / required roles as a "Permissions"
  /// section on the policies tab.
  Future<Result<GradingPolicySetupContext, GradingFailure>>
      fetchPolicySetupContext() async {
    try {
      final response = await _api.getGradingPolicySetupContext();
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: GradingFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no grading policy setup data.',
          ),
        );
      }
      return Ok(value: GradingPolicySetupContext.fromJson(data.toJson()));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  GradingFailure _failureFromApi(ApiError? error) {
    if (error == null) {
      return const GradingFailure(
        code: 'EMPTY_RESPONSE',
        message: 'The server returned no data.',
      );
    }
    return GradingFailure(
      code: error.code,
      message: error.message,
      fieldErrors: error.fieldErrors,
    );
  }

  GradingFailure _exceptionFailure(Exception e) {
    return GradingFailure(
      code: 'EXCEPTION',
      message: e.toString(),
    );
  }
}
