import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../../../app/bootstrap.dart';
import '../../../core/result.dart';
import 'person.dart';
import 'person_failure.dart';
import 'person_repository.dart';

/// Pulls the typed SDK client from the composition root. Tests override
/// this provider with a fake client bound to a stub repository.
final apiClientProvider = Provider<LaratikSchoolsApiClient>((ref) {
  throw StateError(
    'apiClientProvider must be overridden by bootstrap() in the ProviderScope.',
  );
});

/// The People repository. Single instance per app session; all People
/// feature code reads it from this provider.
final personRepositoryProvider = Provider<PersonRepository>((ref) {
  return PersonRepository(api: ref.watch(apiClientProvider));
});

/// Filter shape for the students list. Held in a dedicated provider so
/// changes to one field don't refire the whole list.
class StudentsFilter {
  const StudentsFilter({
    this.search = '',
    this.gradeId,
    this.classGroupId,
  });

  final String search;
  final String? gradeId;
  final String? classGroupId;

  StudentsFilter copyWith({
    String? search,
    Object? gradeId = _noChange,
    Object? classGroupId = _noChange,
  }) {
    return StudentsFilter(
      search: search ?? this.search,
      gradeId: identical(gradeId, _noChange) ? this.gradeId : gradeId as String?,
      classGroupId: identical(classGroupId, _noChange)
          ? this.classGroupId
          : classGroupId as String?,
    );
  }

  bool get isEmpty => search.isEmpty && gradeId == null && classGroupId == null;

  static const Object _noChange = Object();

  @override
  bool operator ==(Object other) =>
      other is StudentsFilter &&
      other.search == search &&
      other.gradeId == gradeId &&
      other.classGroupId == classGroupId;

  @override
  int get hashCode => Object.hash(search, gradeId, classGroupId);
}

final studentsFilterProvider =
    StateProvider<StudentsFilter>((ref) => const StudentsFilter());

/// The student list. Async notifier so the screen can `ref.watch` and
/// receive loading / data / error transitions in a single source of truth.
class StudentsListController extends AutoDisposeAsyncNotifier<PersonPage> {
  String? _cursor;
  static const int _pageSize = 50;

  @override
  Future<PersonPage> build() async {
    // Re-fetch whenever the filter changes.
    final filter = ref.watch(studentsFilterProvider);
    _cursor = null;
    return _fetchPage(filter: filter, reset: true);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    final filter = ref.read(studentsFilterProvider);
    final next = await _fetchPage(filter: filter, reset: false);
    state = AsyncValue.data(
      PersonPage(
        people: [...current.people, ...next.people],
        nextCursor: next.nextCursor,
      ),
    );
  }

  Future<void> refresh() async {
    final filter = ref.read(studentsFilterProvider);
    _cursor = null;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(filter: filter, reset: true));
  }

  Future<PersonPage> _fetchPage({
    required StudentsFilter filter,
    required bool reset,
  }) async {
    final repo = ref.read(personRepositoryProvider);
    final result = await repo.listStudents(
      cursor: reset ? null : _cursor,
      limit: _pageSize,
      search: filter.search.isEmpty ? null : filter.search,
      gradeId: filter.gradeId,
      classGroupId: filter.classGroupId,
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

final studentsListProvider = AsyncNotifierProvider.autoDispose<
    StudentsListController, PersonPage>(
  StudentsListController.new,
);

/// Student detail. Re-fetches when the [id] argument changes; the screen
/// re-reads the provider with `ref.watch(studentProfileProvider(id))`.
final studentProfileProvider = FutureProvider.autoDispose
    .family<Result<PersonProfile, PersonFailure>, String>((ref, id) async {
  final repo = ref.watch(personRepositoryProvider);
  return repo.fetchStudentProfile(id);
});

/// Student setup context. The form reads the schema + defaults from here
/// at first build. Cached for the session because the response is small
/// and only changes on release.
final studentSetupContextProvider = FutureProvider.autoDispose
    .family<Result<JsonMap, PersonFailure>, void>((ref, _) async {
  final repo = ref.watch(personRepositoryProvider);
  return repo.fetchStudentSetupContext();
});

/// Riverpod glue so the bootstrap graph can hand the API client to the
/// People providers without a circular import on bootstrap.dart.
extension AppDependenciesRiverpod on AppDependencies {
  /// Override the [apiClientProvider] in a `ProviderScope.overrides`
  /// so the People feature (and any other feature) can pull the typed
  /// client from a single source of truth.
  List<Override> get riverpodPeopleOverrides => [
        apiClientProvider.overrideWithValue(api),
      ];
}
