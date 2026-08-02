import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../../people/data/person_failure.dart';
import '../data/attendance_providers.dart';
import '../data/attendance_record.dart';
import '../data/attendance_repository.dart';
import 'widgets/attendance_mark_row.dart';
import 'widgets/attendance_status_segment.dart';

import '../../../ui/app_theme.dart';

/// Attendance capture: operator-first surface for daily / period
/// attendance. Loads the class-group roster, lets the operator tap
/// through Present / Absent / Late / Excused, and submits the batch.
///
/// Phase 1 ships the in-memory roster + per-student submit. Offline
/// drafts and bulk-replay land in Phase 4 (offline sync).
class AttendanceCaptureScreen extends ConsumerStatefulWidget {
  const AttendanceCaptureScreen({
    required this.classGroupId,
    this.gradeId,
    super.key,
  });

  final String classGroupId;
  final String? gradeId;

  @override
  ConsumerState<AttendanceCaptureScreen> createState() =>
      _AttendanceCaptureScreenState();
}

class _AttendanceCaptureScreenState
    extends ConsumerState<AttendanceCaptureScreen> {
  final Map<String, AttendanceStatus> _marks = {};
  bool _submitting = false;
  bool _submitted = false;
  AttendanceBatchResult? _result;
  String? _error;
  String _selectedDate = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = _today();
  }

  String _today() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _seedDefault(Iterable<AttendanceMark> roster) {
    for (final m in roster) {
      _marks.putIfAbsent(m.studentId, () => m.status);
    }
  }

  void _markAll(AttendanceStatus status, List<AttendanceMark> roster) {
    setState(() {
      for (final m in roster) {
        _marks[m.studentId] = status;
      }
    });
  }

  Future<void> _submit(List<AttendanceMark> roster) async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final repo = ref.read(attendanceRepositoryProvider);
    final marks = roster
        .map((m) => AttendanceMark(
              studentId: m.studentId,
              studentName: m.studentName,
              status: _marks[m.studentId] ?? m.status,
              guardianName: m.guardianName,
            ))
        .toList(growable: false);
    final result = await repo.submitBatch(
      marks: marks,
      attendanceDate: _selectedDate,
      classGroup: widget.classGroupId,
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _submitted = true;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final asyncRoster = ref.watch(attendanceRosterProvider(
      AttendanceRosterArgs(
        gradeId: widget.gradeId,
        classGroupId: widget.classGroupId,
      ),
    ));

    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shell/attendance'),
        ),
        title: Text(
          'Attendance · ${widget.classGroupId}',
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space.md,
              vertical: tokens.space.sm,
            ),
            child: Center(
              child: Text(
                _selectedDate,
                style: tokens.typography.titleSmall.copyWith(
                  color: tokens.text.secondary,
                  fontFamily: tokens.typography.monoFamily,
                ),
              ),
            ),
          ),
        ],
      ),
      body: asyncRoster.when(
        data: (result) => switch (result) {
          Ok(:final value) => () {
              _seedDefault(value);
              return _buildRoster(value, tokens);
            }(),
          Err(:final error) => LsStateView.error(
              icon: Icons.error_outline,
              title: 'Could not load the roster',
              message: error.message,
              action: LsButton.primary(
                label: 'Try again',
                expand: false,
                onPressed: () => ref.invalidate(attendanceRosterProvider(
                  AttendanceRosterArgs(
                    gradeId: widget.gradeId,
                    classGroupId: widget.classGroupId,
                  ),
                )),
              ),
            ),
        },
        loading: () => const LsStateView.loading(
          title: 'Loading roster',
          message: 'Fetching the class group from the server.',
        ),
        error: (err, _) => LsStateView.error(
          icon: Icons.error_outline,
          title: 'Could not load the roster',
          message: err.toString(),
        ),
      ),
    );
  }

  Widget _buildRoster(List<AttendanceMark> roster, DesignTokens tokens) {
    if (roster.isEmpty) {
      return LsStateView.empty(
        icon: Icons.groups_outlined,
        title: 'No students in this class group',
        message: 'Once students are enrolled, attendance capture is enabled.',
      );
    }
    final present =
        _marks.values.where((s) => s.tone == AttendanceTone.present).length;
    final absent =
        _marks.values.where((s) => s.tone == AttendanceTone.absent).length;
    final late =
        _marks.values.where((s) => s.tone == AttendanceTone.late).length;
    final excused =
        _marks.values.where((s) => s.tone == AttendanceTone.excused).length;
    return Column(
      children: [
        Container(
          color: tokens.surface.surfaceContainerLow,
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space.md,
            vertical: tokens.space.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: tokens.space.xs,
                  runSpacing: tokens.space.xs,
                  children: [
                    LsStatusChip(
                      label: 'P $present',
                      tone: LsChipTone.success,
                    ),
                    LsStatusChip(
                      label: 'A $absent',
                      tone: LsChipTone.error,
                    ),
                    LsStatusChip(
                      label: 'L $late',
                      tone: LsChipTone.warning,
                    ),
                    LsStatusChip(
                      label: 'E $excused',
                      tone: LsChipTone.info,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space.md,
              vertical: tokens.space.xs,
            ),
            children: [
              _MarkAllButton(
                label: 'Mark all present',
                onTap: () => _markAll(AttendanceStatus.present, roster),
              ),
              SizedBox(width: tokens.space.xs),
              _MarkAllButton(
                label: 'Mark all absent',
                onTap: () => _markAll(AttendanceStatus.absent, roster),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: tokens.surface.outlineVariant),
        Expanded(
          child: ListView.builder(
            itemCount: roster.length,
            itemBuilder: (context, index) {
              final m = roster[index];
              final status = _marks[m.studentId] ?? m.status;
              return AttendanceMarkRow(
                mark: AttendanceMark(
                  studentId: m.studentId,
                  studentName: m.studentName,
                  status: status,
                  guardianName: m.guardianName,
                ),
                onChanged: (newStatus) {
                  setState(() {
                    _marks[m.studentId] = newStatus;
                    _submitted = false;
                    _result = null;
                    _error = null;
                  });
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(tokens.space.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Container(
                    padding: EdgeInsets.all(tokens.space.sm),
                    decoration: BoxDecoration(
                      color: tokens.status.errorContainer,
                      borderRadius: BorderRadius.circular(tokens.radius.md),
                      border: Border.all(color: tokens.status.error),
                    ),
                    child: Text(
                      _error!,
                      style: tokens.typography.bodyMedium.copyWith(
                        color: tokens.status.error,
                      ),
                    ),
                  ),
                if (_error != null) SizedBox(height: tokens.space.sm),
                if (_submitted && _result != null)
                  Container(
                    padding: EdgeInsets.all(tokens.space.sm),
                    decoration: BoxDecoration(
                      color: tokens.status.successContainer,
                      borderRadius: BorderRadius.circular(tokens.radius.md),
                      border: Border.all(color: tokens.status.success),
                    ),
                    child: Text(
                      _result!.failed == 0
                          ? 'Submitted ${_result!.succeeded} record(s) for $_selectedDate.'
                          : 'Submitted ${_result!.succeeded}, failed ${_result!.failed} of ${_result!.succeeded + _result!.failed}.',
                      style: tokens.typography.bodyMedium.copyWith(
                        color: tokens.status.success,
                      ),
                    ),
                  ),
                if (_submitted && _result != null)
                  SizedBox(height: tokens.space.sm),
                LsButton.primary(
                  label: _submitting
                      ? 'Submitting…'
                      : _submitted
                          ? 'Re-submit'
                          : 'Submit attendance',
                  icon: Icons.check,
                  isLoading: _submitting,
                  onPressed: _submitting ? null : () => _submit(roster),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MarkAllButton extends StatelessWidget {
  const _MarkAllButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    return Material(
      color: tokens.surface.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.pill),
        side: BorderSide(color: tokens.surface.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radius.pill),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space.md,
            vertical: tokens.space.xs,
          ),
          child: Text(
            label,
            style: tokens.typography.labelMedium.copyWith(
              color: tokens.text.primary,
            ),
          ),
        ),
      ),
    );
  }
}
