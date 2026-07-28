import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import '../../people/data/person_providers.dart';
import 'assessment_repository.dart';
import 'exam.dart';

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  return AssessmentRepository(api: ref.watch(apiClientProvider));
});

class ExamPlansListController
    extends AutoDisposeAsyncNotifier<AsyncValue<ExamPlanPage>> {
  String? _cursor;
  String? _subject;
  static const int _pageSize = 50;

  @override
  Future<AsyncValue<ExamPlanPage>> build() async {
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
    state = next.whenData(
      (page) => ExamPlanPage(
        plans: [...current.plans, ...page.plans],
        nextCursor: page.nextCursor,
      ),
    );
  }

  Future<void> refresh() async {
    _cursor = null;
    state = const AsyncLoading();
    state = await _fetchPage(reset: true);
  }

  Future<AsyncValue<ExamPlanPage>> _fetchPage({required bool reset}) async {
    final repo = ref.read(assessmentRepositoryProvider);
    final result = await repo.listExamPlans(
      cursor: reset ? null : _cursor,
      limit: _pageSize,
      subject: _subject,
    );
    return switch (result) {
      Ok(:final value) => () {
          _cursor = value.nextCursor;
          return AsyncData(value);
        }(),
      Err(:final error) => AsyncError(error, StackTrace.current),
    };
  }
}

final examPlansListProvider = AsyncNotifierProvider.autoDispose<
    ExamPlansListController, AsyncValue<ExamPlanPage>>(
  ExamPlansListController.new,
);

final examEligibilityProvider = FutureProvider.autoDispose
    .family<Result<EligibilityResult, PersonFailure>, ExamEligibilityArgs>(
        (ref, args) async {
  final repo = ref.watch(assessmentRepositoryProvider);
  return repo.checkEligibility(
    examPlanId: args.examPlanId,
    studentId: args.studentId,
  );
});

@immutable
class ExamEligibilityArgs {
  const ExamEligibilityArgs({
    required this.examPlanId,
    required this.studentId,
  });
  final String examPlanId;
  final String studentId;

  @override
  bool operator ==(Object other) =>
      other is ExamEligibilityArgs &&
      other.examPlanId == examPlanId &&
      other.studentId == studentId;

  @override
  int get hashCode => Object.hash(examPlanId, studentId);
}
