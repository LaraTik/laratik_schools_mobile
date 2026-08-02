// SPDX-License-Identifier: Proprietary
// "Switch student" picker — the registrar / teacher / parent-operator
// who is reviewing a specific student's record needs a real way to
// change which student the mobile session is "acting as".
//
// The screen is a focused, full-screen picker: search by name or
// student number, list the matches, tap one to set the choice. The
// picker's choice persists via [SessionStore.setCurrentStudent] and
// invalidates [currentStudentProvider] so every "Acting as: …"
// surface re-renders the new name on next frame.
//
// Surface design notes (per the Laratik UI rules):
//   * Search bar at the top, sticky on scroll, debounced 250ms.
//   * Each row is a 48dp+ tap target with a 44dp avatar, name,
//     student number, and current grade + status.
//   * Empty / loading / error / retry paths reuse [LsStateView] so
//     the operator gets the same shape as every other list.
//   * The currently-acting student is rendered with a "Current"
//     chip so the user can see what they're switching away from.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/login_screen.dart' show sessionProvider;
import '../../../auth/session.dart';
import '../../../core/result.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_search_bar.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../../assessment/data/current_student_provider.dart';
import '../../people/data/person.dart';
import '../../people/data/person_providers.dart';
import '../../people/data/person_repository.dart';

/// Full-screen "Switch student" picker. Reached via
/// `/shell/me/switch-student` from the dashboard's "Acting as" card
/// or the student home's "Acting as" card. Pops back to the caller
/// on selection; the caller reads the new [currentStudentProvider]
/// state on next frame.
class ActingAsPickerScreen extends ConsumerStatefulWidget {
  const ActingAsPickerScreen({super.key});

  @override
  ConsumerState<ActingAsPickerScreen> createState() =>
      _ActingAsPickerScreenState();
}

class _ActingAsPickerScreenState extends ConsumerState<ActingAsPickerScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  String _query = '';
  // We do a manual page cursor (the v1 SDK does accept a cursor
  // string but most pickers only need the first page; the user can
  // narrow via search to find a specific student).
  static const int _pageSize = 50;
  // The currently-acting student id; rendered with a "Current" chip
  // so the user can see what they're switching away from.
  String? _activeStudentId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _activeStudentId = ref.read(sessionProvider).currentStudentId;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      // No loadMore on the picker today — the v1 SDK has a cursor,
      // but a focused picker with search doesn't need infinite
      // scroll. If a future turn wants it, wire
      // `personRepositoryProvider.listStudents` here.
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _query = value.trim());
    });
  }

  Future<void> _selectStudent(Person person) async {
    final session = ref.read(sessionProvider);
    // Persist the choice. We deliberately do NOT pass an
    // `enrollmentId` here — the next read of
    // [currentStudentProvider] will re-derive it from
    // `get_school_enrollments` (see the bug-log 2026-07-31 entry on
    // the audience-scan fallback being broken on the v1 wire).
    await session.setCurrentStudent(studentId: person.id);
    // Invalidate so the dashboard + student home re-fetch the new
    // current student and the "Acting as" card updates immediately.
    // `sessionProvider` is a plain `Provider<SessionStore>`, so the
    // session-store's `notifyListeners()` does not re-trigger
    // Riverpod watchers on its own.
    ref.invalidate(currentStudentProvider);
    if (!mounted) return;
    // Brief snackbar confirmation; the popping surface already
    // re-renders the new "Acting as: …" on next frame.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Now acting as ${person.fullName.isEmpty ? person.id : person.fullName}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Switch student',
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space.md,
              tokens.space.md,
              tokens.space.md,
              tokens.space.sm,
            ),
            child: LsSearchBar(
              placeholder: 'Search by name or student number',
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _buildResults(tokens),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(DesignTokens tokens) {
    // We don't use a Riverpod provider here on purpose — the picker
    // is a focused single-screen surface and a FutureBuilder keeps
    // the wiring local. The fetch goes through the
    // `personRepositoryProvider` (overridable in tests) and the
    // search query lives in widget state.
    return FutureBuilder<Result<PersonPage, dynamic>>(
      // Key the future on the query so the FutureBuilder re-fires
      // when the search text changes.
      key: ValueKey(_query),
      future: _fetchPage(_query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LsStateView.loading(
            title: 'Searching students',
            message: 'Looking up the roster.',
          );
        }
        if (snapshot.hasError) {
          return LsStateView.error(
            icon: Icons.error_outline,
            title: 'Could not load students',
            message: snapshot.error.toString(),
            action: LsButton.primary(
              label: 'Try again',
              expand: false,
              onPressed: () => setState(() {}),
            ),
          );
        }
        final result = snapshot.data;
        if (result == null) {
          return const SizedBox.shrink();
        }
        return switch (result) {
          Ok(:final value) => _buildList(value, tokens),
          Err(:final error) => LsStateView.error(
              icon: Icons.error_outline,
              title: 'Could not load students',
              message: error.toString(),
              action: LsButton.primary(
                label: 'Try again',
                expand: false,
                onPressed: () => setState(() {}),
              ),
            ),
        };
      },
    );
  }

  Future<Result<PersonPage, dynamic>> _fetchPage(String query) async {
    final repo = ref.read(personRepositoryProvider);
    return repo.listStudents(
      limit: _pageSize,
      search: query.isEmpty ? null : query,
    );
  }

  Widget _buildList(PersonPage page, DesignTokens tokens) {
    final people = page.people;
    if (people.isEmpty) {
      return LsStateView.empty(
        icon: Icons.school_outlined,
        title:
            _query.isEmpty ? 'No students yet' : 'No students match "$_query"',
        message: _query.isEmpty
            ? 'Add a student to the roster, then come back here to '
                'pick one.'
            : 'Try a shorter search, or clear the search to see the '
                'full roster.',
        action: _query.isEmpty
            ? null
            : LsButton.secondary(
                label: 'Clear search',
                expand: false,
                icon: Icons.close,
                onPressed: () => setState(() => _query = ''),
              ),
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        tokens.space.md,
        tokens.space.xs,
        tokens.space.md,
        tokens.space.xl,
      ),
      itemCount: people.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: tokens.surface.outlineVariant,
      ),
      itemBuilder: (context, index) {
        final person = people[index];
        return _StudentRow(
          tokens: tokens,
          person: person,
          isActive: person.id == _activeStudentId,
          onTap: () => _selectStudent(person),
        );
      },
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.tokens,
    required this.person,
    required this.isActive,
    required this.onTap,
  });
  final DesignTokens tokens;
  final Person person;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = _subtitle();
    return Material(
      color: tokens.surface.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space.xs,
            vertical: tokens.space.sm,
          ),
          child: Row(
            children: [
              _Avatar(tokens: tokens, name: person.fullName),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      person.fullName.isEmpty ? person.id : person.fullName,
                      style: tokens.typography.titleSmall.copyWith(
                        color: tokens.text.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      SizedBox(height: tokens.space.xxs),
                      Text(
                        subtitle,
                        style: tokens.typography.bodySmall.copyWith(
                          color: tokens.text.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: tokens.space.sm),
              if (isActive)
                LsStatusChip(
                  label: 'Current',
                  tone: LsChipTone.brand,
                  icon: Icons.check_circle_outline,
                )
              else
                Icon(Icons.chevron_right, color: tokens.text.tertiary),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[];
    final number = person.schoolStudentNumber;
    if (number != null && number.isNotEmpty) parts.add('ID $number');
    if (person.grade != null && person.grade!.isNotEmpty) {
      parts.add(person.grade!);
    }
    if (person.status.isNotEmpty) parts.add(person.status);
    return parts.join(' · ');
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.tokens, required this.name});
  final DesignTokens tokens;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFrom(name);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: tokens.brand.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: tokens.typography.titleSmall.copyWith(
          color: tokens.brand.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _initialsFrom(String value) {
    final parts =
        value.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
