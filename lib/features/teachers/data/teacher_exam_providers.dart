// SPDX-License-Identifier: Proprietary
// Riverpod wiring for the Teacher exam surface.
//
// Today (teacher exam authoring + manual grading):
//   * `teacherExamRepositoryProvider` — single instance
//     per app session.
//   * `teacherExamPlansProvider` — AsyncNotifier for the
//     teacher's exam plans list. Manual [refresh] for
//     pull-to-refresh. Returns ALL plans (drafts +
//     closed) for the current teacher; the server is
//     expected to filter to the current user when the
//     session is a teacher role.
//   * `teacherExamQuestionsProvider` — family-keyed
//     AsyncNotifier keyed on the plan's subject (the
//     server filters `get_school_questions` by subject).
//   * `manualGradeControllerProvider` — exposes a manual
//     grade submit action. The screen calls
//     [ManualGradeController.submit] which mints the
//     idempotency key and invalidates the plan list on
//     success.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../assessment/data/assessment_repository.dart' show ExamPlanPage;
import '../../assessment/data/exam.dart';
import '../../people/data/person_failure.dart';
import '../../people/data/person_providers.dart';
import 'teacher_exam_repository.dart';

/// Single teacher exam repository per app session. All
/// Teacher exam feature code reads it from this provider.
final teacherExamRepositoryProvider = Provider<TeacherExamRepository>((ref) {
  return TeacherExamRepository(api: ref.watch(apiClientProvider));
});

/// Teacher exam plans list. AsyncNotifier so the screen
/// can `ref.watch` and receive loading / data / error
/// transitions from a single source of truth. Manual
/// [refresh] for pull-to-refresh.
class TeacherExamPlansController
    extends AutoDisposeAsyncNotifier<ExamPlanPage> {
  @override
  Future<ExamPlanPage> build() async {
    final repo = ref.read(teacherExamRepositoryProvider);
    final result = await repo.listExamPlans();
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<ExamPlanPage>(() async {
      final repo = ref.read(teacherExamRepositoryProvider);
      final result = await repo.listExamPlans();
      return switch (result) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
    });
  }
}

final teacherExamPlansProvider = AsyncNotifierProvider.autoDispose<
    TeacherExamPlansController, ExamPlanPage>(
  TeacherExamPlansController.new,
);

/// Per-subject question list. Family-keyed so the
/// detail screen can refetch the questions for a single
/// subject without reloading every other subject's
/// question set in the app.
class TeacherExamQuestionsController extends AutoDisposeFamilyAsyncNotifier<
    List<TeacherExamQuestion>, String> {
  @override
  Future<List<TeacherExamQuestion>> build(String subject) async {
    final repo = ref.read(teacherExamRepositoryProvider);
    final result = await repo.listQuestions(schoolSubject: subject);
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };
  }

  Future<void> refresh() async {
    final subject = arg;
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard<List<TeacherExamQuestion>>(() async {
      final repo = ref.read(teacherExamRepositoryProvider);
      final result = await repo.listQuestions(schoolSubject: subject);
      return switch (result) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
    });
  }
}

final teacherExamQuestionsProvider = AsyncNotifierProvider.autoDispose
    .family<TeacherExamQuestionsController, List<TeacherExamQuestion>, String>(
  TeacherExamQuestionsController.new,
);

/// Manual grade submit controller. The screen reads the
/// current state (idle / loading / success / error) and
/// calls [submit] from the form action.
class ManualGradeSubmitController
    extends AutoDisposeFamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String attempt) async {
    // No-op build; the screen only needs the [submit]
    // action. The provider is invalidated by the screen
    // after a successful submit.
  }

  /// Submit the per-question scores for [attempt]. On
  /// success, the teacher's plans list provider is
  /// invalidated so the next read re-fetches.
  Future<Result<TeacherExamAttemptGrade, PersonFailure>> submit({
    required Map<String, double> scores,
  }) async {
    final attempt = arg;
    state = const AsyncValue.loading();
    final repo = ref.read(teacherExamRepositoryProvider);
    final result = await repo.gradeAttempt(
      attempt: attempt,
      scores: scores,
    );
    switch (result) {
      case Ok(:final value):
        state = const AsyncValue.data(null);
        ref.invalidate(teacherExamPlansProvider);
        return Ok(value: value);
      case Err(:final error):
        state = AsyncValue.error(error, StackTrace.current);
        return Err(error: error);
    }
  }
}

final manualGradeSubmitProvider = AsyncNotifierProvider.autoDispose.family<
    ManualGradeSubmitController, void, String>(
  ManualGradeSubmitController.new,
);

/// Create a new exam plan shell. The screen reads the
/// current state and calls [submit] from the form action.
class CreateTeacherExamPlanController
    extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No-op build; the screen only needs the [submit]
    // action.
  }

  /// Create a new exam plan. On success, the teacher's
  /// plans list provider is invalidated.
  Future<Result<String, PersonFailure>> submit({
    required String title,
    String? schoolSubject,
    String? schoolBranch,
    String? schoolClassGroup,
    String? examDate,
    int? durationMinutes,
    int? maxScore,
  }) async {
    state = const AsyncValue.loading();
    final repo = ref.read(teacherExamRepositoryProvider);
    final result = await repo.createExamPlan(
      title: title,
      schoolSubject: schoolSubject,
      schoolBranch: schoolBranch,
      schoolClassGroup: schoolClassGroup,
      examDate: examDate,
      durationMinutes: durationMinutes,
      maxScore: maxScore,
    );
    switch (result) {
      case Ok(:final value):
        state = const AsyncValue.data(null);
        ref.invalidate(teacherExamPlansProvider);
        return Ok(value: value);
      case Err(:final error):
        state = AsyncValue.error(error, StackTrace.current);
        return Err(error: error);
    }
  }
}

final createTeacherExamPlanProvider = AsyncNotifierProvider.autoDispose<
    CreateTeacherExamPlanController, void>(
  CreateTeacherExamPlanController.new,
);

/// Resolve a single exam plan by id from the current
/// list. The detail screen calls this to get the
/// plan record + its subject for the question fetch.
ExamPlan? resolveTeacherExamPlan(
  WidgetRef ref,
  String examPlanId,
) {
  final page = ref.read(teacherExamPlansProvider).value;
  if (page == null) return null;
  return page.plans
      .where((p) => p.id == examPlanId)
      .firstOrNull;
}
