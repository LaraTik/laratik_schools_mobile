import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_search_bar.dart';
import '../../people/data/person_failure.dart';
import '../data/guardian.dart';
import '../data/guardian_providers.dart';
import '../data/guardian_repository.dart';
import 'widgets/guardian_card.dart';

import '../../../ui/app_theme.dart';

class GuardiansListScreen extends ConsumerStatefulWidget {
  const GuardiansListScreen({super.key});

  @override
  ConsumerState<GuardiansListScreen> createState() =>
      _GuardiansListScreenState();
}

class _GuardiansListScreenState extends ConsumerState<GuardiansListScreen> {
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
      ref.read(guardianListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final filter = ref.watch(guardianFilterProvider);
    final asyncPage = ref.watch(guardianListProvider);

    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          l.guardianListScreenTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(guardianListProvider.notifier).refresh(),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(end: tokens.space.sm),
            child: LsButton.primary(
              label: l.guardianListNewGuardianAction,
              icon: Icons.person_add,
              expand: false,
              onPressed: () => context.go('/shell/guardians/new'),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56 + tokens.space.md * 2),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              tokens.space.md,
              0,
              tokens.space.md,
              tokens.space.md,
            ),
            child: Column(
              children: [
                LsSearchBar(
                  initialValue: filter.search,
                  placeholder: l.guardianListSearchHint,
                  onChanged: (value) {
                    ref.read(guardianFilterProvider.notifier).update(
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
        onRefresh: () => ref.read(guardianListProvider.notifier).refresh(),
        child: asyncPage.when(
          data: (page) => _buildList(page, filter.isEmpty, tokens, l),
          loading: () => LsStateView.loading(
            title: l.guardianListLoadingTitle,
            message: l.guardianListLoadingMessage,
          ),
          error: (err, _) => _buildError(err, tokens, l),
        ),
      ),
    );
  }

  Widget _buildList(
    GuardianPage page,
    bool filterIsEmpty,
    DesignTokens tokens,
    AppLocalizations l,
  ) {
    final guardians = page.guardians;
    if (guardians.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: tokens.space.xxxl * 2),
          LsStateView.empty(
            icon: Icons.people_outline,
            title: filterIsEmpty
                ? l.guardianListEmptyTitle
                : l.guardianListEmptyFilterTitle,
            message: filterIsEmpty
                ? l.guardianListEmptyMessage
                : l.guardianListEmptyFilterMessage,
            action: filterIsEmpty
                ? LsButton.primary(
                    label: l.guardianListAddGuardianAction,
                    icon: Icons.person_add,
                    onPressed: () => context.go('/shell/guardians/new'),
                  )
                : null,
          ),
        ],
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsetsDirectional.only(bottom: tokens.space.xl),
      itemCount: guardians.length + (page.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: tokens.surface.outlineVariant,
      ),
      itemBuilder: (context, index) {
        if (index >= guardians.length) {
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
        final guardian = guardians[index];
        return GuardianCard(
          guardian: guardian,
          onTap: () => context.go('/shell/guardians/${guardian.id}'),
        );
      },
    );
  }

  Widget _buildError(Object err, DesignTokens tokens, AppLocalizations l) {
    final failure = err is PersonFailure ? err : null;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: tokens.space.xxxl * 2),
        LsStateView.error(
          icon: Icons.error_outline,
          title: l.guardianListErrorTitle,
          message: failure?.message ?? err.toString(),
          action: LsButton.primary(
            label: l.commonTryAgain,
            icon: Icons.refresh,
            expand: false,
            onPressed: () => ref.read(guardianListProvider.notifier).refresh(),
          ),
        ),
      ],
    );
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow({required this.filter});
  final GuardianFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: filter.relation ?? l.guardianListFilterRelation,
            selected: filter.relation != null,
            onTap: () => _showRelationFilter(context, ref, l),
          ),
          SizedBox(width: tokens.space.xs),
          if (!filter.isEmpty)
            _FilterChip(
              label: l.guardianListFilterClear,
              icon: Icons.close,
              onTap: () => ref
                  .read(guardianFilterProvider.notifier)
                  .update((f) => const GuardianFilter()),
            ),
        ],
      ),
    );
  }

  void _showRelationFilter(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _SimpleFilterSheet(
        title: l.guardianListFilterRelationTitle,
        options: [
          l.guardianListFilterRelationFather,
          l.guardianListFilterRelationMother,
          l.guardianListFilterRelationBrother,
          l.guardianListFilterRelationSister,
          l.guardianListFilterRelationUncle,
          l.guardianListFilterRelationAunt,
          l.guardianListFilterRelationGrandparent,
          l.guardianListFilterRelationOther,
        ],
        onSelected: (value) {
          ref.read(guardianFilterProvider.notifier).update(
                (f) => f.copyWith(relation: value),
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
