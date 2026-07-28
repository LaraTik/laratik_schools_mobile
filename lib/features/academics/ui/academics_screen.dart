import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_search_bar.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../../people/data/person_failure.dart';
import '../data/academics_providers.dart';
import '../data/academics_repository.dart';
import '../data/subject.dart';

/// Academics surface: three tabs (Subjects, Timetable, Branches) sharing
/// one scaffold. Subjects gets the create action; Timetable and Branches
/// are read-only browse in this slice.
class AcademicsScreen extends ConsumerWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: tokens.surface.canvas,
        appBar: AppBar(
          backgroundColor: tokens.surface.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
          title: Text(
            'Academics',
            style: tokens.typography.titleLarge.copyWith(
              color: tokens.text.primary,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: tokens.space.sm),
              child: LsButton.primary(
                label: 'New subject',
                icon: Icons.add,
                expand: false,
                onPressed: () => context.go('/shell/academics/subjects/new'),
              ),
            ),
          ],
          bottom: TabBar(
            labelColor: tokens.brand.primary,
            unselectedLabelColor: tokens.text.secondary,
            indicatorColor: tokens.brand.primary,
            tabs: const [
              Tab(text: 'Subjects'),
              Tab(text: 'Timetable'),
              Tab(text: 'Branches'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SubjectsTab(),
            _TimetableTab(),
            _BranchesTab(),
          ],
        ),
      ),
    );
  }
}

class _SubjectsTab extends ConsumerStatefulWidget {
  const _SubjectsTab();

  @override
  ConsumerState<_SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends ConsumerState<_SubjectsTab> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      ref.read(subjectsListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    final asyncPage = ref.watch(subjectsListProvider);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: LsSearchBar(
            placeholder: 'Search by name, code, or department',
            onChanged: (value) =>
                ref.read(subjectsListProvider.notifier).setSearch(value),
          ),
        ),
        Expanded(
          child: asyncPage.when(
            data: (page) => _buildList(page, tokens),
            loading: () =>
                const LsStateView.loading(title: 'Loading subjects'),
            error: (err, _) => LsStateView.error(
              icon: Icons.error_outline,
              title: 'Could not load subjects',
              message: err.toString(),
              action: LsButton.primary(
                label: 'Try again',
                expand: false,
                onPressed: () =>
                    ref.read(subjectsListProvider.notifier).refresh(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList(SubjectPage page, DesignTokens tokens) {
    final subjects = page.subjects;
    if (subjects.isEmpty) {
      return LsStateView.empty(
        icon: Icons.menu_book_outlined,
        title: 'No subjects yet',
        message: 'Add the first subject to get started.',
        action: LsButton.primary(
          label: 'Add subject',
          icon: Icons.add,
          onPressed: () => context.go('/shell/academics/subjects/new'),
        ),
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: tokens.space.xl),
      itemCount: subjects.length + (page.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: tokens.surface.outlineVariant,
      ),
      itemBuilder: (context, index) {
        if (index >= subjects.length) {
          return Padding(
            padding: EdgeInsets.all(tokens.space.md),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: tokens.brand.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }
        final s = subjects[index];
        return ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: tokens.space.md,
            vertical: tokens.space.xxs,
          ),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: tokens.brand.primaryContainer,
            child: Icon(
              Icons.menu_book_outlined,
              color: tokens.brand.onPrimaryContainer,
              size: 18,
            ),
          ),
          title: Text(
            s.subjectName,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.primary,
            ),
          ),
          subtitle: Text(
            [
              if (s.subjectCode != null && s.subjectCode!.isNotEmpty)
                s.subjectCode!,
              if (s.department != null && s.department!.isNotEmpty)
                s.department!,
            ].join(' · '),
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          trailing: s.isActive
              ? const LsStatusChip(
                  label: 'Active',
                  tone: LsChipTone.success,
                )
              : LsStatusChip(label: s.status, tone: LsChipTone.neutral),
        );
      },
    );
  }
}

class _TimetableTab extends ConsumerStatefulWidget {
  const _TimetableTab();

  @override
  ConsumerState<_TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends ConsumerState<_TimetableTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      ref.read(timetableListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    final asyncPage = ref.watch(timetableListProvider);
    return asyncPage.when(
      data: (page) => _buildGrid(page, tokens),
      loading: () => const LsStateView.loading(title: 'Loading timetable'),
      error: (err, _) => LsStateView.error(
        icon: Icons.error_outline,
        title: 'Could not load timetable',
        message: err.toString(),
      ),
    );
  }

  Widget _buildGrid(TimetablePage page, DesignTokens tokens) {
    final slots = page.slots;
    final byDay = _groupByDay(slots);
    if (slots.isEmpty) {
      return LsStateView.empty(
        icon: Icons.calendar_today_outlined,
        title: 'No timetable slots',
        message: 'The school has not published any timetable slots yet.',
      );
    }
    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.all(tokens.space.md),
      children: [
        for (final entry in byDay.entries) ...[
          Padding(
            padding: EdgeInsets.only(bottom: tokens.space.xs),
            child: Text(
              entry.key,
              style: tokens.typography.titleSmall.copyWith(
                color: tokens.text.secondary,
              ),
            ),
          ),
          _DayCard(slots: entry.value, tokens: tokens),
          SizedBox(height: tokens.space.md),
        ],
      ],
    );
  }

  Map<String, List<TimetableSlot>> _groupByDay(List<TimetableSlot> slots) {
    final order = const [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final result = <String, List<TimetableSlot>>{};
    for (final s in slots) {
      final day = (s.dayOfWeek ?? 'Unscheduled').toString();
      result.putIfAbsent(day, () => []).add(s);
    }
    final ordered = <String, List<TimetableSlot>>{};
    for (final day in order) {
      if (result.containsKey(day)) {
        ordered[day] = result.remove(day)!;
      }
    }
    for (final entry in result.entries) {
      ordered[entry.key] = entry.value;
    }
    return ordered;
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.slots, required this.tokens});
  final List<TimetableSlot> slots;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < slots.length; i++) ...[
            if (i > 0) Divider(height: 1, color: tokens.surface.outlineVariant),
            ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: tokens.space.md,
                vertical: tokens.space.xxs,
              ),
              leading: SizedBox(
                width: 56,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (slots[i].startTime ?? '—').toString(),
                      style: tokens.typography.titleSmall.copyWith(
                        color: tokens.text.primary,
                        fontFamily: tokens.typography.monoFamily,
                      ),
                    ),
                    Text(
                      (slots[i].endTime ?? '—').toString(),
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.text.tertiary,
                        fontFamily: tokens.typography.monoFamily,
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(
                (slots[i].subject ?? slots[i].course ?? '—').toString(),
                style: tokens.typography.titleSmall.copyWith(
                  color: tokens.text.primary,
                ),
              ),
              subtitle: Text(
                slots[i].subtitle,
                style: tokens.typography.bodySmall.copyWith(
                  color: tokens.text.secondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BranchesTab extends ConsumerWidget {
  const _BranchesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    final asyncPage = ref.watch(branchesListProvider(null));
    return asyncPage.when(
      data: (result) => switch (result) {
        Ok(:final value) => _buildList(value, tokens),
        Err(:final error) => LsStateView.error(
            icon: Icons.error_outline,
            title: 'Could not load branches',
            message: error.message,
          ),
      },
      loading: () => const LsStateView.loading(title: 'Loading branches'),
      error: (err, _) => LsStateView.error(
        icon: Icons.error_outline,
        title: 'Could not load branches',
        message: err.toString(),
      ),
    );
  }

  Widget _buildList(BranchPage page, DesignTokens tokens) {
    if (page.branches.isEmpty) {
      return LsStateView.empty(
        icon: Icons.account_tree_outlined,
        title: 'No branches yet',
        message: 'Add the first branch from the school admin console.',
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(tokens.space.md),
      itemCount: page.branches.length,
      separatorBuilder: (_, __) => SizedBox(height: tokens.space.xs),
      itemBuilder: (context, index) {
        final b = page.branches[index];
        return Container(
          padding: EdgeInsets.all(tokens.space.md),
          decoration: BoxDecoration(
            color: tokens.surface.surface,
            borderRadius: BorderRadius.circular(tokens.radius.md),
            border: Border.all(color: tokens.surface.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_tree_outlined,
                color: tokens.brand.primary,
              ),
              SizedBox(width: tokens.space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.branchName.isEmpty ? '—' : b.branchName,
                      style: tokens.typography.titleSmall.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                    SizedBox(height: tokens.space.xxs),
                    Text(
                      [
                        if (b.code != null && b.code!.isNotEmpty) b.code!,
                        if (b.city != null && b.city!.isNotEmpty) b.city!,
                        if (b.country != null && b.country!.isNotEmpty)
                          b.country!,
                      ].join(' · '),
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.text.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (b.isPrimary)
                const LsStatusChip(
                  label: 'Primary',
                  icon: Icons.star,
                  tone: LsChipTone.brand,
                ),
            ],
          ),
        );
      },
    );
  }
}
