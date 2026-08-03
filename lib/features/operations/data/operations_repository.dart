// SPDX-License-Identifier: Proprietary
// Operations repository — wraps the v1 read + write operations /
// delivery / auth audit endpoints the admin "Operations" surface
// needs.
//
// Today (read + write operations health + delivery + audit):
//   * `get_school_operations_health` → top-level aggregate
//     (status + per-module KPI maps).
//   * `get_school_delivery_health` → per-status counts of
//     outbound delivery events (notifications, callbacks).
//   * `get_school_auth_audit_events` → list of recent
//     login / token / device-register events for the audit
//     log surface.
//   * `replay_school_delivery_event` → admin re-fires a
//     failed outbox event from the delivery dead-letter
//     queue. Mints a fresh UUID for the `Idempotency-Key`
//     header.
//   * `receive_school_delivery_callback` → admin
//     simulates a provider callback (provider + signature
//     + body) for a delivery event. The v1 SDK exposes
//     this as a top-level write without an `Idempotency-Key`
//     header (callbacks are idempotent on the server).

import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import 'operations_failure.dart';
import 'operations_health.dart';
import 'operations_write.dart';

class OperationsRepository {
  OperationsRepository({
    required LaratikSchoolsApiClient api,
    Uuid? uuid,
  })  : _api = api,
        _uuid = uuid ?? const Uuid();

  final LaratikSchoolsApiClient _api;
  final Uuid _uuid;

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

  /// Replay a dead-letter delivery event. The v1 server
  /// requires `require_security_audit_access()` (admin
  /// role); the payload carries `event_key` + an
  /// optional `reason`. The repository mints a fresh
  /// UUID for the `Idempotency-Key` header so a retry
  /// of the same replay is safe to send again.
  Future<Result<ReplayedDeliveryEvent, OperationsFailure>> replayDeliveryEvent({
    required String eventKey,
    String? reason,
  }) async {
    try {
      final response = await _api.replaySchoolDeliveryEvent(
        payload: <String, Object?>{
          'event_key': eventKey,
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
          error: OperationsFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no replay result.',
          ),
        );
      }
      return Ok(value: ReplayedDeliveryEvent.fromJson(data.toJson()));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Simulate a provider delivery callback. The v1 SDK
  /// exposes this as a top-level write without an
  /// `Idempotency-Key` header (the server is idempotent
  /// on the provider-side); the admin uses it to re-fire
  /// a stuck callback (e.g. a webhook that the provider
  /// retried 3 times but the mobile never got).
  Future<Result<DeliveryCallbackReceipt, OperationsFailure>>
      receiveDeliveryCallback({
    required String provider,
    String? signature,
    String? body,
  }) async {
    try {
      final response = await _api.receiveSchoolDeliveryCallback(
        provider: provider,
        signature: signature,
        body: body,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: OperationsFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no callback receipt.',
          ),
        );
      }
      return Ok(value: DeliveryCallbackReceipt.fromJson(data.toJson()));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }
}
