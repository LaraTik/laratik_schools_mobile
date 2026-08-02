import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_search_bar.dart';
import '../data/person.dart';
import '../data/person_failure.dart';
import '../data/person_providers.dart';
import '../data/person_repository.dart';
import 'widgets/person_card.dart';

import '../../../ui/app_theme.dart';
import '../data/filter_options.dart';

/// Students list. Server-paginated keyset (default 50 per page), case-
/// insensitive name search, grade + class-group filter chips, manual
/// pull-to-refresh, and a primary "New student" action in the app bar.
///
/// The list composition is built around a single [ListView] with
/// `shrinkWrap: false` so virtualized scrolling is preserved on
/// dense class groups (the School_app original fetched everything).
class StudentsListScreen extends ConsumerStatefulWidget {
  const StudentsListScreen({super.key});

  @override
  ConsumerState<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends ConsumerState<StudentsListScreen> {
  final ScrollController _scrollController = ScrollController();

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
      ref.read(studentsListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final filter = ref.watch(studentsFilterProvider);
    final asyncPage = ref.watch(studentsListProvider);
    final filterIsEmpty = filter.isEmpty;

    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Students',
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(studentsListProvider.notifier).refresh(),
          ),
          Padding(
            padding: EdgeInsets.only(right: tokens.space.sm),
            child: LsButton.primary(
              label: 'New student',
              icon: Icons.add,
              expand: false,
              onPressed: () => context.go('/shell/students/new'),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56 + tokens.space.md * 2),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space.md,
              0,
              tokens.space.md,
              tokens.space.md,
            ),
            child: Column(
              children: [
                LsSearchBar(
                  initialValue: filter.search,
                  placeholder: 'Search by name or student number',
                  onChanged: (value) {
                    ref.read(studentsFilterProvider.notifier).update(
                          (f) => f.copyWith(search: value),
                        );
                  },
                ),
                SizedBox(height: tokens.space.sm),
                _FilterRow(filter: filter),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(studentsListProvider.notifier).refresh(),
        child: asyncPage.when(
          data: (page) => _buildList(page, filterIsEmpty, tokens),
          loading: () => const LsStateView.loading(
            title: 'Loading students',
            message: 'Fetching the latest roster from the server.',
          ),
          error: (err, _) => _buildError(err, tokens),
        ),
      ),
    );
  }

  Widget _buildList(
    PersonPage page,
    bool filterIsEmpty,
    DesignTokens tokens,
  ) {
    final people = page.people;
    if (people.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: tokens.space.xxxl * 2),
          LsStateView.empty(
            icon: Icons.school_outlined,
            title: filterIsEmpty
                ? 'No students yet'
                : 'No students match the current filter',
            message: filterIsEmpty
                ? 'Add the first student to get started.'
                : 'Try clearing the search or the grade filter.',
            action: filterIsEmpty
                ? LsButton.primary(
                    label: 'Add student',
                    icon: Icons.add,
                    onPressed: () => context.go('/shell/students/new'),
                  )
                : null,
          ),
        ],
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: tokens.space.xl),
      itemCount: people.length + (page.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: tokens.surface.outlineVariant,
      ),
      itemBuilder: (context, index) {
        if (index >= people.length) {
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
        final person = people[index];
        return PersonCard(
          person: person,
          onTap: () => context.go('/shell/students/${person.id}'),
        );
      },
    );
  }

  Widget _buildError(Object err, DesignTokens tokens) {
    final failure = err is PersonFailure ? err : null;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: tokens.space.xxxl * 2),
        LsStateView.error(
          icon: Icons.error_outline,
          title: 'Could not load students',
          message: failure?.message ?? err.toString(),
          action: LsButton.primary(
            label: 'Try again',
            icon: Icons.refresh,
            expand: false,
            onPressed: () => ref.read(studentsListProvider.notifier).refresh(),
          ),
        ),
      ],
    );
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow({required this.filter});

  final StudentsFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final asyncPage = ref.watch(studentsListProvider);
    // The v1 SDK does not expose a "list grades" / "list class
    // groups" endpoint today, so the filter values are derived from
    // the currently loaded students. The previous version
    // hard-coded `['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4']`
    // and `['A', 'B', 'C', 'D']` which lied to the operator when
    // the school uses a different catalog (e.g. "Year 1" or
    // "KG-2"). The derived list is honest: it shows the grades
    // and class groups that exist in the data the mobile has
    // already pulled.
    final derived = deriveFilterOptions(
      asyncPage.maybeWhen(
        data: (page) => page.people,
        orElse: () => const <Person>[],
      ),
    );
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: filter.gradeId ?? 'Grade',
            selected: filter.gradeId != null,
            onTap: derived.grades.isEmpty
                ? null
                : () => _showGradeFilter(context, ref, derived.grades),
          ),
          SizedBox(width: tokens.space.xs),
          _FilterChip(
            label: filter.classGroupId ?? 'Class group',
            selected: filter.classGroupId != null,
            onTap: derived.classGroups.isEmpty
                ? null
                : () => _showClassGroupFilter(
                      context,
                      ref,
                      derived.classGroups,
                    ),
          ),
          SizedBox(width: tokens.space.xs),
          if (!filter.isEmpty)
            _FilterChip(
              label: 'Clear',
              icon: Icons.close,
              onTap: () => ref
                  .read(studentsFilterProvider.notifier)
                  .update((f) => const StudentsFilter()),
            ),
        ],
      ),
    );
  }

  void _showGradeFilter(
    BuildContext context,
    WidgetRef ref,
    List<String> options,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _SimpleFilterSheet(
        title: 'Filter by grade',
        options: options,
        onSelected: (value) {
          ref.read(studentsFilterProvider.notifier).update(
                (f) => f.copyWith(gradeId: value),
              );
        },
      ),
    );
  }

  void _showClassGroupFilter(
    BuildContext context,
    WidgetRef ref,
    List<String> options,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _SimpleFilterSheet(
        title: 'Filter by class group',
        options: options,
        onSelected: (value) {
          ref.read(studentsFilterProvider.notifier).update(
                (f) => f.copyWith(classGroupId: value),
              );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.selected = false,
    this.icon,
    this.onTap,
  });

  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    return Material(
      color: selected
          ? tokens.brand.primaryContainer
          : tokens.surface.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.pill),
        side: BorderSide(
          color: selected ? tokens.brand.primary : tokens.surface.outline,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radius.pill),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space.md,
            vertical: tokens.space.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: tokens.text.secondary),
                SizedBox(width: tokens.space.xxs),
              ],
              Text(
                label,
                style: tokens.typography.labelMedium.copyWith(
                  color: selected
                      ? tokens.brand.onPrimaryContainer
                      : tokens.text.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleFilterSheet extends StatelessWidget {
  const _SimpleFilterSheet({
    required this.title,
    required this.options,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.space.md,
                vertical: tokens.space.xs,
              ),
              child: Text(
                title,
                style: tokens.typography.titleMedium.copyWith(
                  color: tokens.text.primary,
                ),
              ),
            ),
            for (final option in options)
              ListTile(
                title: Text(option),
                onTap: () {
                  onSelected(option);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
