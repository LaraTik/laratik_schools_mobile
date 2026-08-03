// SPDX-License-Identifier: Proprietary
// Grading write-flow models — grade record correction.
//
// The v1 SDK returns `correct_school_grade_record` as a
// forward-compatible [JsonMap]; the fields the mobile
// knows about (the corrected grade's id + the new score
// + the actor + the timestamp) are surfaced as named
// accessors while the full map is preserved on [raw]
// so future schema additions flow through without an app
// update. The form payload is a tiny immutable shape with
// a [copyWith] sentinel for null-clearing (the same
// pattern the Student + Staff + Guardian create screens
// use).

import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

/// The result of a successful `correct_school_grade_record`
/// call. The v1 wire shape is opaque; the named accessors
/// are best-effort fallbacks.
@immutable
class CorrectedGradeRecord extends Equatable {
  const CorrectedGradeRecord({
    required this.raw,
    required this.gradeName,
    this.correctedScore,
    this.correctedMaxScore,
    this.actor,
    this.timestamp,
    this.message,
  });

  /// Forward-compat factory. Pulls the well-known keys
  /// (canonical + the legacy aliases) and falls back to
  /// `null` when the wire doesn't carry them.
  ///
  /// The v1 server returns `{grade_record, status}` from
  /// `correct_published_grade`; the legacy aliases are
  /// kept so a future schema change doesn't break the
  /// mobile.
  factory CorrectedGradeRecord.fromJson(JsonMap json) {
    final grade = _readString(json, const [
      'grade_record',
      'grade_name',
      'name',
      'grade',
    ]);
    return CorrectedGradeRecord(
      raw: json,
      gradeName: grade ?? '',
      correctedScore: _readDouble(json, const [
        'corrected_score',
        'score',
        'final_score',
      ]),
      correctedMaxScore: _readDouble(json, const [
        'corrected_max_score',
        'max_score',
      ]),
      actor: _readString(json, const ['actor', 'user', 'corrected_by']),
      timestamp: _readString(json, const [
        'timestamp',
        'corrected_at',
        'modified',
        'approved_on',
      ]),
      message: _readString(json, const [
        'message',
        'note',
        'status_message',
        'status',
      ]),
    );
  }

  final JsonMap raw;
  final String gradeName;
  final double? correctedScore;
  final double? correctedMaxScore;
  final String? actor;
  final String? timestamp;
  final String? message;

  bool get hasScore => correctedScore != null;
  bool get hasMaxScore => correctedMaxScore != null;

  @override
  List<Object?> get props => [
        raw,
        gradeName,
        correctedScore,
        correctedMaxScore,
        actor,
        timestamp,
        message,
      ];
}

/// Immutable payload for the "correct a grade" form.
/// The [copyWith] sentinel is `clearReason: true` to
/// distinguish "leave the reason unchanged" from
/// "explicitly clear the reason to empty".
@immutable
class GradeRecordCorrectionPayload extends Equatable {
  const GradeRecordCorrectionPayload({
    required this.gradeName,
    this.score,
    this.maxScore,
    this.reason,
  });

  const GradeRecordCorrectionPayload.empty(this.gradeName)
      : score = null,
        maxScore = null,
        reason = null;

  final String gradeName;
  final String? score;
  final String? maxScore;
  final String? reason;

  bool get isValid {
    final s = double.tryParse(score ?? '');
    final m = double.tryParse(maxScore ?? '');
    if (s == null || m == null) return false;
    if (s < 0 || m <= 0) return false;
    if (s > m) return false;
    return true;
  }

  GradeRecordCorrectionPayload copyWith({
    String? gradeName,
    String? score,
    String? maxScore,
    String? reason,
    bool clearReason = false,
  }) {
    return GradeRecordCorrectionPayload(
      gradeName: gradeName ?? this.gradeName,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      reason: clearReason ? null : (reason ?? this.reason),
    );
  }

  @override
  List<Object?> get props => [gradeName, score, maxScore, reason];
}

String? _readString(JsonMap json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

double? _readDouble(JsonMap json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}
