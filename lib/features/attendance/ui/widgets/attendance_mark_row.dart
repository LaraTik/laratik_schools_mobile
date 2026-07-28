import 'package:flutter/material.dart';

import '../../../ui/design_tokens.dart';
import '../../data/attendance_record.dart';
import 'attendance_status_segment.dart';

/// Per-student row on the capture screen. Name on the left, four-way
/// status segment on the right. 64dp tall so the operator can mark
/// thumb-through a roster without mis-taps.
class AttendanceMarkRow extends StatelessWidget {
  const AttendanceMarkRow({
    required this.mark,
    required this.onChanged,
    super.key,
  });

  final AttendanceMark mark;
  final ValueChanged<AttendanceStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space.md,
        vertical: tokens.space.sm,
      ),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        border: Border(
          bottom: BorderSide(color: tokens.surface.outlineVariant),
        ),
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
                      mark.studentName.isEmpty ? '—' : mark.studentName,
                      style: tokens.typography.titleSmall.copyWith(
                        color: tokens.text.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (mark.guardianName != null &&
                        mark.guardianName!.isNotEmpty)
                      Text(
                        'Guardian: ${mark.guardianName!}',
                        style: tokens.typography.bodySmall.copyWith(
                          color: tokens.text.tertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space.xs),
          AttendanceStatusSegment(value: mark.status, onChanged: onChanged),
        ],
      ),
    );
  }
}
