import 'package:flutter/material.dart';

import '../../../../ui/design_tokens.dart';
import '../../../../ui/widgets/ls_status_chip.dart';
import '../../data/guardian.dart';

import '../../../../ui/app_theme.dart';

class GuardianCard extends StatelessWidget {
  const GuardianCard({
    required this.guardian,
    required this.onTap,
    this.dense = false,
    super.key,
  });

  final Guardian guardian;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final linked = guardian.linkedStudentNames;
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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: tokens.brand.primaryContainer,
                  child: Icon(
                    Icons.shield_outlined,
                    color: tokens.brand.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                SizedBox(width: tokens.space.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guardian.guardianName.isEmpty
                            ? '—'
                            : guardian.guardianName,
                        style: tokens.typography.titleSmall.copyWith(
                          color: tokens.text.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: tokens.space.xxs),
                      Text(
                        _subtitleFor(guardian, linked),
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
                  label: linked.isEmpty
                      ? guardian.status
                      : '${linked.length} student${linked.length == 1 ? '' : 's'}',
                  tone: linked.isEmpty ? LsChipTone.neutral : LsChipTone.brand,
                  icon: linked.isEmpty ? null : Icons.people_outline,
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

  String _subtitleFor(Guardian g, List<String> linked) {
    final parts = <String>[];
    if (g.relation != null && g.relation!.isNotEmpty) {
      parts.add(g.relation!);
    }
    if (linked.isNotEmpty) {
      parts.add(linked.first);
      if (linked.length > 1) parts.add('+${linked.length - 1}');
    } else if (g.phone != null && g.phone!.isNotEmpty) {
      parts.add(g.phone!);
    }
    return parts.join(' · ');
  }
}
