// SPDX-License-Identifier: Proprietary
// Tests for the ExamPlan / ExamQuestion wire-format normalisation.
// The Frappe backend returns long-form field names and question type
// labels; the mobile narrows them to the keys the UI widgets read.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_mobile/features/assessment/data/exam.dart';

void main() {
  group('ExamPlan.fromJson', () {
    test('parses long-form Frappe keys (name, exam_name, max_score, online_status)', () {
      final plan = ExamPlan.fromJson({
        'name': 'EXM-00002',
        'exam_name': 'Arithmetic Practice Quiz',
        'school_branch': 'Main Campus',
        'subject_name': 'Mathematics',
        'school_subject': 'SUB-Mathematics-Main-Campus',
        'exam_date': '2026-07-28',
        'duration_minutes': 10,
        'max_score': 6.0,
        'status': 'Published',
        'online_status': 'Published',
      });
      expect(plan.id, 'EXM-00002');
      expect(plan.title, 'Arithmetic Practice Quiz');
      expect(plan.subject, 'Mathematics');
      expect(plan.examDate, '2026-07-28');
      expect(plan.durationMinutes, 10);
      expect(plan.totalMarks, 6);
      expect(plan.published, isTrue,
          reason: 'online_status=Published should derive published=true');
      expect(plan.status, 'Published');
    });

    test('maps non-Published online_status to published=false', () {
      final plan = ExamPlan.fromJson({
        'name': 'EXM-00003',
        'exam_name': 'Draft Quiz',
        'online_status': 'Draft',
        'status': 'Draft',
      });
      expect(plan.published, isFalse);
    });

    test('accepts legacy title/total_marks/published fields for forward compat', () {
      final plan = ExamPlan.fromJson({
        'name': 'EXM-00004',
        'title': 'Legacy Midterm',
        'subject': 'History',
        'total_marks': 50,
        'duration_minutes': 60,
        'published': true,
      });
      expect(plan.title, 'Legacy Midterm');
      expect(plan.subject, 'History');
      expect(plan.totalMarks, 50);
      expect(plan.published, isTrue);
    });
  });

  group('ExamQuestion.fromJson', () {
    test('normalises Single Choice -> multi_choice and maps options', () {
      final q = ExamQuestion.fromJson({
        'name': 'QUE-00001',
        'question_text': 'What is 7 + 5?',
        'question_type': 'Single Choice',
        'marks': 1,
        'options': [
          {'option_key': 'A', 'option_text': '10', 'is_correct': 0, 'sequence': 1},
          {'option_key': 'C', 'option_text': '12', 'is_correct': 1, 'sequence': 3},
        ],
      });
      expect(q.questionType, ExamQuestion.typeMultiChoice);
      expect(q.options, hasLength(2));
      expect(q.options.first['value'], 'A');
      expect(q.options.first['label'], '10');
    });

    test('normalises Multiple Choice -> multi_select', () {
      final q = ExamQuestion.fromJson({
        'name': 'QUE-00002',
        'question_text': 'Pick the primes',
        'question_type': 'Multiple Choice',
        'marks': 2,
        'options': [
          {'option_key': 'B', 'option_text': '2', 'is_correct': 1},
          {'option_key': 'D', 'option_text': '4', 'is_correct': 0},
        ],
      });
      expect(q.questionType, ExamQuestion.typeMultiSelect);
    });

    test('normalises True/False -> true_false', () {
      final q = ExamQuestion.fromJson({
        'name': 'QUE-00003',
        'question_text': '9 * 6 = 54',
        'question_type': 'True/False',
        'marks': 1,
      });
      expect(q.questionType, ExamQuestion.typeTrueFalse);
    });

    test('normalises Short Text -> text', () {
      final q = ExamQuestion.fromJson({
        'name': 'QUE-00005',
        'question_text': 'Solve for x',
        'question_type': 'Short Text',
        'marks': 1,
      });
      expect(q.questionType, ExamQuestion.typeText);
    });

    test('normalises Long Text -> essay', () {
      final q = ExamQuestion.fromJson({
        'name': 'QUE-00006',
        'question_text': 'Discuss...',
        'question_type': 'Long Text',
        'marks': 5,
      });
      expect(q.questionType, ExamQuestion.typeEssay);
    });

    test('normalises Numeric -> numeric', () {
      final q = ExamQuestion.fromJson({
        'name': 'QUE-00007',
        'question_text': 'How many?',
        'question_type': 'Numeric',
        'marks': 1,
      });
      expect(q.questionType, ExamQuestion.typeNumeric);
    });

    test('falls back to text for unknown types', () {
      final q = ExamQuestion.fromJson({
        'name': 'QUE-00008',
        'question_text': '???',
        'question_type': 'Esoteric Type',
        'marks': 1,
      });
      expect(q.questionType, ExamQuestion.typeText);
    });

    test('reads id from `question` field (start_attempt response shape)', () {
      final q = ExamQuestion.fromJson({
        'question': 'QUE-00009',
        'question_text': 'Attempt response uses `question`, not `name`',
        'question_type': 'text',
        'marks': 1,
      });
      expect(q.id, 'QUE-00009');
    });
  });
}
