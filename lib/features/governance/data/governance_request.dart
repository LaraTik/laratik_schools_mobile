// SPDX-License-Identifier: Proprietary
// Data governance models — privacy requests, legal hold, retention.
//
// The v1 contract returns these as forward-compatible [JsonMap]s;
// the fields the mobile knows about are surfaced as named
// accessors while the full map is preserved on [raw] so future
// schema additions (legal-hold release events, retention
// evaluation results, governance settings diffs) flow through
// without an app update.
//
// "Privacy request" is the core entity. The wire shape is
// deliberately open — the admin surface is read-mostly, and
// the approve / process / set-legal-hold actions accept a
// free-form `payload` so the server can grow fields without
// an app update. The mobile renders the wire value as-is
// for the display fields and groups rows by the lifecycle
// status (Submitted / Under Review / Approved / Rejected /
// Legal Hold) so the admin can scan the queue at a glance.

import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

/// A privacy request row from
/// `get_school_privacy_requests`. The wire shape is open;
/// the mobile renders the canonical display fields with
/// safe fallbacks.
@immutable
class PrivacyRequest extends Equatable {
  const PrivacyRequest({
    required this.id,
    required this.subject,
    required this.subjectName,
    required this.requestType,
    required this.status,
    required this.submittedBy,
    required this.submittedAt,
    required this.legalHold,
    required this.notes,
    required this.raw,
  });

  factory PrivacyRequest.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    return PrivacyRequest(
      id: pickString('name') ?? pickString('id') ?? '',
      subject: pickString('school_student') ??
          pickString('school_staff') ??
          pickString('subject') ??
          '',
      subjectName: pickString('subject_name') ??
          pickString('student_name') ??
          pickString('staff_name') ??
          '',
      requestType: pickString('request_type') ??
          pickString('type') ??
          pickString('category') ??
          'data_export',
      status:
          pickString('status') ?? pickString('request_status') ?? 'Submitted',
      submittedBy: pickString('submitted_by') ??
          pickString('requester') ??
          pickString('owner') ??
          '',
      submittedAt: pickString('submitted_at') ?? pickString('created_at') ?? '',
      legalHold: pickString('legal_hold') == '1' ||
          pickString('legal_hold')?.toLowerCase() == 'true',
      notes: pickString('notes') ?? pickString('description') ?? '',
      raw: json,
    );
  }

  /// The privacy request's Frappe primary key
  /// (e.g. `EDU-PR-2026-00001`).
  final String id;

  /// The school student or staff the request is about
  /// (e.g. `STU-00001`). Empty when the request is a
  /// school-wide governance action.
  final String subject;

  /// Display name for the subject. The mobile uses this as
  /// the primary row subtitle in the privacy list.
  final String subjectName;

  /// One of `data_export` / `data_deletion` / `data_access`
  /// / `consent_withdrawal` / `legal_hold` /
  /// `governance_settings` — the v1 server's canonical set
  /// (the mobile falls back to the wire value if the server
  /// grows a new type).
  final String requestType;

  /// One of `Submitted` / `Under Review` / `Approved` /
  /// `Rejected` / `Legal Hold`. The mobile groups by this
  /// for the queue overview chip strip.
  final String status;

  /// The user that submitted the request.
  final String submittedBy;

  /// When the request was submitted (the wire value is the
  /// server's ISO timestamp; the surface passes it through
  /// unchanged).
  final String submittedAt;

  /// True when the request is currently under legal hold.
  /// The mobile renders a distinct chip so the admin can
  /// spot held requests at a glance.
  final bool legalHold;

  /// Free-form notes the requester attached. The mobile
  /// renders this as the row's secondary line.
  final String notes;

  final JsonMap raw;

  /// A coarse status family for the chip tone. The mobile
  /// maps:
  ///   * `Approved` / `Completed` → success
  ///   * `Rejected` / `Denied` / `Cancelled` → error
  ///   * `Legal Hold` / `Hold` → warning
  ///   * `Under Review` / `Processing` → info
  ///   * `Submitted` / `Pending` → brand
  ///   * anything else → neutral
  String get statusFamily {
    final s = status.toLowerCase();
    if (s.contains('approved') || s.contains('completed')) return 'approved';
    if (s.contains('rejected') ||
        s.contains('denied') ||
        s.contains('cancelled')) {
      return 'rejected';
    }
    if (s.contains('legal') || s.contains('hold')) return 'hold';
    if (s.contains('review') || s.contains('processing')) return 'review';
    if (s.contains('submitted') || s.contains('pending')) return 'pending';
    return 'other';
  }

  /// A coarse type family for the chip / icon. The mobile
  /// maps the canonical request type to a Material icon.
  String get typeFamily {
    final t = requestType.toLowerCase();
    if (t.contains('export') || t.contains('access')) return 'access';
    if (t.contains('deletion') || t.contains('erase')) return 'deletion';
    if (t.contains('consent')) return 'consent';
    if (t.contains('legal') || t.contains('hold')) return 'legal_hold';
    if (t.contains('governance') || t.contains('settings')) return 'governance';
    return 'other';
  }

  @override
  List<Object?> get props => [
        id,
        subject,
        subjectName,
        requestType,
        status,
        submittedBy,
        submittedAt,
        legalHold,
        notes,
      ];
}

/// Paged list of privacy requests.
@immutable
class PrivacyRequestPage extends Equatable {
  const PrivacyRequestPage({required this.requests});
  final List<PrivacyRequest> requests;

  @override
  List<Object?> get props => [requests];
}

/// A summary of a privacy request's lifecycle actions
/// (approve / process / set legal hold). The server returns
/// the list of actions that have been taken so far; the
/// mobile renders the count + the latest actor.
@immutable
class PrivacyRequestTimeline extends Equatable {
  const PrivacyRequestTimeline({
    required this.entries,
  });

  factory PrivacyRequestTimeline.fromJson(JsonMap json) {
    final entries = json['entries'];
    final list = entries is List
        ? entries
            .whereType<Map<String, Object?>>()
            .map(PrivacyTimelineEntry.fromJson)
            .toList(growable: false)
        : const <PrivacyTimelineEntry>[];
    return PrivacyRequestTimeline(entries: list);
  }

  final List<PrivacyTimelineEntry> entries;

  int get count => entries.length;

  @override
  List<Object?> get props => [entries];
}

/// A single entry in a privacy request's timeline.
@immutable
class PrivacyTimelineEntry extends Equatable {
  const PrivacyTimelineEntry({
    required this.action,
    required this.actor,
    required this.timestamp,
    required this.note,
  });

  factory PrivacyTimelineEntry.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    return PrivacyTimelineEntry(
      action: pickString('action') ?? pickString('event') ?? '',
      actor: pickString('actor') ?? pickString('user') ?? '',
      timestamp: pickString('timestamp') ?? pickString('occurred_at') ?? '',
      note: pickString('note') ?? pickString('notes') ?? '',
    );
  }

  final String action;
  final String actor;
  final String timestamp;
  final String note;

  @override
  List<Object?> get props => [action, actor, timestamp, note];
}

/// The result of a successful `submit_school_privacy_request`
/// call from a parent or student. The v1 wire shape is
/// `{privacy_request, status}`. The named accessors are
/// best-effort fallbacks.
@immutable
class SubmittedPrivacyRequest extends Equatable {
  const SubmittedPrivacyRequest({
    required this.raw,
    required this.privacyRequest,
    this.status,
    this.message,
  });

  /// Forward-compat factory. Pulls the well-known keys
  /// (canonical + the legacy aliases) and falls back to
  /// `null` when the wire doesn't carry them.
  factory SubmittedPrivacyRequest.fromJson(JsonMap json) {
    return SubmittedPrivacyRequest(
      raw: json,
      privacyRequest: _readString(json, const [
        'privacy_request',
        'name',
        'request',
      ]) ?? '',
      status: _readString(json, const [
        'status',
        'state',
        'result',
      ]),
      message: _readString(json, const [
        'message',
        'note',
        'status_message',
      ]),
    );
  }

  final JsonMap raw;
  final String privacyRequest;
  final String? status;
  final String? message;

  bool get isSubmitted => status == 'submitted' || status == 'received';
  bool get hasName => privacyRequest.isNotEmpty;

  @override
  List<Object?> get props => [raw, privacyRequest, status, message];
}

String? _readString(JsonMap json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}
