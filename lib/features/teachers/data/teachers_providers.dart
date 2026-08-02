// SPDX-License-Identifier: Proprietary
// Riverpod wiring for the Teachers feature.
//
// The teacher surface is read-only in this slice:
//   * `teachersRepositoryProvider` — single instance per app
//     session.
//   * `myClassesController` — async controller for the
//     "My classes" list. Re-fetches on refresh; no pagination
//     today (the v1 SDK doesn't expose a cursor on
//     `get_school_teaching_assignments`).
//   * `classRosterController` — per-class student roster
//     filtered by `classGroupId`. Family-scoped so the class
//     detail screen reads it by class id.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../people/data/person.dart';
import '../../people/data/person_failure.dart';
import '../../people/data/person_providers.dart';
import '../../people/data/person_repository.dart';
import 'teachers_failure.dart';
import 'teachers_repository.dart';
import 'teaching_assignment.dart';

/// Single teachers repository per app session. All Teachers
/// feature code reads it from this provider.
final teachersRepositoryProvider = Provider<TeachersRepository>((ref) {
  return TeachersRepository(api: ref.watch(apiClientProvider));
});

/// "My classes" list. Async notifier so the screen can `ref.watch`
/// and receive loading / data / error transitions from a single
/// source of truth. Manual [refresh] for pull-to-refresh.
class MyClassesController
    extends AutoDisposeAsyncNotifier<TeachingAssignmentPage> {
  @override
  Future<TeachingAssignmentPage> build() async {
    final repo = ref.read(teachersRepositoryProvider);
    final result = await repo.listMyClasses();
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<TeachingAssignmentPage>(() async {
      final repo = ref.read(teachersRepositoryProvider);
      final result = await repo.listMyClasses();
      return switch (result) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
    });
  }
}

final myClassesProvider = AsyncNotifierProvider.autoDispose<MyClassesController,
    TeachingAssignmentPage>(
  MyClassesController.new,
);

/// Per-class student roster. The mobile filters the global
/// `listStudents` API by `classGroupId` (the v1 SDK accepts
/// `classGroupId` on the wire) so the class detail screen can
/// show "the 28 students in Grade 3-A" without a dedicated
/// "list students by class" endpoint.
///
/// Family-scoped on the class group id; autoDispose so navigating
/// away releases the fetch.
final classRosterProvider = FutureProvider.autoDispose
    .family<Result<PersonPage, PersonFailure>, String>(
        (ref, classGroupId) async {
  final repo = ref.watch(personRepositoryProvider);
  return repo.listStudents(classGroupId: classGroupId, limit: 200);
});
