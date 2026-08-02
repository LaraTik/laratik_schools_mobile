import 'package:flutter/material.dart';

import '../../../../ui/design_tokens.dart';
import '../../../../ui/widgets/ls_status_chip.dart';
import '../../data/staff_member.dart';

import '../../../../ui/app_theme.dart';

/// Row tile for the staff list. Mirrors `PersonCard` but for staff; the
/// status chip tone uses the role hint when the wire status is missing.
class StaffCard extends StatelessWidget {
  const StaffCard({
    required this.member,
    required this.onTap,
    this.dense = false,
    super.key,
  });

  final StaffMember member;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    return Material(
      color: tokens.surface.surface,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: dense ? 56 : 64),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space.md,
              vertical: tokens.space.sm,
            ),
            child: Row(
              children: [
                _Avatar(member: member),
                SizedBox(width: tokens.space.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName.isEmpty ? '—' : member.fullName,
                        style: tokens.typography.titleSmall.copyWith(
                          color: tokens.text.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: tokens.space.xxs),
                      Text(
                        _subtitleFor(member),
                        style: tokens.typography.bodySmall.copyWith(
                          color: tokens.text.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: tokens.space.sm),
                LsStatusChip(
                  label: _chipLabel(member),
                  tone: _toneForStatus(member),
                ),
                SizedBox(width: tokens.space.xs),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: tokens.text.tertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitleFor(StaffMember m) {
    final parts = <String>[];
    if (m.staffRole != null && m.staffRole!.isNotEmpty) {
      parts.add(m.staffRole!);
    }
    if (m.branch != null && m.branch!.isNotEmpty) {
      parts.add(m.branch!);
    }
    if (m.id.isNotEmpty) parts.add('#${m.id}');
    return parts.join(' · ');
  }

  String _chipLabel(StaffMember m) {
    if (m.status.isNotEmpty && m.status.toLowerCase() != 'active') {
      return m.status;
    }
    if (m.staffRole != null && m.staffRole!.isNotEmpty) {
      return m.staffRole!;
    }
    return 'Active';
  }

  LsChipTone _toneForStatus(StaffMember m) {
    switch (m.status.toLowerCase()) {
      case 'inactive':
      case 'on leave':
        return LsChipTone.warning;
      case 'suspended':
      case 'terminated':
        return LsChipTone.error;
      default:
        return LsChipTone.brand;
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.member});
  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final initials = _initials(member.fullName);
    final photoUrl = member.photoUrl;
    return CircleAvatar(
      radius: 20,
      backgroundColor: tokens.brand.secondaryContainer,
      foregroundImage: (photoUrl != null && photoUrl.isNotEmpty)
          ? NetworkImage(photoUrl)
          : null,
      child: Text(
        initials,
        style: tokens.typography.labelLarge.copyWith(
          color: tokens.brand.onPrimaryContainer,
        ),
      ),
    );
  }

  String _initials(String fullName) {
    if (fullName.isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
