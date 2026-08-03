// SPDX-License-Identifier: Proprietary
// Governance repository — wraps the v1 endpoints the read-only
// privacy + retention surface needs.
//
// Today (read-only privacy requests + approve / process / set
// legal hold):
//   * `get_school_privacy_requests` → list of privacy requests
//     (data export / data deletion / data access / consent
//     withdrawal / legal hold / governance settings). The
//     server is expected to filter to the active school's
//     pending + active requests.
//   * `approve_school_privacy_request` (write) — admin
//     approves a submitted request. The mobile passes a
//     `payload: { 'request_name': <id>, 'decision': 'approved' }`
//     and a fresh idempotency key (see the convention in
//     `lib/core/result.dart`).
//   * `process_school_privacy_request` (write) — admin
//     marks a request as "Under Review" (in-progress).
//   * `set_school_privacy_legal_hold` (write) — admin
//     sets or releases a legal hold on a request.
//   * `evaluate_school_data_retention` (write) — admin runs
//     the retention policy across the school.
//
// The `submit_school_privacy_request` endpoint is for the
// requester (a parent or student submitting their own
// request). That flow is deferred to a follow-up turn — the
// admin surface doesn't need it.
//
// The `approve_school_data_governance_settings` endpoint is
// the approve action for the governance settings change
// (e.g. updating the retention policy). Deferred to the
// settings follow-up.

import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import 'governance_failure.dart';
import 'governance_request.dart';

class GovernanceRepository {
  GovernanceRepository({required LaratikSchoolsApiClient api, Uuid? uuid})
      : _api = api,
        _uuid = uuid ?? const Uuid();

  final LaratikSchoolsApiClient _api;
  final Uuid _uuid;

  /// List the school's privacy requests. The v1 SDK exposes
  /// a cursor on `get_school_privacy_requests`; the mobile
  /// pages via cursor when the server returns one and falls
  /// through to the first page when it does not.
  Future<Result<PrivacyRequestPage, GovernanceFailure>> listPrivacyRequests({
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _api.getSchoolPrivacyRequests(
        cursor: cursor,
        limit: limit ?? 50,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: GovernanceFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no privacy request data.',
          ),
        );
      }
      final rows = data.privacyRequests ?? const <JsonMap>[];
      final requests =
          rows.map(PrivacyRequest.fromJson).toList(growable: false);
      return Ok(value: PrivacyRequestPage(requests: requests));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Approve a privacy request. The wire envelope returns a
  /// typed `ApproveSchoolPrivacyRequestData` which the mobile
  /// does not currently consume (the surface just refreshes
  /// the list on success).
  Future<Result<void, GovernanceFailure>> approvePrivacyRequest({
    required String requestName,
    String? reason,
  }) async {
    try {
      final response = await _api.approveSchoolPrivacyRequest(
        payload: <String, Object?>{
          'request_name': requestName,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
        idempotencyKey: _uuid.v4(),
      );
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      return const Ok(value: null);
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Mark a privacy request as "Under Review".
  Future<Result<void, GovernanceFailure>> processPrivacyRequest({
    required String requestName,
    String? note,
  }) async {
    try {
      final response = await _api.processSchoolPrivacyRequest(
        payload: <String, Object?>{
          'request_name': requestName,
          if (note != null && note.isNotEmpty) 'note': note,
        },
        idempotencyKey: _uuid.v4(),
      );
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      return const Ok(value: null);
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Set or release a legal hold on a privacy request.
  Future<Result<void, GovernanceFailure>> setLegalHold({
    required String requestName,
    required bool hold,
    String? reason,
  }) async {
    try {
      final response = await _api.setSchoolPrivacyLegalHold(
        payload: <String, Object?>{
          'request_name': requestName,
          'hold': hold,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
        idempotencyKey: _uuid.v4(),
      );
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      return const Ok(value: null);
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Trigger a retention evaluation across the school. The
  /// server returns a typed
  /// `EvaluateSchoolDataRetentionData` which the mobile does
  /// not currently consume (the surface just refreshes the
  /// list on success; a future detail surface can render
  /// the evaluation result).
  Future<Result<void, GovernanceFailure>> evaluateRetention() async {
    try {
      final response = await _api.evaluateSchoolDataRetention(
        payload: const <String, Object?>{},
        idempotencyKey: _uuid.v4(),
      );
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      return const Ok(value: null);
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  GovernanceFailure _failureFromApi(ApiError? error) {
    if (error == null) {
      return const GovernanceFailure(
        code: 'EMPTY_RESPONSE',
        message: 'The server returned no data.',
      );
    }
    return GovernanceFailure(
      code: error.code,
      message: error.message,
      fieldErrors: error.fieldErrors,
    );
  }

  GovernanceFailure _exceptionFailure(Exception e) {
    return GovernanceFailure(
      code: 'EXCEPTION',
      message: e.toString(),
    );
  }
}
