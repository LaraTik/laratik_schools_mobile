import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import '../../people/data/person_providers.dart';
import 'academics_repository.dart';
import 'subject.dart';

final academicsRepositoryProvider = Provider<AcademicsRepository>((ref) {
  return AcademicsRepository(api: ref.watch(apiClientProvider));
});

class SubjectsListController extends AutoDisposeAsyncNotifier<SubjectPage> {
  String? _cursor;
  String _search = '';
  String? _department;
  static const int _pageSize = 50;

  @override
  Future<SubjectPage> build() async {
    _cursor = null;
    return _fetchPage(reset: true);
  }

  Future<void> setSearch(String value) async {
    _search = value;
    await refresh();
  }

  Future<void> setDepartment(String? value) async {
    _department = value;
    await refresh();
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    final next = await _fetchPage(reset: false);
    state = AsyncValue.data(
      SubjectPage(
        subjects: [...current.subjects, ...next.subjects],
        nextCursor: next.nextCursor,
      ),
    );
  }

  Future<void> refresh() async {
    _cursor = null;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(reset: true));
  }

  Future<SubjectPage> _fetchPage({required bool reset}) async {
    final repo = ref.read(academicsRepositoryProvider);
    final result = await repo.listSubjects(
      cursor: reset ? null : _cursor,
      limit: _pageSize,
      search: _search.isEmpty ? null : _search,
      department: _department,
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

final subjectsListProvider =
    AsyncNotifierProvider.autoDispose<SubjectsListController, SubjectPage>(
  SubjectsListController.new,
);

class TimetableListController extends AutoDisposeAsyncNotifier<TimetablePage> {
  String? _cursor;
  String? _branch;
  String? _academicYear;
  static const int _pageSize = 100;

  @override
  Future<TimetablePage> build() async {
    _cursor = null;
    return _fetchPage(reset: true);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    final next = await _fetchPage(reset: false);
    state = AsyncValue.data(
      TimetablePage(
        slots: [...current.slots, ...next.slots],
        nextCursor: next.nextCursor,
      ),
    );
  }

  Future<TimetablePage> _fetchPage({required bool reset}) async {
    final repo = ref.read(academicsRepositoryProvider);
    final result = await repo.listTimetable(
      cursor: reset ? null : _cursor,
      limit: _pageSize,
      branch: _branch,
      academicYear: _academicYear,
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

final timetableListProvider =
    AsyncNotifierProvider.autoDispose<TimetableListController, TimetablePage>(
  TimetableListController.new,
);

final branchesListProvider = FutureProvider.autoDispose
    .family<Result<BranchPage, PersonFailure>, void>((ref, _) async {
  final repo = ref.watch(academicsRepositoryProvider);
  return repo.listBranches();
});
