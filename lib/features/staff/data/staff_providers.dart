import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import '../../people/data/person_providers.dart';
import 'staff_form_payload.dart';
import 'staff_member.dart';
import 'staff_repository.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository(api: ref.watch(apiClientProvider));
});

class StaffFilter {
  const StaffFilter({
    this.search = '',
    this.staffRole,
    this.branchId,
  });

  final String search;
  final String? staffRole;
  final String? branchId;

  StaffFilter copyWith({
    String? search,
    Object? staffRole = _noChange,
    Object? branchId = _noChange,
  }) {
    return StaffFilter(
      search: search ?? this.search,
      staffRole: identical(staffRole, _noChange)
          ? this.staffRole
          : staffRole as String?,
      branchId:
          identical(branchId, _noChange) ? this.branchId : branchId as String?,
    );
  }

  bool get isEmpty => search.isEmpty && staffRole == null && branchId == null;

  static const Object _noChange = Object();

  @override
  bool operator ==(Object other) =>
      other is StaffFilter &&
      other.search == search &&
      other.staffRole == staffRole &&
      other.branchId == branchId;

  @override
  int get hashCode => Object.hash(search, staffRole, branchId);
}

final staffFilterProvider =
    StateProvider<StaffFilter>((ref) => const StaffFilter());

class StaffListController extends AutoDisposeAsyncNotifier<StaffPage> {
  String? _cursor;
  static const int _pageSize = 50;

  @override
  Future<StaffPage> build() async {
    final filter = ref.watch(staffFilterProvider);
    _cursor = null;
    return _fetchPage(filter: filter, reset: true);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    final filter = ref.read(staffFilterProvider);
    final next = await _fetchPage(filter: filter, reset: false);
    state = AsyncValue.data(
      StaffPage(
        staff: [...current.staff, ...next.staff],
        nextCursor: next.nextCursor,
      ),
    );
  }

  Future<void> refresh() async {
    final filter = ref.read(staffFilterProvider);
    _cursor = null;
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard(() => _fetchPage(filter: filter, reset: true));
  }

  Future<StaffPage> _fetchPage({
    required StaffFilter filter,
    required bool reset,
  }) async {
    final repo = ref.read(staffRepositoryProvider);
    final result = await repo.listStaff(
      cursor: reset ? null : _cursor,
      limit: _pageSize,
      search: filter.search.isEmpty ? null : filter.search,
      staffRole: filter.staffRole,
      branchId: filter.branchId,
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

final staffListProvider =
    AsyncNotifierProvider.autoDispose<StaffListController, StaffPage>(
  StaffListController.new,
);

final staffProfileProvider = FutureProvider.autoDispose
    .family<Result<StaffProfile, PersonFailure>, String>((ref, id) async {
  final repo = ref.watch(staffRepositoryProvider);
  return repo.fetchProfile(id);
});

final staffSetupContextProvider = FutureProvider.autoDispose
    .family<Result<JsonMap, PersonFailure>, void>((ref, _) async {
  final repo = ref.watch(staffRepositoryProvider);
  return repo.fetchSetupContext();
});
