import 'package:flutter/material.dart';

import '../design_tokens.dart';

enum LsChipTone { neutral, success, warning, error, info, brand }

/// A compact label-and-tone chip. Used for status, role, capability, and
/// warning indicators across the app. Tones map to the [StatusPalette] in
/// the design tokens; the [neutral] tone uses the surface palette.
class LsStatusChip extends StatelessWidget {
  const LsStatusChip({
    required this.label,
    this.tone = LsChipTone.neutral,
    this.icon,
    super.key,
  });

  final String label;
  final LsChipTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    final (Color bg, Color fg) = switch (tone) {
      LsChipTone.neutral => (
          tokens.surface.surfaceContainerHigh,
          tokens.text.secondary,
        ),
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
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space.sm,
        vertical: tokens.space.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(tokens.radius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            SizedBox(width: tokens.space.xxs),
          ],
          Text(
            label,
            style: tokens.typography.labelSmall.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
