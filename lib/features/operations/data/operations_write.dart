// SPDX-License-Identifier: Proprietary
// Operations write-flow models — replayed delivery event
// + delivery callback receipt.
//
// The v1 SDK returns `replay_school_delivery_event` and
// `receive_school_delivery_callback` as forward-
// compatible [JsonMap]s. The fields the mobile knows
// about (event_key + replay_count + status for the
// replay envelope; delivery_identity + status for the
// callback receipt) are surfaced as named accessors
// while the full map is preserved on [raw] so future
// schema additions flow through without an app update.

import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

/// The result of a successful `replay_school_delivery_event`
/// call. The v1 wire shape is opaque; the named accessors
/// are best-effort fallbacks.
@immutable
class ReplayedDeliveryEvent extends Equatable {
  const ReplayedDeliveryEvent({
    required this.raw,
    required this.eventKey,
    this.replayCount,
    this.status,
    this.message,
  });

  /// Forward-compat factory. Pulls the well-known keys
  /// (canonical + the legacy aliases) and falls back to
  /// `null` when the wire doesn't carry them.
  ///
  /// The v1 server returns `{event_key, replay_count, status}`
  /// from `replay_school_delivery_event`; the legacy
  /// aliases are kept so a future schema change doesn't
  /// break the mobile.
  factory ReplayedDeliveryEvent.fromJson(JsonMap json) {
    return ReplayedDeliveryEvent(
      raw: json,
      eventKey: _readString(json, const [
        'event_key',
        'name',
        'event',
      ]) ?? '',
      replayCount: _readInt(json, const [
        'replay_count',
        'attempt',
        'retries',
      ]),
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
  final String eventKey;
  final int? replayCount;
  final String? status;
  final String? message;

  bool get hasReplayCount => replayCount != null;
  bool get isSuccess => status == 'replayed' || status == 'success';

  @override
  List<Object?> get props => [raw, eventKey, replayCount, status, message];
}

/// The receipt of a successful
/// `receive_school_delivery_callback` call. The v1 wire
/// shape is `{delivery_identity, status}`.
@immutable
class DeliveryCallbackReceipt extends Equatable {
  const DeliveryCallbackReceipt({
    required this.raw,
    required this.deliveryIdentity,
    this.status,
    this.message,
  });

  /// Forward-compat factory. Pulls the well-known keys
  /// (canonical + the legacy aliases) and falls back to
  /// `null` when the wire doesn't carry them.
  factory DeliveryCallbackReceipt.fromJson(JsonMap json) {
    return DeliveryCallbackReceipt(
      raw: json,
      deliveryIdentity: _readString(json, const [
        'delivery_identity',
        'name',
        'delivery',
        'event_key',
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
  final String deliveryIdentity;
  final String? status;
  final String? message;

  bool get isAccepted =>
      status == 'accepted' ||
      status == 'received' ||
      status == 'success' ||
      status == 'ok';

  @override
  List<Object?> get props =>
      [raw, deliveryIdentity, status, message];
}

String? _readString(JsonMap json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

int? _readInt(JsonMap json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}
