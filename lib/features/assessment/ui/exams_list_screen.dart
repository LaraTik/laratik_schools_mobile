import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../../people/data/person_failure.dart';
import '../data/assessment_providers.dart';
import '../data/assessment_repository.dart';
import '../data/exam.dart';

import '../../../ui/app_theme.dart';

class ExamsListScreen extends ConsumerStatefulWidget {
  const ExamsListScreen({super.key});

  @override
  ConsumerState<ExamsListScreen> createState() => _ExamsListScreenState();
}

class _ExamsListScreenState extends ConsumerState<ExamsListScreen> {
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
      ref.read(examPlansListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final asyncPage = ref.watch(examPlansListProvider);
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shell/academics'),
        ),
        title: Text(
          l.examsListScreenTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(examPlansListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(examPlansListProvider.notifier).refresh(),
        child: asyncPage.when(
          data: (page) => _buildList(page, tokens, l),
          loading: () => LsStateView.loading(
            title: l.examsListLoadingTitle,
            message: l.examsListLoadingMessage,
          ),
          error: (err, _) => _buildError(err, tokens, l),
        ),
      ),
    );
  }

  Widget _buildList(
    ExamPlanPage page,
    DesignTokens tokens,
    AppLocalizations l,
  ) {
    final plans = page.plans;
    if (plans.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: tokens.space.xxxl * 2),
          LsStateView.empty(
            icon: Icons.assignment_outlined,
            title: l.examsListEmptyTitle,
            message: l.examsListEmptyMessage,
          ),
        ],
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsetsDirectional.only(bottom: tokens.space.xl),
      itemCount: plans.length + (page.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: tokens.surface.outlineVariant,
      ),
      itemBuilder: (context, index) {
        if (index >= plans.length) {
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
        final plan = plans[index];
        return ListTile(
          contentPadding: EdgeInsetsDirectional.symmetric(
            horizontal: tokens.space.md,
            vertical: tokens.space.sm,
          ),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: tokens.brand.primaryContainer,
            child: Icon(
              Icons.assignment_outlined,
              color: tokens.brand.onPrimaryContainer,
              size: 22,
            ),
          ),
          title: Text(
            plan.title.isEmpty ? '—' : plan.title,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.primary,
            ),
          ),
          subtitle: Text(
            [
              if ((plan.subject ?? '').isNotEmpty) plan.subject!,
              if ((plan.examDate ?? '').isNotEmpty) plan.examDate!,
              if (plan.durationMinutes != null)
                l.examsListDurationMinutesChip(plan.durationMinutes!),
            ].join(' · '),
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          trailing: LsStatusChip(
            label: plan.published
                ? l.examsListStatusOpen
                : l.examsListStatusDraft,
            tone: plan.published ? LsChipTone.success : LsChipTone.neutral,
            icon: plan.published
                ? Icons.check_circle_outline
                : Icons.lock_outline,
          ),
          onTap: () => context.go('/shell/academics/exams/${plan.id}'),
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
          title: l.examsListErrorTitle,
          message: failure?.message ?? err.toString(),
          action: LsButton.primary(
            label: l.commonTryAgain,
            icon: Icons.refresh,
            expand: false,
            onPressed: () => ref.read(examPlansListProvider.notifier).refresh(),
          ),
        ),
      ],
    );
  }
}
