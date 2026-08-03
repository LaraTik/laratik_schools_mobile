// SPDX-License-Identifier: Proprietary
// Forward-compat result model for the
// `promote_school_exam_attempt` write flow.
//
// The v1 wire shape is `{grade_record, status}` where
// `grade_record` is the Frappe name of the new grade
// record the server created from the exam attempt.
// The mobile flattens the well-known fields into named
// accessors and preserves the full envelope on `raw`
// so future schema additions (e.g. `score`,
// `max_score`, `attempt_name`, `promoted_by`) flow
// through without an app update.

import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

@immutable
class PromotedExamAttempt extends Equatable {
  const PromotedExamAttempt({
    required this.raw,
    required this.gradeRecord,
    this.status,
  });

  /// Forward-compat factory. Walks the canonical
  /// `grade_record` key first, then the legacy
  /// `name` / `grade_name` aliases.
  factory PromotedExamAttempt.fromJson(JsonMap json) {
    return PromotedExamAttempt(
      raw: json,
      gradeRecord: _readString(json, const [
        'grade_record',
        'name',
        'grade_name',
      ]) ??
          '',
      status: _readString(json, const ['status', 'state', 'result']),
    );
  }

  final JsonMap raw;
  final String gradeRecord;
  final String? status;

  bool get isPromoted =>
      status == 'promoted' ||
      status == 'Promoted' ||
      status == 'created' ||
      status == 'Created';

  bool get hasGradeRecord => gradeRecord.isNotEmpty;

  @override
  List<Object?> get props => [raw, gradeRecord, status];
}

String? _readString(JsonMap json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}
