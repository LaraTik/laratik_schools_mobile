// SPDX-License-Identifier: Proprietary
// Operations repository — wraps the v1 read-only operations /
// delivery / auth audit endpoints the admin "Operations" surface
// needs.
//
// Today (read-only operations health + delivery + audit):
//   * `get_school_operations_health` → top-level aggregate
//     (status + per-module KPI maps).
//   * `get_school_delivery_health` → per-status counts of
//     outbound delivery events (notifications, callbacks).
//   * `get_school_auth_audit_events` → list of recent
//     login / token / device-register events for the audit
//     log surface.
//
// Write flows (`replay_school_delivery_event`,
// `receive_school_delivery_callback`,
// `approve_school_privacy_request`,
// `set_school_privacy_legal_hold`) are deferred to the
// governance follow-up turn.

import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

import '../../../core/result.dart';
import 'operations_failure.dart';
import 'operations_health.dart';

class OperationsRepository {
  OperationsRepository({required LaratikSchoolsApiClient api}) : _api = api;

  final LaratikSchoolsApiClient _api;

  /// Top-level operations health snapshot. The wire shape is
  /// open (the server is free to grow per-module KPI maps);
  /// the [OperationsHealth] factory pulls the canonical
  /// fields with safe fallbacks.
  Future<Result<OperationsHealth, OperationsFailure>>
      fetchOperationsHealth() async {
    try {
      final response = await _api.getSchoolOperationsHealth();
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: OperationsFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no operations health data.',
          ),
        );
      }
      return Ok(value: OperationsHealth.fromJson(data.toJson()));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Per-status counts of outbound delivery events. The wire
  /// shape is open; the [DeliveryHealth] factory pulls the
  /// `status_counts` map with safe fallbacks.
  Future<Result<DeliveryHealth, OperationsFailure>>
      fetchDeliveryHealth() async {
    try {
      final response = await _api.getSchoolDeliveryHealth();
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: OperationsFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no delivery health data.',
          ),
        );
      }
      return Ok(value: DeliveryHealth.fromJson(data.toJson()));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Recent auth audit events (login / logout / token refresh /
  /// device register). The v1 SDK does not expose a cursor on
  /// `get_school_auth_audit_events` today, so the page is
  /// "everything we fetched".
  Future<Result<AuthAuditPage, OperationsFailure>> listAuthAuditEvents({
    int? limit,
  }) async {
    try {
      final response = await _api.getSchoolAuthAuditEvents(
        limit: limit ?? 50,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: OperationsFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no auth audit events.',
          ),
        );
      }
      final rows = data.auditEvents ?? const <JsonMap>[];
      final events = rows.map(AuthAuditEvent.fromJson).toList(growable: false);
      return Ok(value: AuthAuditPage(events: events));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  OperationsFailure _failureFromApi(ApiError? error) {
    if (error == null) {
      return const OperationsFailure(
        code: 'EMPTY_RESPONSE',
        message: 'The server returned no data.',
      );
    }
    return OperationsFailure(
      code: error.code,
      message: error.message,
      fieldErrors: error.fieldErrors,
    );
  }

  OperationsFailure _exceptionFailure(Exception e) {
    return OperationsFailure(
      code: 'EXCEPTION',
      message: e.toString(),
    );
  }
}
