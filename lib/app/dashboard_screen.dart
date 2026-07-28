import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/design_tokens.dart';
import '../ui/widgets/ls_button.dart';
import '../ui/widgets/ls_status_chip.dart';
import 'router.dart';

/// Operator landing screen. Surfaces the five top-level destinations as
/// large primary cards so the operator can find the right surface in
/// one tap. Also renders the current date + boot summary placeholder.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    final today = _today();
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          'Home',
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: tokens.space.md),
            child: Center(
              child: Text(
                today,
                style: tokens.typography.titleSmall.copyWith(
                  color: tokens.text.secondary,
                  fontFamily: tokens.typography.monoFamily,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          Text(
            'Quick start',
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          _QuickStartGrid(tokens: tokens),
          SizedBox(height: tokens.space.lg),
          Text(
            'Today',
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.sm),
          _TodaySummaryCard(tokens: tokens),
          SizedBox(height: tokens.space.lg),
          LsButton.secondary(
            label: 'Open students',
            icon: Icons.school_outlined,
            onPressed: () => context.go(ShellTab.students.route),
          ),
        ],
      ),
    );
  }

  String _today() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class _QuickStartGrid extends StatelessWidget {
  const _QuickStartGrid({required this.tokens});
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    final items = <_QuickItem>[
      _QuickItem(
        label: 'Capture attendance',
        description: 'Mark a class group',
        icon: Icons.fact_check_outlined,
        tone: LsChipTone.success,
        onTap: () => context.go('/shell/attendance'),
      ),
      _QuickItem(
        label: 'New student',
        description: 'Enrol from the registrar',
        icon: Icons.person_add_alt_1,
        tone: LsChipTone.brand,
        onTap: () => context.go('/shell/students/new'),
      ),
      _QuickItem(
        label: 'New staff',
        description: 'Add a teacher or admin',
        icon: Icons.badge_outlined,
        tone: LsChipTone.brand,
        onTap: () => context.go('/shell/staff/new'),
      ),
      _QuickItem(
        label: 'New subject',
        description: 'Add a subject to the catalog',
        icon: Icons.menu_book_outlined,
        tone: LsChipTone.info,
        onTap: () => context.go('/shell/academics/subjects/new'),
      ),
    ];
    if (isWide) {
      return Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(child: _QuickCard(item: items[i], tokens: tokens)),
            if (i < items.length - 1) SizedBox(width: tokens.space.md),
          ],
        ],
      );
    }
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _QuickCard(item: items[i], tokens: tokens),
          if (i < items.length - 1) SizedBox(height: tokens.space.sm),
        ],
      ],
    );
  }
}

class _QuickItem {
  const _QuickItem({
    required this.label,
    required this.description,
    required this.icon,
    required this.tone,
    required this.onTap,
  });
  final String label;
  final String description;
  final IconData icon;
  final LsChipTone tone;
  final VoidCallback onTap;
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.item, required this.tokens});
  final _QuickItem item;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tokens.surface.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.surface.outlineVariant),
      ),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _toneContainer(tokens, item.tone),
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Icon(
                  item.icon,
                  color: _toneFg(tokens, item.tone),
                  size: 22,
                ),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: tokens.typography.titleSmall.copyWith(
                        color: tokens.text.primary,
                      ),
                    ),
                    SizedBox(height: tokens.space.xxs),
                    Text(
                      item.description,
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.text.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: tokens.text.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _toneContainer(DesignTokens tokens, LsChipTone tone) {
    return switch (tone) {
      LsChipTone.success => tokens.status.successContainer,
      LsChipTone.warning => tokens.status.warningContainer,
      LsChipTone.error => tokens.status.errorContainer,
      LsChipTone.info => tokens.status.infoContainer,
      LsChipTone.brand => tokens.brand.primaryContainer,
      LsChipTone.neutral => tokens.surface.surfaceContainer,
    };
  }

  Color _toneFg(DesignTokens tokens, LsChipTone tone) {
    return switch (tone) {
      LsChipTone.success => tokens.status.success,
      LsChipTone.warning => tokens.status.warning,
      LsChipTone.error => tokens.status.error,
      LsChipTone.info => tokens.status.info,
      LsChipTone.brand => tokens.brand.onPrimaryContainer,
      LsChipTone.neutral => tokens.text.secondary,
    };
  }
}

class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard({required this.tokens});
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt_outlined,
                color: tokens.status.warning,
                size: 18,
              ),
              SizedBox(width: tokens.space.xs),
              Text(
                'Live counters land in Phase 2',
                style: tokens.typography.titleSmall.copyWith(
                  color: tokens.text.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space.xs),
          Text(
            'The home dashboard is read-mostly today; live counters and '
            'operations health surface once the Phase 2 boot pipeline '
            'and operations permission are wired.',
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
