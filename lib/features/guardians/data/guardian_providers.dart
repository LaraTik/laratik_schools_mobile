import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import '../../people/data/person_providers.dart';
import 'guardian.dart';
import 'guardian_form_payload.dart';
import 'guardian_repository.dart';

final guardianRepositoryProvider = Provider<GuardianRepository>((ref) {
  return GuardianRepository(api: ref.watch(apiClientProvider));
});

class GuardianFilter {
  const GuardianFilter({
    this.search = '',
    this.relation,
  });

  final String search;
  final String? relation;

  GuardianFilter copyWith({
    String? search,
    Object? relation = _noChange,
  }) {
    return GuardianFilter(
      search: search ?? this.search,
      relation: identical(relation, _noChange) ? this.relation : relation as String?,
    );
  }

  bool get isEmpty => search.isEmpty && relation == null;

  static const Object _noChange = Object();

  @override
  bool operator ==(Object other) =>
      other is GuardianFilter &&
      other.search == search &&
      other.relation == relation;

  @override
  int get hashCode => Object.hash(search, relation);
}

final guardianFilterProvider =
    StateProvider<GuardianFilter>((ref) => const GuardianFilter());

class GuardianListController
    extends AutoDisposeAsyncNotifier<AsyncValue<GuardianPage>> {
  String? _cursor;
  static const int _pageSize = 50;

  @override
  Future<AsyncValue<GuardianPage>> build() async {
    final filter = ref.watch(guardianFilterProvider);
    _cursor = null;
    return _fetchPage(filter: filter, reset: true);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    final filter = ref.read(guardianFilterProvider);
    final next = await _fetchPage(filter: filter, reset: false);
    state = next.whenData(
      (page) => GuardianPage(
        guardians: [...current.guardians, ...page.guardians],
        nextCursor: page.nextCursor,
      ),
    );
  }

  Future<void> refresh() async {
    final filter = ref.read(guardianFilterProvider);
    _cursor = null;
    state = const AsyncLoading();
    state = await _fetchPage(filter: filter, reset: true);
  }

  Future<AsyncValue<GuardianPage>> _fetchPage({
    required GuardianFilter filter,
    required bool reset,
  }) async {
    final repo = ref.read(guardianRepositoryProvider);
    final result = await repo.listGuardians(
      cursor: reset ? null : _cursor,
      limit: _pageSize,
      search: filter.search.isEmpty ? null : filter.search,
      relation: filter.relation,
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

final guardianListProvider = AsyncNotifierProvider.autoDispose<
    GuardianListController, AsyncValue<GuardianPage>>(
  GuardianListController.new,
);

final guardianProfileProvider = FutureProvider.autoDispose
    .family<Result<GuardianProfile, PersonFailure>, String>((ref, id) async {
  final repo = ref.watch(guardianRepositoryProvider);
  return repo.fetchProfile(id);
});

final guardianSetupContextProvider = FutureProvider.autoDispose
    .family<Result<JsonMap, PersonFailure>, void>((ref, _) async {
  final repo = ref.watch(guardianRepositoryProvider);
  return repo.fetchSetupContext();
});
