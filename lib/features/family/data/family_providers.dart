// SPDX-License-Identifier: Proprietary
// Riverpod wiring for the Family feature.
//
// The family surface is read-only on the v1 SDK: parent "my
// children" resolves to the union of `School Guardian.linked_students`
// rows the server returns for the current user, and the per-child
// detail pulls grade / attendance / report-card records and filters
// them client-side by student id (the v1 SDK doesn't accept a
// `school_student` filter on those endpoints).
//
// The provider tree:
//   * `familyRepositoryProvider` — single instance per app session.
//   * `familyListController`    — async controller for the "my
//                                  children" list. Re-fetches on
//                                  refresh; no pagination today
//                                  (the SDK doesn't expose a cursor
//                                  on `get_school_guardians`).
//   * `childRecordsController`  — per-student records page (grades
//                                  + attendance + report cards in
//                                  one shot). AutoDispose so
//                                  navigating away releases the
//                                  fetch. Family-scoped so the
//                                  child-detail screen reads it
//                                  by student id.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../people/data/person_providers.dart';
import 'family_failure.dart';
import 'family_repository.dart';

/// Single family repository per app session. All Family feature code
/// reads it from this provider.
final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepository(api: ref.watch(apiClientProvider));
});

/// "My children" list. Async notifier so the screen can `ref.watch`
/// and receive loading / data / error transitions from a single
/// source of truth. Manual [refresh] for pull-to-refresh.
class FamilyListController extends AutoDisposeAsyncNotifier<FamilyPage> {
  @override
  Future<FamilyPage> build() async {
    final repo = ref.read(familyRepositoryProvider);
    final result = await repo.listFamily();
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<FamilyPage>(() async {
      final repo = ref.read(familyRepositoryProvider);
      final result = await repo.listFamily();
      return switch (result) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
    });
  }
}

final familyListProvider =
    AsyncNotifierProvider.autoDispose<FamilyListController, FamilyPage>(
  FamilyListController.new,
);

/// Per-child records page (grades + attendance + report cards).
/// Family-scoped so the child detail screen reads it by
/// `ref.watch(childRecordsProvider(studentId))`. AutoDispose so
/// navigating away releases the fetch.
///
/// Returns the full [StudentRecordsPage] in one shot — the v1 SDK
/// exposes each endpoint independently and the latency is small
/// enough that a single Future provider is friendlier to the UI
/// than a separate refresh button per tab.
final childRecordsProvider = FutureProvider.autoDispose
    .family<Result<StudentRecordsPage, FamilyFailure>, String>(
        (ref, studentId) async {
  final repo = ref.watch(familyRepositoryProvider);
  return repo.listAllRecordsForStudent(studentId);
});
