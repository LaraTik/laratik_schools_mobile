import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../people/data/person_failure.dart';
import '../data/attendance_providers.dart';
import '../data/attendance_record.dart';
import '../data/attendance_repository.dart';
import 'widgets/attendance_status_segment.dart';

/// Read-only history. Tapping a class group chip on the dashboard (Phase
/// 1.1) deep-links into [AttendanceCaptureScreen]; this list is for the
/// audit trail — who marked whom and when.
class AttendanceListScreen extends ConsumerStatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  ConsumerState<AttendanceListScreen> createState() =>
      _AttendanceListScreenState();
}

class _AttendanceListScreenState
    extends ConsumerState<AttendanceListScreen> {
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
      ref.read(attendanceListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    final asyncPage = ref.watch(attendanceListProvider);
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Attendance',
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(attendanceListProvider.notifier).refresh(),
          ),
          Padding(
            padding: EdgeInsets.only(right: tokens.space.sm),
            child: LsButton.primary(
              label: 'Capture',
              icon: Icons.fact_check_outlined,
              expand: false,
              onPressed: () => _showClassGroupPicker(context),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(attendanceListProvider.notifier).refresh(),
        child: asyncPage.when(
          data: (page) => _buildList(page, tokens),
          loading: () => const LsStateView.loading(
            title: 'Loading attendance',
            message: 'Fetching the latest records from the server.',
          ),
          error: (err, _) => _buildError(err, tokens),
        ),
      ),
    );
  }

  Widget _buildList(AttendancePage page, DesignTokens tokens) {
    final records = page.records;
    if (records.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: tokens.space.xxxl * 2),
          LsStateView.empty(
            icon: Icons.fact_check_outlined,
            title: 'No attendance records yet',
            message: 'Tap Capture to start the daily attendance for a class group.',
            action: LsButton.primary(
              label: 'Start capture',
              icon: Icons.play_arrow,
              onPressed: () => _showClassGroupPicker(context),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: tokens.space.xl),
      itemCount: records.length + (page.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: tokens.surface.outlineVariant,
      ),
      itemBuilder: (context, index) {
        if (index >= records.length) {
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
        final r = records[index];
        return ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: tokens.space.md,
            vertical: tokens.space.xxs,
          ),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: _toneBg(tokens, r.status.tone),
            child: Icon(
              _toneIcon(r.status.tone),
              color: _toneFg(tokens, r.status.tone),
              size: 18,
            ),
          ),
          title: Text(
            r.studentName.isEmpty ? '—' : r.studentName,
            style: tokens.typography.titleSmall.copyWith(
              color: tokens.text.primary,
            ),
          ),
          subtitle: Text(
            [
              if ((r.attendanceDate ?? '').isNotEmpty) r.attendanceDate!,
              if ((r.classGroup ?? '').isNotEmpty) r.classGroup!,
            ].join(' · '),
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          trailing: AttendanceStatusBadge(status: r.status),
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
          title: 'Could not load attendance',
          message: failure?.message ?? err.toString(),
          action: LsButton.primary(
            label: 'Try again',
            icon: Icons.refresh,
            expand: false,
            onPressed: () =>
                ref.read(attendanceListProvider.notifier).refresh(),
          ),
        ),
      ],
    );
  }

  void _showClassGroupPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final tokens = DesignTokens.forBrightness(
          MediaQuery.platformBrightnessOf(sheetContext),
        );
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
                    'Pick a class group',
                    style: tokens.typography.titleMedium.copyWith(
                      color: tokens.text.primary,
                    ),
                  ),
                ),
                for (final cg in const ['A', 'B', 'C', 'D'])
                  ListTile(
                    title: Text('Class group $cg'),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      context.go('/shell/attendance/capture/$cg');
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _toneBg(DesignTokens tokens, AttendanceTone tone) {
    return switch (tone) {
      AttendanceTone.present => tokens.status.successContainer,
      AttendanceTone.absent => tokens.status.errorContainer,
      AttendanceTone.late => tokens.status.warningContainer,
      AttendanceTone.excused => tokens.status.infoContainer,
      AttendanceTone.neutral => tokens.surface.surfaceContainer,
    };
  }

  Color _toneFg(DesignTokens tokens, AttendanceTone tone) {
    return switch (tone) {
      AttendanceTone.present => tokens.status.success,
      AttendanceTone.absent => tokens.status.error,
      AttendanceTone.late => tokens.status.warning,
      AttendanceTone.excused => tokens.status.info,
      AttendanceTone.neutral => tokens.text.secondary,
    };
  }

  IconData _toneIcon(AttendanceTone tone) {
    return switch (tone) {
      AttendanceTone.present => Icons.check,
      AttendanceTone.absent => Icons.close,
      AttendanceTone.late => Icons.schedule,
      AttendanceTone.excused => Icons.event_busy,
      AttendanceTone.neutral => Icons.help_outline,
    };
  }
}
