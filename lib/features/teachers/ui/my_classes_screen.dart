// SPDX-License-Identifier: Proprietary
// "My classes" — the teacher role's primary home tab.
//
// Lists the teaching assignments owned by the current staff
// member (the v1 server is expected to filter to the current
// user when the session is a teacher role). Each row tappable
// into the per-class detail (student roster + class info).
//
// The screen reuses the [TeachingAssignment] rows resolved by
// [TeachersRepository]. The list is read-only — manual grading
// and assignment authoring land in a follow-up turn per
// docs/PROD_READINESS_AUDIT.md #6.
//
// UX:
//   * Each assignment row shows class name, subject, academic
//     year, and a "Homeroom" chip on primary assignments.
//   * Active assignments first; inactive ones still rendered but
//     faded so the teacher sees the history.
//   * Empty / loading / error / retry paths use [LsStateView] for
//     consistency with every other list in the app.
//   * Every user-facing string is locale-aware via
//     [AppLocalizations.of(context)]; the chevron mirrors itself
//     under RTL so the visual flow stays consistent with the text
//     direction.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../data/teachers_providers.dart';
import '../data/teaching_assignment.dart';

class MyClassesScreen extends ConsumerWidget {
  const MyClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(myClassesProvider);
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.navMyClasses,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(myClassesProvider.notifier).refresh(),
          ),
        ],
      ),
      body: async.when(
        data: (page) => _buildBody(context, ref, tokens, page),
        loading: () => LsStateView.loading(
          title: l.myClassesLoadingTitle,
          message: l.myClassesLoadingMessage,
        ),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: l.myClassesErrorTitle,
          message: err.toString(),
          action: LsButton.primary(
            label: l.commonTryAgain,
            expand: false,
            onPressed: () => ref.read(myClassesProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DesignTokens tokens,
    TeachingAssignmentPage page,
  ) {
    if (page.assignments.isEmpty) {
      return LsStateView.empty(
        icon: Icons.class_outlined,
        title: l_empty(context),
        message: l_empty_msg(context),
      );
    }
    // Active assignments first; the inactive tail is still
    // rendered but faded. Stable order inside each group by class
    // label, then subject.
    final sorted = [...page.assignments]..sort((a, b) {
        if (a.isActive != b.isActive) {
          return a.isActive ? -1 : 1;
        }
        final classCmp =
            a.classLabel.toLowerCase().compareTo(b.classLabel.toLowerCase());
        if (classCmp != 0) return classCmp;
        return a.subjectLabel
            .toLowerCase()
            .compareTo(b.subjectLabel.toLowerCase());
      });
    return RefreshIndicator(
      color: tokens.brand.primary,
      onRefresh: () => ref.read(myClassesProvider.notifier).refresh(),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          tokens.space.md,
          tokens.space.md,
          tokens.space.md,
          tokens.space.xl,
        ),
        itemCount: sorted.length + 1,
        separatorBuilder: (_, __) => SizedBox(height: tokens.space.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Header(
              tokens: tokens,
              total: page.assignments.length,
              active: page.assignments.where((a) => a.isActive).length,
            );
          }
          return _AssignmentCard(tokens: tokens, assignment: sorted[index - 1]);
        },
      ),
    );
  }
}

// Forwarders so the empty-state LsStateView can stay inline without
// a long conditional in the call site. They pull the latest
// AppLocalizations off the BuildContext; cheap because the picker
// rebuild is rare and the localisation class is cached.
String l_empty(BuildContext context) =>
    AppLocalizations.of(context).myClassesEmptyTitle;
String l_empty_msg(BuildContext context) =>
    AppLocalizations.of(context).myClassesEmptyMessage;

class _Header extends StatelessWidget {
  const _Header(
      {required this.tokens, required this.total, required this.active});
  final DesignTokens tokens;
  final int total;
  final int active;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final inactive = total - active;
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.class_outlined, color: tokens.brand.primary),
          SizedBox(width: tokens.space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.myClassesHeaderTotal(total),
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
                SizedBox(height: tokens.space.xxs),
                Text(
                  inactive == 0
                      ? l.myClassesHeaderAllActive
                      : l.myClassesHeaderActive(active, inactive),
                  style: tokens.typography.bodySmall.copyWith(
                    color: tokens.text.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.tokens, required this.assignment});
  final DesignTokens tokens;
  final TeachingAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final active = assignment.isActive;
    return Opacity(
      opacity: active ? 1.0 : 0.62,
      child: Material(
        color: tokens.surface.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.md),
          side: BorderSide(color: tokens.surface.outlineVariant),
        ),
        child: InkWell(
          onTap: assignment.classGroup.isEmpty
              ? null
              : () => context.go(
                    '/shell/teachers/classes/${Uri.encodeComponent(assignment.classGroup)}',
                  ),
          borderRadius: BorderRadius.circular(tokens.radius.md),
          child: Semantics(
            button: true,
            label: assignment.classLabel,
            child: Padding(
              padding: EdgeInsets.all(tokens.space.md),
              child: Row(
                children: [
                  _ClassAvatar(
                    tokens: tokens,
                    label: assignment.classLabel,
                    active: active,
                  ),
                  SizedBox(width: tokens.space.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          assignment.classLabel,
                          style: tokens.typography.titleSmall.copyWith(
                            color: tokens.text.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: tokens.space.xxs),
                        Wrap(
                          spacing: tokens.space.xs,
                          runSpacing: tokens.space.xxs,
                          children: [
                            if (assignment.subjectLabel.isNotEmpty)
                              LsStatusChip(
                                label: assignment.subjectLabel,
                                tone: LsChipTone.brand,
                                icon: Icons.menu_book_outlined,
                              ),
                            if (assignment.isPrimary)
                              LsStatusChip(
                                label: l.myClassesChipHomeroom,
                                tone: LsChipTone.info,
                                icon: Icons.home_outlined,
                              ),
                            if (!active)
                              LsStatusChip(
                                label: assignment.status,
                                tone: LsChipTone.neutral,
                                icon: Icons.archive_outlined,
                              ),
                          ],
                        ),
                        if (assignment.academicYear.isNotEmpty) ...[
                          SizedBox(height: tokens.space.xxs),
                          Text(
                            l.myClassesAcademicYear(assignment.academicYear),
                            style: tokens.typography.bodySmall.copyWith(
                              color: tokens.text.secondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    // Mirror the chevron under RTL so the visual
                    // "next →" stays consistent with the text flow.
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                    color: tokens.text.tertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClassAvatar extends StatelessWidget {
  const _ClassAvatar({
    required this.tokens,
    required this.label,
    required this.active,
  });
  final DesignTokens tokens;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: active
            ? tokens.brand.primaryContainer
            : tokens.surface.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initialsFrom(label),
        style: tokens.typography.titleSmall.copyWith(
          color:
              active ? tokens.brand.onPrimaryContainer : tokens.text.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _initialsFrom(String value) {
    // Best-effort: take the first letter of the first 1-2 words
    // in the class label. "Grade 3-A" → "G3" looks weird; fall
    // through to "GR" for clarity when the label is mostly a
    // grade name.
    final parts =
        value.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final word = parts.first;
      return word.length <= 2
          ? word.toUpperCase()
          : word.characters.first.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
