// SPDX-License-Identifier: Proprietary
// Per-child detail screen with 4 tabs: Overview / Grades /
// Attendance / Report cards.
//
// Reused by:
//   * Parents picking from "My children" — `/shell/family/:studentId`.
//     The header is the child's name + grade + relation chip.
//   * Students opening their own records — `/shell/me/records`. The
//     header is the current student's name and the screen reads the
//     same providers; the only difference is the AppBar label.
//
// The data layer is [childRecordsProvider], a single FutureProvider
// that returns the full [StudentRecordsPage] (grades + attendance +
// report cards) in one shot. Splitting it per-tab would mean three
// loaders and three error states for the same data; the v1 SDK
// exposes each endpoint independently but the latency is small
// enough that a single fetch is friendlier to the UI.
//
// Per-tab bodies:
//   * Overview: identity summary + counts (how many grades, how many
//     attendance rows, latest report card) so the user gets a quick
//     health-check at a glance.
//   * Grades: per-assessment row with subject, score / max, a
//     percentage bar, and the pass / fail chip.
//   * Attendance: per-day row with date, class group, and status
//     chip. Sorted newest-first.
//   * Report cards: term-summary cards with academic year, term,
//     average score, and the published date.
//
// All user-facing copy is locale-aware via
// [AppLocalizations.of(context)]; the overview summary text shifts
// voice between "your records" (student) and "this child's records"
// (parent) per the [isOwnRecords] flag.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../data/family_failure.dart';
import '../data/family_providers.dart';
import '../data/family_repository.dart';

/// Child detail with Overview / Grades / Attendance / Report cards
/// tabs. The same widget is reachable from the parent "My children"
/// picker and from the student "My records" route; the
/// [isOwnRecords] flag changes only the AppBar label and a few
/// sub-titles so the surface reads naturally to both audiences.
class ChildDetailScreen extends ConsumerWidget {
  const ChildDetailScreen({
    required this.studentId,
    this.title,
    this.isOwnRecords = false,
    super.key,
  });

  /// The School Student id (e.g. `STU-00001`).
  final String studentId;

  /// Optional override for the AppBar title. When null, the title
  /// is "Child" or "My records" based on [isOwnRecords].
  final String? title;

  /// When `true`, the surface is rendered as the student looking
  /// at their own records. The labels shift from "Child" to
  /// "My records" and the overview sub-text drops the "your
  /// child's" voice. The data layer is identical.
  final bool isOwnRecords;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(childRecordsProvider(studentId));
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: tokens.surface.canvas,
        appBar: AppBar(
          backgroundColor: tokens.surface.surface,
          elevation: 0,
          leading: IconButton(
            tooltip: l.commonBack,
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _onBack(context, isOwnRecords),
          ),
          title: Text(
            title ??
                (isOwnRecords
                    ? l.childDetailTitleOwn
                    : l.childDetailTitleOther),
            style: tokens.typography.titleLarge.copyWith(
              color: tokens.text.primary,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: tokens.surface.surface,
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: tokens.brand.primary,
                labelColor: tokens.brand.primary,
                unselectedLabelColor: tokens.text.secondary,
                labelStyle: tokens.typography.labelLarge,
                tabs: [
                  Tab(text: l.childDetailTabOverview),
                  Tab(text: l.childDetailTabGrades),
                  Tab(text: l.childDetailTabAttendance),
                  Tab(text: l.childDetailTabReports),
                ],
              ),
            ),
          ),
        ),
        body: async.when(
          data: (result) => switch (result) {
            Ok(:final value) => TabBarView(
                children: [
                  _OverviewTab(page: value, isOwnRecords: isOwnRecords),
                  _GradesTab(records: value.grades.items),
                  _AttendanceTab(records: value.attendance.items),
                  _ReportCardsTab(records: value.reportCards.items),
                ],
              ),
            Err(:final error) => _ErrorView(
                error: error,
                onRetry: () => ref.invalidate(childRecordsProvider(studentId)),
              ),
          },
          loading: () => LsStateView.loading(
            title: l.childDetailLoadingTitle,
            message: l.childDetailLoadingMessage,
          ),
          error: (err, _) => LsStateView.error(
            icon: Icons.error_outline,
            title: l.childDetailEmptyStateFallback,
            message: err.toString(),
            action: LsButton.primary(
              label: l.commonTryAgain,
              expand: false,
              onPressed: () => ref.invalidate(childRecordsProvider(studentId)),
            ),
          ),
        ),
      ),
    );
  }

  void _onBack(BuildContext context, bool isOwnRecords) {
    if (context.canPop()) {
      context.pop();
    } else if (isOwnRecords) {
      context.go('/shell');
    } else {
      context.go('/shell/family');
    }
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final FamilyFailure error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LsStateView.error(
      icon: Icons.error_outline,
      title: l.childDetailEmptyStateFallback,
      message: error.message,
      action: LsButton.primary(
        label: l.commonTryAgain,
        expand: false,
        onPressed: onRetry,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overview tab
// ---------------------------------------------------------------------------

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.page, required this.isOwnRecords});
  final StudentRecordsPage page;
  final bool isOwnRecords;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final grades = page.grades.items;
    final attendance = page.attendance.items;
    final reportCards = page.reportCards.items;
    final present = attendance.where((r) => r.isPresent()).length;
    final absent = attendance.where((r) => r.isAbsent()).length;
    final late = attendance.where((r) => r.isLate()).length;
    final passed = grades.where((r) => r.passed).length;
    final avg = _averagePercent(grades);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        tokens.space.md,
        tokens.space.md,
        tokens.space.md,
        tokens.space.xl,
      ),
      children: [
        _SummaryCard(
          tokens: tokens,
          icon: Icons.school_outlined,
          title: isOwnRecords
              ? l.childDetailOverviewTitleOwn
              : l.childDetailOverviewTitleOther,
          message: isOwnRecords
              ? l.childDetailOverviewMessageOwn
              : l.childDetailOverviewMessageOther,
        ),
        SizedBox(height: tokens.space.lg),
        _KpiRow(
          tokens: tokens,
          items: [
            _KpiData(
              icon: Icons.assignment_turned_in_outlined,
              label: l.childDetailOverviewKpiGrades,
              value: grades.length.toString(),
              sub: grades.isEmpty
                  ? l.childDetailAverageNoGrades
                  : (passed == grades.length
                      ? l.childDetailGradesAllPassed
                      : l.childDetailGradesOfTotalPassed(
                          passed, grades.length)),
              tone: LsChipTone.brand,
            ),
            _KpiData(
              icon: Icons.percent_outlined,
              label: l.childDetailOverviewKpiAverage,
              value: avg == null ? '—' : '${avg.toStringAsFixed(0)}%',
              sub: avg == null
                  ? l.childDetailAverageNoGrades
                  : (avg >= 70
                      ? l.childDetailAverageOnTrack
                      : l.childDetailAverageBelowTarget),
              tone: avg == null
                  ? LsChipTone.neutral
                  : (avg >= 70 ? LsChipTone.success : LsChipTone.warning),
            ),
            _KpiData(
              icon: Icons.fact_check_outlined,
              label: l.childDetailOverviewKpiAttendance,
              value: attendance.length.toString(),
              sub: absent == 0
                  ? l.childDetailAttendanceNoAbsences
                  : (late > 0
                      ? l.childDetailAttendanceKpiSubLate(present, absent, late)
                      : l.childDetailAttendanceKpiSub(present, absent)),
              tone: absent == 0
                  ? LsChipTone.success
                  : (absent > present ? LsChipTone.error : LsChipTone.warning),
            ),
            _KpiData(
              icon: Icons.summarize_outlined,
              label: l.childDetailOverviewKpiReports,
              value: reportCards.length.toString(),
              sub: reportCards.isEmpty
                  ? l.childDetailReportCardNoCards
                  : l.childDetailReportCardLatest(
                      _latestReportLabel(reportCards),
                    ),
              tone: LsChipTone.info,
            ),
          ],
        ),
      ],
    );
  }

  static double? _averagePercent(List<ChildGradeRecord> grades) {
    final pcts = grades
        .map((g) => g.percentage)
        .whereType<double>()
        .toList(growable: false);
    if (pcts.isEmpty) return null;
    final sum = pcts.fold<double>(0, (a, b) => a + b);
    return sum / pcts.length;
  }

  static String _latestReportLabel(List<ChildReportCard> cards) {
    if (cards.isEmpty) return '';
    final sorted = [...cards]
      ..sort((a, b) => (b.publishedOn ?? '').compareTo(a.publishedOn ?? ''));
    final latest = sorted.first;
    final parts = <String>[];
    if (latest.term.isNotEmpty) parts.add(latest.term);
    if (latest.academicYear.isNotEmpty) parts.add(latest.academicYear);
    return parts.isEmpty ? '—' : parts.join(' · ');
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.tokens,
    required this.icon,
    required this.title,
    required this.message,
  });
  final DesignTokens tokens;
  final IconData icon;
  final String title;
  final String message;

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
          Icon(icon, color: tokens.brand.primary, size: 22),
          SizedBox(width: tokens.space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
                SizedBox(height: tokens.space.xxs),
                Text(
                  message,
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

class _KpiData {
  const _KpiData({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.tone,
  });
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final LsChipTone tone;
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.tokens, required this.items});
  final DesignTokens tokens;
  final List<_KpiData> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 2 columns on phones, 4 on wide layouts. Each card needs
        // at least 140dp to keep the value readable.
        final isWide = constraints.maxWidth >= 720;
        final cols = isWide ? items.length : 2;
        final rows = (items.length / cols).ceil();
        return Column(
          children: [
            for (var r = 0; r < rows; r++) ...[
              if (r > 0) SizedBox(height: tokens.space.sm),
              Row(
                children: [
                  for (var c = 0; c < cols; c++) ...[
                    if (c > 0) SizedBox(width: tokens.space.sm),
                    Expanded(
                      child: _KpiCard(
                        tokens: tokens,
                        data: items[r * cols + c],
                      ),
                    ),
                  ],
                  // Pad the trailing row when the count doesn't
                  // divide evenly, so the remaining cells stretch
                  // to the same width.
                  for (var c = items.length - r * cols; c < cols; c++) ...[
                    if (c > 0) SizedBox(width: tokens.space.sm),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.tokens, required this.data});
  final DesignTokens tokens;
  final _KpiData data;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (data.tone) {
      LsChipTone.success => (
          tokens.status.successContainer,
          tokens.status.success,
        ),
      LsChipTone.warning => (
          tokens.status.warningContainer,
          tokens.status.warning,
        ),
      LsChipTone.error => (
          tokens.status.errorContainer,
          tokens.status.error,
        ),
      LsChipTone.info => (
          tokens.status.infoContainer,
          tokens.status.info,
        ),
      LsChipTone.brand => (
          tokens.brand.primaryContainer,
          tokens.brand.onPrimaryContainer,
        ),
      LsChipTone.neutral => (
          tokens.surface.surfaceContainerHigh,
          tokens.text.secondary,
        ),
    };
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
            child: Icon(data.icon, color: fg, size: 18),
          ),
          SizedBox(height: tokens.space.sm),
          Text(
            data.value,
            style: tokens.typography.titleLarge.copyWith(
              color: tokens.text.primary,
            ),
          ),
          SizedBox(height: tokens.space.xxs),
          Text(
            data.label,
            style: tokens.typography.labelMedium.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          SizedBox(height: tokens.space.xxs),
          Text(
            data.sub,
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.text.tertiary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grades tab
// ---------------------------------------------------------------------------

class _GradesTab extends StatelessWidget {
  const _GradesTab({required this.records});
  final List<ChildGradeRecord> records;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (records.isEmpty) {
      return LsStateView.empty(
        icon: Icons.assignment_outlined,
        title: l.childDetailGradesEmptyTitle,
        message: l.childDetailGradesEmptyMessage,
      );
    }
    // Newest first; fallback to the wire order if a row has no date.
    final sorted = [...records]..sort((a, b) {
        final ad = a.publishedOn ?? '';
        final bd = b.publishedOn ?? '';
        if (ad.isEmpty && bd.isEmpty) return 0;
        if (ad.isEmpty) return 1;
        if (bd.isEmpty) return -1;
        return bd.compareTo(ad);
      });
    final tokens = context.laratik;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        tokens.space.md,
        tokens.space.md,
        tokens.space.md,
        tokens.space.xl,
      ),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => SizedBox(height: tokens.space.sm),
      itemBuilder: (context, i) => _GradeRow(record: sorted[i]),
    );
  }
}

class _GradeRow extends StatelessWidget {
  const _GradeRow({required this.record});
  final ChildGradeRecord record;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final pct = record.percentage;
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.assessmentName.isEmpty
                          ? l.childDetailGradeAssessmentFallback
                          : record.assessmentName,
                      style: tokens.typography.titleSmall.copyWith(
                        color: tokens.text.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (record.subject.isNotEmpty) ...[
                      SizedBox(height: tokens.space.xxs),
                      Text(
                        record.subject,
                        style: tokens.typography.bodySmall.copyWith(
                          color: tokens.text.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: tokens.space.sm),
              if (record.letterGrade.isNotEmpty)
                LsStatusChip(
                  label: record.letterGrade,
                  tone: record.passed ? LsChipTone.success : LsChipTone.error,
                )
              else if (record.passStatus.isNotEmpty)
                LsStatusChip(
                  label: record.passed
                      ? l.childDetailGradePass
                      : l.childDetailGradeFail,
                  tone: record.passed ? LsChipTone.success : LsChipTone.error,
                ),
            ],
          ),
          SizedBox(height: tokens.space.sm),
          _ScoreBar(record: record, percentage: pct, tokens: tokens),
          if (record.publishedOn != null && record.publishedOn!.isNotEmpty) ...[
            SizedBox(height: tokens.space.xs),
            Text(
              l.childDetailGradePublishedOn(record.publishedOn!),
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.text.tertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({
    required this.record,
    required this.percentage,
    required this.tokens,
  });
  final ChildGradeRecord record;
  final double? percentage;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    final p = percentage;
    final color = _barColor(p);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${_formatScore(record.score)} / ${_formatScore(record.maxScore)}',
          style: tokens.typography.titleSmall.copyWith(
            color: tokens.text.primary,
          ),
        ),
        SizedBox(width: tokens.space.md),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius.pill),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: tokens.surface.surfaceContainerHigh),
                  FractionallySizedBox(
                    widthFactor: p == null ? 0 : (p.clamp(0, 100) / 100),
                    child: Container(color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: tokens.space.sm),
        Text(
          p == null ? '—' : '${p.toStringAsFixed(0)}%',
          style: tokens.typography.titleSmall.copyWith(color: color),
        ),
      ],
    );
  }

  String _formatScore(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  Color _barColor(double? p) {
    if (p == null) return tokens.text.tertiary;
    if (p >= 85) return tokens.status.success;
    if (p >= 70) return tokens.brand.primary;
    if (p >= 50) return tokens.status.warning;
    return tokens.status.error;
  }
}

// ---------------------------------------------------------------------------
// Attendance tab
// ---------------------------------------------------------------------------

class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab({required this.records});
  final List<ChildAttendanceRecord> records;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (records.isEmpty) {
      return LsStateView.empty(
        icon: Icons.fact_check_outlined,
        title: l.childDetailAttendanceEmptyTitle,
        message: l.childDetailAttendanceEmptyMessage,
      );
    }
    final tokens = context.laratik;
    final sorted = [...records]..sort((a, b) => b.date.compareTo(a.date));
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        tokens.space.md,
        tokens.space.md,
        tokens.space.md,
        tokens.space.xl,
      ),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => SizedBox(height: tokens.space.sm),
      itemBuilder: (context, i) => _AttendanceRow(record: sorted[i]),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.record});
  final ChildAttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final (LsChipTone tone, IconData icon) =
        switch (record.status.toLowerCase()) {
      'present' => (LsChipTone.success, Icons.check_circle_outline),
      'late' => (LsChipTone.warning, Icons.access_time_outlined),
      'excused' => (LsChipTone.info, Icons.event_busy_outlined),
      'absent' => (LsChipTone.error, Icons.cancel_outlined),
      _ => (LsChipTone.neutral, Icons.help_outline),
    };
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tokens.surface.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
            alignment: Alignment.center,
            child: Text(
              _dayLabel(record.date),
              style: tokens.typography.labelMedium.copyWith(
                color: tokens.text.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: tokens.space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.date,
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
                if (record.classGroup != null &&
                    record.classGroup!.isNotEmpty) ...[
                  SizedBox(height: tokens.space.xxs),
                  Text(
                    record.classGroup!,
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.text.secondary,
                    ),
                  ),
                ],
                if (record.notes != null && record.notes!.isNotEmpty) ...[
                  SizedBox(height: tokens.space.xxs),
                  Text(
                    record.notes!,
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.text.tertiary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: tokens.space.sm),
          LsStatusChip(
            label: _capitalize(record.status),
            tone: tone,
            icon: icon,
          ),
        ],
      ),
    );
  }

  String _dayLabel(String iso) {
    // Best-effort: pull the day-of-month from a YYYY-MM-DD string
    // without parsing it as a tz-aware DateTime. Falls back to the
    // raw last 2 chars if the shape is unexpected.
    if (iso.length >= 10) {
      return iso.substring(8, 10);
    }
    return iso;
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

// ---------------------------------------------------------------------------
// Report cards tab
// ---------------------------------------------------------------------------

class _ReportCardsTab extends StatelessWidget {
  const _ReportCardsTab({required this.records});
  final List<ChildReportCard> records;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (records.isEmpty) {
      return LsStateView.empty(
        icon: Icons.summarize_outlined,
        title: l.childDetailReportsEmptyTitle,
        message: l.childDetailReportsEmptyMessage,
      );
    }
    final tokens = context.laratik;
    final sorted = [...records]..sort((a, b) {
        final ad = a.publishedOn ?? '';
        final bd = b.publishedOn ?? '';
        if (ad.isEmpty && bd.isEmpty) return 0;
        if (ad.isEmpty) return 1;
        if (bd.isEmpty) return -1;
        return bd.compareTo(ad);
      });
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        tokens.space.md,
        tokens.space.md,
        tokens.space.md,
        tokens.space.xl,
      ),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => SizedBox(height: tokens.space.sm),
      itemBuilder: (context, i) => _ReportCardRow(record: sorted[i]),
    );
  }
}

class _ReportCardRow extends StatelessWidget {
  const _ReportCardRow({required this.record});
  final ChildReportCard record;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
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
                Icons.summarize_outlined,
                color: tokens.brand.primary,
                size: 20,
              ),
              SizedBox(width: tokens.space.xs),
              Expanded(
                child: Text(
                  _title(context),
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
              ),
              if (record.averageScore != null)
                LsStatusChip(
                  label: '${record.averageScore!.toStringAsFixed(0)}%',
                  tone: record.averageScore! >= 70
                      ? LsChipTone.success
                      : LsChipTone.warning,
                ),
            ],
          ),
          SizedBox(height: tokens.space.xs),
          if (record.publishedOn != null && record.publishedOn!.isNotEmpty)
            Text(
              l.childDetailGradePublishedOn(record.publishedOn!),
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.text.tertiary,
              ),
            ),
        ],
      ),
    );
  }

  String _title(BuildContext context) {
    final l = AppLocalizations.of(context);
    final parts = <String>[];
    if (record.term.isNotEmpty) parts.add(record.term);
    if (record.academicYear.isNotEmpty) parts.add(record.academicYear);
    return parts.isEmpty ? l.childDetailReportCardFallback : parts.join(' · ');
  }
}
