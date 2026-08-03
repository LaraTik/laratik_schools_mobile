// SPDX-License-Identifier: Proprietary
// Operations health + delivery health + auth audit event models.
//
// The v1 contract returns these as forward-compatible [JsonMap]s;
// the fields the mobile knows about are surfaced as named
// accessors while the full map is preserved on [raw] so future
// schema additions (per-module score, per-status counts,
// alert thresholds) flow through without an app update.
//
// "Operations health" is the top-level aggregate:
//   * status — overall system health ('healthy' / 'degraded' /
//     'unhealthy' / unknown).
//   * generatedAt — when the server built this snapshot.
//   * analytics / audit / delivery / imports / outbox — nested
//     per-module KPI maps. The mobile renders their keys as
//     a flat KPI grid so the surface stays useful even when
//     the server grows a new metric.
//
// "Delivery health" is the per-status count of outbound delivery
// events (notifications, callbacks, etc). The mobile renders the
// counts as a small bar chart + table.
//
// "Auth audit event" is a single row from the
// `get_school_auth_audit_events` list. The mobile renders the
// most common fields (event type, user, timestamp, ip) and
// preserves the full row on [raw] for future drill-downs.

import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

/// Top-level operations health snapshot.
@immutable
class OperationsHealth extends Equatable {
  const OperationsHealth({
    required this.status,
    required this.generatedAt,
    required this.analytics,
    required this.audit,
    required this.delivery,
    required this.imports,
    required this.outbox,
    required this.raw,
  });

  factory OperationsHealth.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    JsonMap? pickMap(String key) {
      final v = json[key];
      if (v is Map) return Map<String, Object?>.from(v);
      return null;
    }

    return OperationsHealth(
      status: pickString('status') ?? 'unknown',
      generatedAt: pickString('generated_at') ?? '',
      analytics: pickMap('analytics') ?? const <String, Object?>{},
      audit: pickMap('audit') ?? const <String, Object?>{},
      delivery: pickMap('delivery') ?? const <String, Object?>{},
      imports: pickMap('imports') ?? const <String, Object?>{},
      outbox: pickMap('outbox') ?? const <String, Object?>{},
      raw: json,
    );
  }

  /// 'healthy' / 'degraded' / 'unhealthy' / 'unknown' (forward
  /// compat — the server may add new values).
  final String status;

  /// When the server built this snapshot. The mobile renders
  /// this as a small "Generated at" sub-line.
  final String generatedAt;

  /// Per-module KPI maps. Keys are the server-defined metric
  /// names; values are the wire values (typically `num` /
  /// `String` / `bool`). The mobile renders them as a flat
  /// KPI grid in the order the server returns them.
  final JsonMap analytics;
  final JsonMap audit;
  final JsonMap delivery;
  final JsonMap imports;
  final JsonMap outbox;

  final JsonMap raw;

  /// True when the server reports the system is healthy. The
  /// mobile renders a green chip + the status text.
  bool get isHealthy => status.toLowerCase() == 'healthy';

  /// True when the server reports the system is degraded.
  /// The mobile renders a yellow chip + the status text.
  bool get isDegraded => status.toLowerCase() == 'degraded';

  /// True when the server reports the system is unhealthy.
  /// The mobile renders a red chip + the status text.
  bool get isUnhealthy => status.toLowerCase() == 'unhealthy';

  /// Flat list of (module, key, value) tuples for the
  /// module-KPI grid. The mobile iterates this to render the
  /// "Analytics" / "Audit" / "Delivery" / "Imports" / "Outbox"
  /// sections in the surface.
  List<ModuleKpi> get moduleKpis {
    final out = <ModuleKpi>[];
    void addAll(String module, JsonMap map) {
      map.forEach((key, value) {
        out.add(ModuleKpi(
          module: module,
          key: key,
          value: value,
        ));
      });
    }

    addAll('analytics', analytics);
    addAll('audit', audit);
    addAll('delivery', delivery);
    addAll('imports', imports);
    addAll('outbox', outbox);
    return out;
  }

  @override
  List<Object?> get props =>
      [status, generatedAt, analytics, audit, delivery, imports, outbox];
}

/// A single module-KPI triple. The module is the parent group
/// ('analytics' / 'audit' / 'delivery' / 'imports' / 'outbox'),
/// the key is the server-defined metric name, and the value is
/// the wire value (the mobile renders numbers + booleans
/// specially; everything else falls through to a string).
@immutable
class ModuleKpi extends Equatable {
  const ModuleKpi({
    required this.module,
    required this.key,
    required this.value,
  });

  final String module;
  final String key;
  final Object? value;

  @override
  List<Object?> get props => [module, key, value];
}

/// Delivery health: per-status counts of outbound events.
@immutable
class DeliveryHealth extends Equatable {
  const DeliveryHealth({
    required this.statusCounts,
    required this.raw,
  });

  factory DeliveryHealth.fromJson(JsonMap json) {
    final counts = json['status_counts'];
    return DeliveryHealth(
      statusCounts: counts is Map
          ? Map<String, Object?>.from(counts)
          : const <String, Object?>{},
      raw: json,
    );
  }

  /// Per-status counts. Keys are the wire-defined status
  /// names (e.g. `pending`, `completed`, `failed`); values
  /// are typically `int`. The mobile renders them sorted
  /// by count (descending) and shows each as a chip +
  /// stacked bar.
  final JsonMap statusCounts;

  final JsonMap raw;

  /// True when the server returned no counts. The mobile
  /// renders a calm empty state.
  bool get isEmpty => statusCounts.isEmpty;

  /// Sorted list of (status, count) tuples for the bar chart.
  List<MapEntry<String, int>> sortedCounts() {
    final entries = statusCounts.entries
        .map((e) => MapEntry(
              e.key,
              e.value is num
                  ? (e.value as num).toInt()
                  : int.tryParse(e.value?.toString() ?? '') ?? 0,
            ))
        .where((e) => e.value > 0)
        .toList(growable: false);
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Total across all statuses. The mobile renders this as
  /// the "Total" KPI on the delivery health tab.
  int get total =>
      sortedCounts().fold<int>(0, (sum, entry) => sum + entry.value);

  @override
  List<Object?> get props => [statusCounts];
}

/// A single auth audit event row.
@immutable
class AuthAuditEvent extends Equatable {
  const AuthAuditEvent({
    required this.eventType,
    required this.user,
    required this.timestamp,
    required this.ipAddress,
    required this.userAgent,
    required this.raw,
  });

  factory AuthAuditEvent.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    return AuthAuditEvent(
      eventType: pickString('event_type') ??
          pickString('event') ??
          pickString('action') ??
          '',
      user: pickString('user') ??
          pickString('user_email') ??
          pickString('actor') ??
          '',
      timestamp: pickString('timestamp') ?? pickString('occurred_at') ?? '',
      ipAddress: pickString('ip_address') ?? pickString('ip') ?? '',
      userAgent: pickString('user_agent') ?? '',
      raw: json,
    );
  }

  /// The event type (e.g. `login`, `logout`, `token_refresh`,
  /// `device_register`). The mobile renders this as a chip
  /// + a color tone per family.
  final String eventType;

  /// The user that triggered the event (email or id).
  final String user;

  /// When the event happened. The mobile renders this as the
  /// row's subtitle (the wire value is the server's ISO
  /// timestamp; the surface passes it through unchanged).
  final String timestamp;

  /// The source IP address, if the server tracked it.
  final String ipAddress;

  /// The source user agent, if the server tracked it.
  final String userAgent;

  final JsonMap raw;

  /// A coarse family for the chip tone. The mobile maps:
  ///   * `login*` → success
  ///   * `logout*` → neutral
  ///   * `token_refresh*` → info
  ///   * `device_register*` → brand
  ///   * anything else → warning (so unknown events stand out).
  String get family {
    final et = eventType.toLowerCase();
    if (et.startsWith('login')) return 'login';
    if (et.startsWith('logout')) return 'logout';
    if (et.startsWith('token_refresh')) return 'token_refresh';
    if (et.startsWith('device_register')) return 'device_register';
    return 'other';
  }

  @override
  List<Object?> get props => [eventType, user, timestamp, ipAddress, userAgent];
}

/// Paged list of auth audit events.
@immutable
class AuthAuditPage extends Equatable {
  const AuthAuditPage({required this.events});
  final List<AuthAuditEvent> events;

  @override
  List<Object?> get props => [events];
}
