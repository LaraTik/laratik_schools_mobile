import 'package:flutter/material.dart';

import '../../../../ui/design_tokens.dart';
import '../../../../ui/widgets/ls_status_chip.dart';
import '../../data/person.dart';

import '../../../../ui/app_theme.dart';

/// Row tile for the students / staff / guardians list.
///
/// 64dp tall, name + role/status, optional trailing caret. Tap target meets
/// the 44dp minimum even on dense rows. The status tone is computed from
/// the well-known [Person.status] values; anything not recognized falls
/// back to neutral.
class PersonCard extends StatelessWidget {
  const PersonCard({
    required this.person,
    required this.onTap,
    this.dense = false,
    super.key,
  });

  final Person person;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final tone = _toneForStatus(person.status);
    return Material(
      color: tokens.surface.surface,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: dense ? 56 : 64,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space.md,
              vertical: tokens.space.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Avatar(person: person),
                SizedBox(width: tokens.space.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.fullName.isEmpty ? '—' : person.fullName,
                        style: tokens.typography.titleSmall.copyWith(
                          color: tokens.text.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: tokens.space.xxs),
                      Text(
                        _subtitleFor(person),
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
                LsStatusChip(label: person.status, tone: tone),
                SizedBox(width: tokens.space.xs),
                Icon(
                  // Mirror the chevron under RTL so the
                  // visual "next →" stays consistent with
                  // the text flow. The pattern matches the
                  // student + parent + teacher home tiles
                  // (raw `Icon` does not auto-mirror like
                  // `ListTile` does).
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left
                      : Icons.chevron_right,
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

  String _subtitleFor(Person person) {
    final parts = <String>[];
    if (person.grade != null && person.grade!.isNotEmpty) {
      parts.add(person.grade!);
    }
    if (person.classGroup != null && person.classGroup!.isNotEmpty) {
      parts.add(person.classGroup!);
    }
    if (person.schoolStudentNumber != null &&
        person.schoolStudentNumber!.isNotEmpty) {
      parts.add('#${person.schoolStudentNumber}');
    } else if (person.id.isNotEmpty) {
      parts.add('#${person.id}');
    }
    return parts.join(' · ');
  }

  LsChipTone _toneForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return LsChipTone.success;
      case 'inactive':
      case 'withdrawn':
        return LsChipTone.warning;
      case 'transferred':
        return LsChipTone.info;
      case 'graduated':
        return LsChipTone.brand;
      default:
        return LsChipTone.neutral;
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.person});
  final Person person;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final initials = _initials(person.fullName);
    final photoUrl = person.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: tokens.brand.primaryContainer,
        foregroundImage: NetworkImage(photoUrl),
        child: Text(
          initials,
          style: tokens.typography.labelLarge.copyWith(
            color: tokens.brand.onPrimaryContainer,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: tokens.brand.primaryContainer,
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
