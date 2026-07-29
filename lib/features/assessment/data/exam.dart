import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

/// The wire shape of an exam plan is opaque; the model narrows the well-
/// known fields the mobile client cares about. The full row is preserved
/// on [raw] so future schema additions (e.g. randomisation policy) flow
/// through without an app update.
///
/// Field name mapping (defensive — backend keys can drift):
///   - `id`            ← `name` (Frappe primary key)
///   - `title`         ← `title`, falling back to `exam_name`
///   - `subject`       ← `subject_name` (display), `subject` (rare),
///                       or the `school_subject` link's display name
///   - `examDate`      ← `exam_date` (string YYYY-MM-DD or DateTime)
///   - `durationMinutes` ← `duration_minutes` (the only wire field)
///   - `totalMarks`    ← `max_score` (the only wire field); the mobile
///                       also accepts `total_marks` if the server later
///                       adds it
///   - `status`        ← `status`
///   - `published`     ← `true` when `online_status == 'Published'`,
///                       otherwise `false` (the wire carries a tri-state
///                       "online_status" rather than a boolean)
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
      if (v is num) return v != 0;
      return false;
    }

    String? examDate;
    final rawDate = json['exam_date'];
    if (rawDate is String && rawDate.isNotEmpty) {
      examDate = rawDate;
    } else if (rawDate is DateTime) {
      examDate = rawDate.toIso8601String().split('T').first;
    }

    // `published` is a derived flag: the wire carries a tri-state
    // `status` (Draft / Published / Closed) or `online_status`
    // (legacy). The mobile only cares about the boolean "is this
    // visible right now".
    final onlineStatus = pickString('online_status') ??
        pickString('status');
    final published =
        pickBool('published') || onlineStatus == 'Published';

    return ExamPlan(
      id: pickString('exam_plan') ??
          pickString('name') ??
          pickString('id') ??
          '',
      title: pickString('title') ?? pickString('exam_name') ?? '',
      subject: pickString('subject_name') ??
          pickString('subject') ??
          pickString('school_subject'),
      examDate: examDate,
      durationMinutes: pickInt('duration_minutes') ?? pickInt('duration'),
      // Server doesn't expose `total_marks`; the canonical field is
      // `max_score`. Accept either for forward compat.
      totalMarks: pickInt('total_marks') ??
          pickInt('total') ??
          _asInt(json['max_score']) ??
          _asInt(json['maxScore']),
      status: pickString('status') ?? onlineStatus ?? 'Draft',
      published: published,
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

int? _asInt(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
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

    // Backend options carry `option_key` and `option_text`; the
    // mobile UI widget reads `value` and `label`. Map both ways.
    final rawOptions = (json['options'] is List)
        ? (json['options'] as List)
            .where((e) => e is Map)
            .map((e) {
              final m = Map<String, Object?>.from(e as Map);
              return <String, Object?>{
                'value': m['option_key'] ?? m['value'] ?? m['name'] ?? '',
                'label': m['option_text'] ?? m['label'] ?? m['name'] ?? '',
                'option_key': m['option_key'],
                'option_text': m['option_text'],
                'is_correct': m['is_correct'],
                'sequence': m['sequence'],
              };
            })
            .toList(growable: false)
        : const <JsonMap>[];

    // Type normalization: the wire carries the long form
    //   "Single Choice" / "Multiple Choice" / "True/False" /
    //   "Short Text" / "Long Text" / "Numeric"
    // but the mobile UI narrows to a small set of stable keys. Unknown
    // types fall back to `text` (the `_QuestionCard` widget treats
    // `text` and `essay` as the same TextField).
    final rawType = pickString('question_type') ?? 'text';
    final normalized = _normalizeQuestionType(rawType);

    return ExamQuestion(
      // Backend uses `name` on direct fetches and `question` on
      // attempt-start responses; accept either.
      id: pickString('name') ??
          pickString('id') ??
          pickString('question') ??
          '',
      questionText: pickString('question_text') ?? '',
      questionType: normalized,
      marks: pickInt('marks') ?? 1,
      options: rawOptions,
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
  static const String typeNumeric = 'numeric';
  static const String fallback = 'text';

  @override
  List<Object?> get props =>
      [id, questionText, questionType, marks, options, required];
}

/// Map the backend's long-form question type names to the mobile's
/// stable short keys. Anything we don't recognise falls back to
/// [ExamQuestion.typeText] (treated as a free-form answer).
String _normalizeQuestionType(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'single choice':
    case 'multi_choice':
    case 'multi-choice':
      return ExamQuestion.typeMultiChoice;
    case 'multiple choice':
    case 'multi_select':
    case 'multi-select':
      return ExamQuestion.typeMultiSelect;
    case 'true/false':
    case 'truefalse':
    case 'true_false':
      return ExamQuestion.typeTrueFalse;
    case 'long text':
    case 'essay':
      return ExamQuestion.typeEssay;
    case 'numeric':
    case 'number':
      return ExamQuestion.typeNumeric;
    case 'short text':
    case 'text':
    default:
      return ExamQuestion.typeText;
  }
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
