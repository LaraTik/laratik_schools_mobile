import 'package:flutter/material.dart';

import '../design_tokens.dart';

import '../../ui/app_theme.dart';

/// State for an empty / loading / error surface. The same widget handles
/// all three with a consistent layout — keeps the operator experience
/// predictable and saves each screen from re-implementing the same shape.
class LsStateView extends StatelessWidget {
  const LsStateView({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    super.key,
  });

  /// Convenience constructors for the common states.
  const LsStateView.empty({
    required IconData icon,
    required String title,
    String? message,
    Widget? action,
    super.key,
  })  : icon = icon,
        title = title,
        message = message,
        action = action;

  const LsStateView.error({
    required IconData icon,
    required String title,
    String? message,
    Widget? action,
    super.key,
  })  : icon = icon,
        title = title,
        message = message,
        action = action;

  const LsStateView.loading({
    String title = 'Loading',
    String? message,
    super.key,
  })  : icon = Icons.hourglass_empty,
        title = title,
        message = message,
        action = null;

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.space.xl),
        child: Semantics(
          // The icon + title is the screen-reader announcement. The
          // message is part of the same region; the action gets its
          // own Semantics from the underlying button so it isn't
          // re-announced here.
          container: true,
          label: title,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: tokens.text.tertiary),
              SizedBox(height: tokens.space.md),
              Text(
                title,
                style: tokens.typography.titleMedium.copyWith(
                  color: tokens.text.primary,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                SizedBox(height: tokens.space.xs),
                Text(
                  message!,
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.text.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                SizedBox(height: tokens.space.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
