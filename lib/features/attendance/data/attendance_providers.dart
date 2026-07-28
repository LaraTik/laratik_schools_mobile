import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import '../../people/data/person_providers.dart';
import 'attendance_record.dart';
import 'attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(
    api: ref.watch(apiClientProvider),
    personRepository: ref.watch(personRepositoryProvider),
  );
});

class AttendanceListController
    extends AutoDisposeAsyncNotifier<AsyncValue<AttendancePage>> {
  String? _cursor;
  String? _classGroup;
  String? _date;
  static const int _pageSize = 50;

  @override
  Future<AsyncValue<AttendancePage>> build() async {
    _cursor = null;
    return _fetchPage(reset: true);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    final next = await _fetchPage(reset: false);
    state = next.whenData(
      (page) => AttendancePage(
        records: [...current.records, ...page.records],
        nextCursor: page.nextCursor,
      ),
    );
  }

  Future<void> setClassGroup(String? value) async {
    _classGroup = value;
    await refresh();
  }

  Future<void> setDate(String? value) async {
    _date = value;
    await refresh();
  }

  Future<void> refresh() async {
    _cursor = null;
    state = const AsyncLoading();
    state = await _fetchPage(reset: true);
  }

  Future<AsyncValue<AttendancePage>> _fetchPage({required bool reset}) async {
    final repo = ref.read(attendanceRepositoryProvider);
    final result = await repo.listRecords(
      cursor: reset ? null : _cursor,
      limit: _pageSize,
      classGroup: _classGroup,
      date: _date,
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

final attendanceListProvider = AsyncNotifierProvider.autoDispose<
    AttendanceListController, AsyncValue<AttendancePage>>(
  AttendanceListController.new,
);

final attendanceRosterProvider = FutureProvider.autoDispose
    .family<Result<List<AttendanceMark>, PersonFailure>, AttendanceRosterArgs>(
        (ref, args) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.loadRoster(
    gradeId: args.gradeId,
    classGroupId: args.classGroupId,
  );
});

@immutable
class AttendanceRosterArgs {
  const AttendanceRosterArgs({this.gradeId, this.classGroupId});
  final String? gradeId;
  final String? classGroupId;

  @override
  bool operator ==(Object other) =>
      other is AttendanceRosterArgs &&
      other.gradeId == gradeId &&
      other.classGroupId == classGroupId;

  @override
  int get hashCode => Object.hash(gradeId, classGroupId);
}
