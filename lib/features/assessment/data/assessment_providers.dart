import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import '../../people/data/person_providers.dart';
import 'assessment_repository.dart';
import 'exam.dart';

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  return AssessmentRepository(api: ref.watch(apiClientProvider));
});

class ExamPlansListController extends AutoDisposeAsyncNotifier<ExamPlanPage> {
  String? _cursor;
  String? _subject;
  static const int _pageSize = 50;

  @override
  Future<ExamPlanPage> build() async {
    _cursor = null;
    return _fetchPage(reset: true);
  }

  Future<void> setSubject(String? value) async {
    _subject = value;
    await refresh();
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    final next = await _fetchPage(reset: false);
    state = AsyncValue.data(
      ExamPlanPage(
        plans: [...current.plans, ...next.plans],
        nextCursor: next.nextCursor,
      ),
    );
  }

  Future<void> refresh() async {
    _cursor = null;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(reset: true));
  }

  Future<ExamPlanPage> _fetchPage({required bool reset}) async {
    final repo = ref.read(assessmentRepositoryProvider);
    final result = await repo.listExamPlans(
      cursor: reset ? null : _cursor,
      limit: _pageSize,
      subject: _subject,
    );
    return switch (result) {
      Ok(:final value) => () {
          _cursor = value.nextCursor;
          return value;
        }(),
      Err(:final error) => throw error,
    };
  }
}

final examPlansListProvider =
    AsyncNotifierProvider.autoDispose<ExamPlansListController, ExamPlanPage>(
  ExamPlansListController.new,
);

final examEligibilityProvider = FutureProvider.autoDispose
    .family<Result<EligibilityResult, PersonFailure>, ExamEligibilityArgs>(
        (ref, args) async {
  final repo = ref.watch(assessmentRepositoryProvider);
  return repo.checkEligibility(
    examPlanId: args.examPlanId,
    studentId: args.studentId,
    // The v1 eligibility check requires the enrollment id to match
    // the audience row's `school_enrollment`. The mobile resolves
    // the active enrollment once at the current-student level and
    // passes it through here so the user doesn't have to re-pick it
    // per exam.
    schoolEnrollment: args.schoolEnrollment,
  );
});

@immutable
class ExamEligibilityArgs {
  const ExamEligibilityArgs({
    required this.examPlanId,
    required this.studentId,
    this.schoolEnrollment = '',
  });
  final String examPlanId;
  final String studentId;
  final String schoolEnrollment;

  @override
  bool operator ==(Object other) =>
      other is ExamEligibilityArgs &&
      other.examPlanId == examPlanId &&
      other.studentId == studentId &&
      other.schoolEnrollment == schoolEnrollment;

  @override
  int get hashCode => Object.hash(examPlanId, studentId, schoolEnrollment);
}
