import 'package:flutter/material.dart';

import '../design_tokens.dart';

/// Primary action button. 48dp tall, 48dp wide target, full-width by default
/// but adapts to a compact variant when nested in a toolbar.
enum LsButtonVariant { primary, secondary, ghost, danger }

class LsButton extends StatelessWidget {
  const LsButton({
    required this.label,
    required this.onPressed,
    this.variant = LsButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    super.key,
  });

  /// Convenience constructors for the common variants.
  const LsButton.primary({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    super.key,
  }) : variant = LsButtonVariant.primary;

  const LsButton.secondary({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    super.key,
  }) : variant = LsButtonVariant.secondary;

  const LsButton.danger({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    super.key,
  }) : variant = LsButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final LsButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.forBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    final isDisabled = onPressed == null || isLoading;

    final (Color bg, Color fg, Color border) = switch (variant) {
      LsButtonVariant.primary => (
          tokens.brand.primary,
          tokens.brand.onPrimary,
          tokens.brand.primary,
        ),
      LsButtonVariant.secondary => (
          tokens.surface.surface,
          tokens.brand.primary,
          tokens.surface.outline,
        ),
      LsButtonVariant.ghost => (
          Colors.transparent,
          tokens.brand.primary,
          Colors.transparent,
        ),
      LsButtonVariant.danger => (
          tokens.status.error,
          tokens.status.onError,
          tokens.status.error,
        ),
    };

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation(fg),
            ),
          ),
          SizedBox(width: tokens.space.sm),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: fg),
          SizedBox(width: tokens.space.sm),
        ],
        Text(
          label,
          style: tokens.typography.labelLarge.copyWith(color: fg),
        ),
      ],
    );

    return Material(
      color: isDisabled
          ? bg.withValues(alpha: 0.5)
          : bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: border == Colors.transparent
            ? BorderSide.none
            : BorderSide(color: border, width: 1),
      ),
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 48, // Laratik minimum comfortable target.
            minWidth: 48,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space.md,
              vertical: tokens.space.sm,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
