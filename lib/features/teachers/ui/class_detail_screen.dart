// SPDX-License-Identifier: Proprietary
// Per-class detail screen — the teacher taps a row in
// "My classes" and lands here.
//
// Surface contents:
//   * Identity card: class name, subject, academic year, "Homeroom"
//     chip when the assignment is primary.
//   * Student roster: the school's students filtered by
//     `classGroupId` (the v1 SDK accepts a classGroupId filter on
//     `get_school_students`). Each row is a tappable PersonCard.
//   * Empty / loading / error / retry paths reuse [LsStateView] for
//     consistency with the other lists.
//
// Future (deferred to docs/PROD_READINESS_AUDIT.md #6 follow-up):
//   * "Take attendance for this class" tile (deep link to the
//     attendance capture screen).
//   * "Author exam for this subject" tile (deep link to the
//     exam authoring surface).
//   * "Grade exam attempts" tile (deep link to the manual
//     grading surface).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../../people/data/person.dart';
import '../../people/data/person_failure.dart';
import '../../people/data/person_providers.dart';
import '../../people/ui/widgets/person_card.dart';
import '../data/teachers_providers.dart';

/// Per-class detail. Reached from "My classes" via
/// `/shell/teachers/classes/:classGroupId`. The class group id is
/// URL-encoded so it survives route parsing.
class ClassDetailScreen extends ConsumerWidget {
  const ClassDetailScreen({required this.classGroupId, super.key});
  final String classGroupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    // Roster is keyed by class group id. The detail doesn't need
    // the teaching assignment row itself — the class group id is
    // enough to identify the surface.
    final rosterAsync = ref.watch(classRosterProvider(classGroupId));
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/shell/teachers/classes'),
        ),
        title: Text(
          'Class',
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
      ),
      body: rosterAsync.when(
        data: (result) => switch (result) {
          Ok(:final value) => _buildBody(context, tokens, value.people),
          Err(:final error) => _buildError(
              tokens,
              ref,
              error,
              'Could not load roster',
            ),
        },
        loading: () => const LsStateView.loading(
          title: 'Loading roster',
          message: 'Looking up the students assigned to this class group.',
        ),
        error: (err, _) => _buildError(
          tokens,
          ref,
          err is PersonFailure
              ? err
              : PersonFailure(
                  code: 'EXCEPTION',
                  message: err.toString(),
                ),
          'Could not load roster',
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, DesignTokens tokens, List<Person> people) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space.md,
              tokens.space.md,
              tokens.space.md,
              tokens.space.sm,
            ),
            child: _IdentityCard(
                tokens: tokens,
                classGroupId: classGroupId,
                count: people.length),
          ),
        ),
        if (people.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: LsStateView.empty(
              icon: Icons.group_off_outlined,
              title: 'No students in this class yet',
              message: "No students are assigned to this class group yet. "
                  "When the registrar enrols students, they will "
                  "appear here automatically.",
            ),
          )
        else
          SliverList.separated(
            itemCount: people.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: tokens.surface.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final person = people[index];
              return PersonCard(
                person: person,
                onTap: () => context.go('/shell/students/${person.id}'),
              );
            },
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildError(
    DesignTokens tokens,
    WidgetRef ref,
    PersonFailure error,
    String title,
  ) {
    return LsStateView.error(
      icon: Icons.error_outline,
      title: title,
      message: error.message,
      action: LsButton.primary(
        label: 'Try again',
        expand: false,
        onPressed: () => ref.invalidate(classRosterProvider(classGroupId)),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.tokens,
    required this.classGroupId,
    required this.count,
  });
  final DesignTokens tokens;
  final String classGroupId;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: tokens.brand.primaryContainer,
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
            child: Icon(
              Icons.class_outlined,
              color: tokens.brand.onPrimaryContainer,
              size: 28,
            ),
          ),
          SizedBox(width: tokens.space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class group',
                  style: tokens.typography.labelMedium.copyWith(
                    color: tokens.text.secondary,
                  ),
                ),
                SizedBox(height: tokens.space.xxs),
                Text(
                  classGroupId,
                  style: tokens.typography.titleMedium.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
                SizedBox(height: tokens.space.xs),
                Wrap(
                  spacing: tokens.space.xs,
                  runSpacing: tokens.space.xxs,
                  children: [
                    LsStatusChip(
                      label: count == 1 ? '1 student' : '$count students',
                      tone: count == 0 ? LsChipTone.neutral : LsChipTone.brand,
                      icon: Icons.group_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
