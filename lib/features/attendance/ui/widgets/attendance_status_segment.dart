import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../ui/design_tokens.dart';
import '../../../../ui/widgets/ls_status_chip.dart';
import '../../data/attendance_record.dart';

import '../../../../ui/app_theme.dart';

/// 4-way status selector: Present / Absent / Late / Excused.
/// 48dp tall per option so the operator can tap with a thumb on dense
/// rosters. The selected option uses the brand primary fill; the rest
/// are surface-tinted with the matching tone outline.
class AttendanceStatusSegment extends StatelessWidget {
  const AttendanceStatusSegment({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final AttendanceStatus value;
  final ValueChanged<AttendanceStatus> onChanged;

  static const _options = <AttendanceStatus>[
    AttendanceStatus.present,
    AttendanceStatus.absent,
    AttendanceStatus.late,
    AttendanceStatus.excused,
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          for (var i = 0; i < _options.length; i++) ...[
            Expanded(
              child: _SegmentButton(
                status: _options[i],
                label: _labelFor(_options[i], l),
                selected: _options[i].value == value.value,
                onTap: () => onChanged(_options[i]),
              ),
            ),
            if (i < _options.length - 1) SizedBox(width: tokens.space.xxs),
          ],
        ],
      ),
    );
  }

  String _labelFor(AttendanceStatus status, AppLocalizations l) {
    switch (status.tone) {
      case AttendanceTone.present:
        return l.attendanceStatusPresent;
      case AttendanceTone.absent:
        return l.attendanceStatusAbsent;
      case AttendanceTone.late:
        return l.attendanceStatusLate;
      case AttendanceTone.excused:
        return l.attendanceStatusExcused;
      case AttendanceTone.neutral:
        return status.value;
    }
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.status,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AttendanceStatus status;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final (Color bg, Color fg, Color border) = switch (status.tone) {
      AttendanceTone.present => selected
          ? (
              tokens.status.success,
              tokens.status.onSuccess,
              tokens.status.success
            )
          : (
              tokens.status.successContainer,
              tokens.status.success,
              tokens.status.success
            ),
      AttendanceTone.absent => selected
          ? (tokens.status.error, tokens.status.onError, tokens.status.error)
          : (
              tokens.status.errorContainer,
              tokens.status.error,
              tokens.status.error
            ),
      AttendanceTone.late => selected
          ? (
              tokens.status.warning,
              tokens.status.onWarning,
              tokens.status.warning
            )
          : (
              tokens.status.warningContainer,
              tokens.status.warning,
              tokens.status.warning
            ),
      AttendanceTone.excused => selected
          ? (tokens.status.info, tokens.status.onInfo, tokens.status.info)
          : (
              tokens.status.infoContainer,
              tokens.status.info,
              tokens.status.info
            ),
      AttendanceTone.neutral => selected
          ? (tokens.brand.primary, tokens.brand.onPrimary, tokens.brand.primary)
          : (
              tokens.surface.surfaceContainer,
              tokens.text.secondary,
              tokens.surface.outline
            ),
    };
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        side: BorderSide(color: border, width: selected ? 1 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: tokens.typography.labelSmall.copyWith(color: fg),
          ),
        ),
      ),
    );
  }
}

/// Compact tone badge for the read-only list rows. Reuses [LsStatusChip]
/// so the colors match the segment selector.
class AttendanceStatusBadge extends StatelessWidget {
  const AttendanceStatusBadge({required this.status, super.key});
  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final label = switch (status.tone) {
      AttendanceTone.present => l.attendanceStatusPresent,
      AttendanceTone.absent => l.attendanceStatusAbsent,
      AttendanceTone.late => l.attendanceStatusLate,
      AttendanceTone.excused => l.attendanceStatusExcused,
      AttendanceTone.neutral => status.value,
    };
    return LsStatusChip(
      label: label,
      tone: switch (status.tone) {
        AttendanceTone.present => LsChipTone.success,
        AttendanceTone.absent => LsChipTone.error,
        AttendanceTone.late => LsChipTone.warning,
        AttendanceTone.excused => LsChipTone.info,
        AttendanceTone.neutral => LsChipTone.neutral,
      },
    );
  }
}
