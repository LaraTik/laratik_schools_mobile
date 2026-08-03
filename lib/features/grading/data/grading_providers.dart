// SPDX-License-Identifier: Proprietary
// Riverpod wiring for the Grading feature.
//
// Today (read-only overview + policies + setup context +
// admin write flows):
//   * `gradingRepositoryProvider` — single instance per app
//     session.
//   * `gradingOverviewProvider` — FutureProvider.autoDispose
//     for the top-level overview snapshot.
//   * `gradingPoliciesController` — async notifier for the
//     policies list. Manual [refresh] for pull-to-refresh.
//   * `gradingPolicySetupContextProvider` —
//     FutureProvider.autoDispose for the role / permissions
//     context.
//   * `gradingPolicySetupContextController` — async notifier
//     for the policies list including the setup context
//     (used by the policies tab so a single ref.watch
//     fetches both).
//   * `correctGradeRecordController` — async notifier for
//     the `correct_school_grade_record` write flow. Mints a
//     fresh UUID for the `Idempotency-Key` header; the
//     overview provider is invalidated on success so the
//     next ref.watch re-fetches the new summary.
//   * `approveSubjectGradePolicy(ref, ...)` — top-level
//     widget helper for the
//     `approve_school_subject_grade_policy` write flow.
//     Invalidates the policies provider on success so the
//     next ref.watch re-fetches the new approval state.
//   * `promoteAssessmentResult(ref, ...)` — top-level widget
//     helper for the `promote_school_assessment_result`
//     write flow. Invalidates the overview + policies
//     providers on success so the next ref.watch re-fetches
//     the new summary.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../people/data/person_providers.dart';
import 'approved_policy.dart';
import 'grade_record_correction.dart';
import 'grading_failure.dart';
import 'grading_overview.dart';
import 'grading_repository.dart';
import 'promoted_result.dart';

/// Single grading repository per app session. All Grading
/// feature code reads it from this provider.
final gradingRepositoryProvider = Provider<GradingRepository>((ref) {
  return GradingRepository(api: ref.watch(apiClientProvider));
});

/// Top-level grading overview snapshot. AutoDispose so
/// navigating away releases the fetch.
final gradingOverviewProvider =
    FutureProvider.autoDispose<Result<GradingOverview, GradingFailure>>(
        (ref) async {
  final repo = ref.watch(gradingRepositoryProvider);
  return repo.fetchOverview();
});

/// Grading policy setup context. AutoDispose so navigating
/// away releases the fetch.
final gradingPolicySetupContextProvider = FutureProvider.autoDispose<
    Result<GradingPolicySetupContext, GradingFailure>>((ref) async {
  final repo = ref.watch(gradingRepositoryProvider);
  return repo.fetchPolicySetupContext();
});

/// Combined "policies + setup" view used by the policies
/// tab. The screen watches this single provider; the
/// controller internally fires the two fetches in parallel
/// so a single ref.watch returns both. Manual [refresh] for
/// pull-to-refresh.
class GradingPoliciesController
    extends AutoDisposeAsyncNotifier<GradingPoliciesView> {
  @override
  Future<GradingPoliciesView> build() async {
    final repo = ref.read(gradingRepositoryProvider);
    final results = await Future.wait<dynamic>([
      repo.listPolicies(),
      repo.fetchPolicySetupContext(),
    ]);
    final policiesResult =
        results[0] as Result<SubjectGradePolicyPage, GradingFailure>;
    final setupResult =
        results[1] as Result<GradingPolicySetupContext, GradingFailure>;
    // Fail fast on either error; the surface shows a single
    // error state.
    final firstError = [policiesResult, setupResult]
        .firstWhere((r) => r is Err, orElse: () => policiesResult);
    if (firstError is Err) {
      throw (firstError as Err).error as GradingFailure;
    }
    return GradingPoliciesView(
      page: (policiesResult as Ok).value as SubjectGradePolicyPage,
      setup: (setupResult as Ok).value as GradingPolicySetupContext,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<GradingPoliciesView>(() async {
      final repo = ref.read(gradingRepositoryProvider);
      final results = await Future.wait<dynamic>([
        repo.listPolicies(),
        repo.fetchPolicySetupContext(),
      ]);
      final policiesResult =
          results[0] as Result<SubjectGradePolicyPage, GradingFailure>;
      final setupResult =
          results[1] as Result<GradingPolicySetupContext, GradingFailure>;
      final firstError = [policiesResult, setupResult]
          .firstWhere((r) => r is Err, orElse: () => policiesResult);
      if (firstError is Err) {
        throw (firstError as Err).error as GradingFailure;
      }
      return GradingPoliciesView(
        page: (policiesResult as Ok).value as SubjectGradePolicyPage,
        setup: (setupResult as Ok).value as GradingPolicySetupContext,
      );
    });
  }
}

/// View-model that holds both the policy list and the setup
/// context. The screen reads this from
/// `gradingPoliciesProvider` so a single `ref.watch` fetches
/// both.
class GradingPoliciesView {
  const GradingPoliciesView({required this.page, required this.setup});
  final SubjectGradePolicyPage page;
  final GradingPolicySetupContext setup;
}

final gradingPoliciesProvider = AsyncNotifierProvider.autoDispose<
    GradingPoliciesController, GradingPoliciesView>(
  GradingPoliciesController.new,
);

/// Controller for the `correct_school_grade_record` write
/// flow. Mints a fresh UUID for the `Idempotency-Key`
/// header inside the repository (not the controller) so a
/// retry of the same correction is safe to send again.
/// On success the overview + policies providers are
/// invalidated so the next ref.watch re-fetches the new
/// summary.
class CorrectGradeRecordController
    extends AutoDisposeAsyncNotifier<CorrectedGradeRecord?> {
  @override
  Future<CorrectedGradeRecord?> build() async => null;

  Future<Result<CorrectedGradeRecord, GradingFailure>> submit(
    GradeRecordCorrectionPayload payload,
  ) async {
    if (!payload.isValid) {
      return const Err(
        error: GradingFailure(
          code: 'INVALID_CORRECTION_PAYLOAD',
          message: 'Score must be a non-negative number, max must be > 0, '
              'and score must not exceed max.',
        ),
      );
    }
    state = const AsyncValue.loading();
    final repo = ref.read(gradingRepositoryProvider);
    final result = await repo.correctGradeRecord(
      gradeName: payload.gradeName,
      score: double.parse(payload.score!),
      maxScore: double.parse(payload.maxScore!),
      reason: payload.reason,
    );
    switch (result) {
      case Ok(:final value):
        // Invalidate the overview + policies so the next
        // ref.watch re-fetches the new summary.
        ref.invalidate(gradingOverviewProvider);
        ref.invalidate(gradingPoliciesProvider);
        state = AsyncValue.data(value);
      case Err():
        state = const AsyncValue.data(null);
    }
    return result;
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final correctGradeRecordProvider = AsyncNotifierProvider.autoDispose<
    CorrectGradeRecordController, CorrectedGradeRecord?>(
  CorrectGradeRecordController.new,
);

/// Top-level widget helper for the
/// `approve_school_subject_grade_policy` write flow. The
/// repository mints a fresh UUID for the `Idempotency-Key`
/// header so a retry of the same approve is safe to send
/// again. Takes a [WidgetRef] (not a [Ref]) because the
/// only callers are widget-side helpers — the Riverpod
/// `Ref` type lives inside a provider closure, not in a
/// widget's build method.
///
/// On success the policies provider is invalidated so the
/// next ref.watch re-fetches the new approval state.
Future<Result<ApprovedPolicy, GradingFailure>> approveSubjectGradePolicy(
  WidgetRef ref, {
  required String policyName,
}) async {
  final repo = ref.read(gradingRepositoryProvider);
  final result = await repo.approveSubjectGradePolicy(
    policyName: policyName,
  );
  if (result is Ok) {
    ref.invalidate(gradingPoliciesProvider);
  }
  return result;
}

/// Top-level widget helper for the
/// `promote_school_assessment_result` write flow. The
/// repository mints a fresh UUID for the `Idempotency-Key`
/// header. Takes a [WidgetRef] (not a [Ref]).
///
/// On success the overview + policies providers are
/// invalidated so the next ref.watch re-fetches the new
/// summary.
Future<Result<PromotedAssessmentResult, GradingFailure>> promoteAssessmentResult(
  WidgetRef ref, {
  required String assessmentResultName,
  required String policyName,
}) async {
  final repo = ref.read(gradingRepositoryProvider);
  final result = await repo.promoteAssessmentResult(
    assessmentResultName: assessmentResultName,
    policyName: policyName,
  );
  if (result is Ok) {
    ref.invalidate(gradingOverviewProvider);
    ref.invalidate(gradingPoliciesProvider);
  }
  return result;
}
