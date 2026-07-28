import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

/// The wire shape of an exam plan is opaque; the model narrows the well-
/// known fields the mobile client cares about. The full row is preserved
/// on [raw] so future schema additions (e.g. randomisation policy) flow
/// through without an app update.
@immutable
class ExamPlan extends Equatable {
  const ExamPlan({
    required this.id,
    required this.title,
    required this.subject,
    required this.examDate,
    required this.durationMinutes,
    required this.totalMarks,
    required this.status,
    required this.published,
    required this.raw,
  });

  factory ExamPlan.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    int? pickInt(String key) {
      final v = json[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    bool pickBool(String key) {
      final v = json[key];
      if (v is bool) return v;
      if (v is String) {
        final s = v.toLowerCase();
        return s == 'true' || s == '1' || s == 'yes';
      }
      return false;
    }

    return ExamPlan(
      id: pickString('name') ?? pickString('id') ?? '',
      title: pickString('title') ?? pickString('exam_name') ?? '',
      subject: pickString('subject') ?? pickString('subject_name'),
      examDate: pickString('exam_date') ?? pickString('date'),
      durationMinutes: pickInt('duration_minutes') ?? pickInt('duration'),
      totalMarks: pickInt('total_marks') ?? pickInt('total'),
      status: pickString('status') ?? 'Draft',
      published: pickBool('published'),
      raw: json,
    );
  }

  final String id;
  final String title;
  final String? subject;
  final String? examDate;
  final int? durationMinutes;
  final int? totalMarks;
  final String status;
  final bool published;
  final JsonMap raw;

  @override
  List<Object?> get props => [
        id,
        title,
        subject,
        examDate,
        durationMinutes,
        totalMarks,
        status,
        published,
      ];
}

@immutable
class ExamQuestion extends Equatable {
  const ExamQuestion({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.marks,
    required this.options,
    required this.required,
    required this.raw,
  });

  factory ExamQuestion.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    int? pickInt(String key) {
      final v = json[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    final options = (json['options'] is List)
        ? (json['options'] as List)
            .where((e) => e is Map)
            .map((e) => Map<String, Object?>.from(e as Map))
            .toList(growable: false)
        : const <JsonMap>[];

    return ExamQuestion(
      id: pickString('name') ?? pickString('id') ?? '',
      questionText: pickString('question_text') ?? '',
      questionType: pickString('question_type') ?? 'text',
      marks: pickInt('marks') ?? 1,
      options: options,
      required: pickString('required') == 'true' ||
          pickInt('required') == 1 ||
          (json['required'] is bool && json['required'] as bool),
      raw: json,
    );
  }

  final String id;
  final String questionText;
  final String questionType;
  final int marks;
  final List<JsonMap> options;
  final bool required;
  final JsonMap raw;

  /// Stable, well-known question types. The wire carries a free string;
  /// unknown types fall back to [fallback].
  static const String typeText = 'text';
  static const String typeMultiChoice = 'multi_choice';
  static const String typeMultiSelect = 'multi_select';
  static const String typeTrueFalse = 'true_false';
  static const String typeEssay = 'essay';
  static const String fallback = 'text';

  @override
  List<Object?> get props =>
      [id, questionText, questionType, marks, options, required];
}

@immutable
class ExamAttemptSummary extends Equatable {
  const ExamAttemptSummary({
    required this.attemptId,
    required this.examPlanId,
    required this.studentId,
    required this.status,
    required this.startedAt,
    required this.submittedAt,
    required this.score,
    required this.totalMarks,
    required this.graded,
  });

  final String attemptId;
  final String examPlanId;
  final String studentId;
  final String status;
  final String? startedAt;
  final String? submittedAt;
  final double? score;
  final int? totalMarks;
  final bool graded;

  @override
  List<Object?> get props => [
        attemptId,
        examPlanId,
        studentId,
        status,
        startedAt,
        submittedAt,
        score,
        totalMarks,
        graded,
      ];
}
