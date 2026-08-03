import 'package:flutter/material.dart';

import '../../ui/app_theme.dart';

/// Reusable text field. Always renders a visible label (no placeholder-only
/// labels), keeps 48dp minimum height, exposes the per-field error so the
/// form layer can map [PersonFailure.fieldErrors] directly.
class LsTextField extends StatelessWidget {
  const LsTextField({
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.required = false,
    this.obscure = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.suffix,
    this.validator,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final String? errorText;
  final bool required;
  final bool obscure;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: tokens.typography.labelLarge.copyWith(
                  color: tokens.text.primary,
                ),
              ),
            ),
            if (required) ...[
              SizedBox(width: tokens.space.xxs),
              Text(
                '*',
                style: tokens.typography.labelLarge.copyWith(
                  color: tokens.status.error,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: tokens.space.xs),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: obscure ? 1 : maxLines,
          onChanged: onChanged,
          validator: validator,
          style: tokens.typography.bodyMedium.copyWith(
            color: tokens.text.primary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helper,
            errorText: errorText,
            suffixIcon: suffix,
            filled: true,
            fillColor: tokens.surface.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: tokens.space.md,
              vertical: tokens.space.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radius.md),
              borderSide: BorderSide(color: tokens.surface.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radius.md),
              borderSide: BorderSide(color: tokens.surface.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radius.md),
              borderSide: BorderSide(
                color: tokens.brand.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radius.md),
              borderSide: BorderSide(color: tokens.status.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radius.md),
              borderSide: BorderSide(
                color: tokens.status.error,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
