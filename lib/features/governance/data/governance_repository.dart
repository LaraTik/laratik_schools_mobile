// SPDX-License-Identifier: Proprietary
// Governance repository — wraps the v1 endpoints the admin +
// parent / student privacy + retention surface needs.
//
// Today (read-only privacy requests + admin approve / process /
// set legal hold + retention + requester submit + settings
// approval):
//   * `get_school_privacy_requests` → list of privacy requests
//     (data export / data deletion / data access / consent
//     withdrawal / legal hold / governance settings). The
//     server is expected to filter to the active school's
//     pending + active requests.
//   * `approve_school_privacy_request` (write) — admin
//     approves a submitted request. The mobile passes a
//     `payload: { 'request_name': <id>, 'decision': 'approved' }`
//     and a fresh idempotency key.
//   * `process_school_privacy_request` (write) — admin
//     marks a request as "Under Review" (in-progress).
//   * `set_school_privacy_legal_hold` (write) — admin
//     sets or releases a legal hold on a request.
//   * `evaluate_school_data_retention` (write) — admin runs
//     the retention policy across the school.
//   * `submit_school_privacy_request` (write) — parent or
//     student submits a new privacy request. The mobile
//     mints a fresh UUID for the `Idempotency-Key` header
//     and the `client_request_id` field on the payload.
//   * `approve_school_data_governance_settings` (write) —
//     admin approves a settings change (e.g. updating
//     the retention policy). The mobile passes a
//     `payload: { 'policy_version': <int>, 'reason'? }`
//     and a fresh idempotency key.

import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import 'approved_settings.dart';
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

  /// Submit a new privacy request from a parent or student.
  /// The v1 server requires
  /// `require_privacy_requester_access()` (parent or student
  /// role). The payload carries `request_type` (access /
  /// rectification / erasure / consent_withdrawal / legal_hold)
  /// + `requester_type` (guardian / student) + `subject_type`
  /// (student / family / staff) + `subject` (the subject id)
  /// + `requested_categories` (list) + `school_branch` (the
  /// active school branch) + `authority_reference` (an external
  /// reference) + `client_request_id` (a fresh UUID v4 so a
  /// retry of the same submit is safe to send again). The
  /// repository mints a fresh UUID for the `Idempotency-Key`
  /// header too.
  Future<Result<SubmittedPrivacyRequest, GovernanceFailure>>
      submitPrivacyRequest({
    required String requestType,
    required String requesterType,
    required String subjectType,
    required String subject,
    required List<String> requestedCategories,
    required String schoolBranch,
    required String authorityReference,
    String? schemaVersion,
  }) async {
    try {
      final clientRequestId = _uuid.v4();
      final response = await _api.submitSchoolPrivacyRequest(
        payload: SubmitSchoolPrivacyRequestPayload(
          authorityReference: authorityReference,
          clientRequestId: clientRequestId,
          requestType: requestType,
          requestedCategories: requestedCategories,
          requesterType: requesterType,
          schoolBranch: schoolBranch,
          schemaVersion: schemaVersion,
          subject: subject,
          subjectType: subjectType,
        ),
        idempotencyKey: _uuid.v4(),
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: GovernanceFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no submitted privacy request.',
          ),
        );
      }
      return Ok(value: SubmittedPrivacyRequest.fromJson(data.toJson()));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Approve a pending data governance settings change. The
  /// v1 server requires `require_governance_approval_access()`
  /// (admin role) and the SDK takes an optional
  /// `payload: { 'policy_version', 'reason'? }`. The
  /// repository mints a fresh UUID for the `Idempotency-Key`
  /// header so a retry of the same approve is safe to send
  /// again.
  Future<Result<ApprovedGovernanceSettings, GovernanceFailure>>
      approveDataGovernanceSettings({
    int? policyVersion,
    String? reason,
  }) async {
    try {
      final response = await _api.approveSchoolDataGovernanceSettings(
        payload: <String, Object?>{
          if (policyVersion != null) 'policy_version': policyVersion,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
        idempotencyKey: _uuid.v4(),
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: GovernanceFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no approved settings data.',
          ),
        );
      }
      return Ok(value: ApprovedGovernanceSettings.fromJson(data.toJson()));
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
