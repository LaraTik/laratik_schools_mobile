import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../design_tokens.dart';

import '../../ui/app_theme.dart';

/// Debounced search field. Emits a value only after the operator stops
/// typing for [debounce] (default 350ms) so the underlying list is not
/// re-fetched per keystroke.
class LsSearchBar extends StatefulWidget {
  const LsSearchBar({
    required this.onChanged,
    this.placeholder = 'Search',
    this.debounce = const Duration(milliseconds: 350),
    this.initialValue = '',
    super.key,
  });

  final ValueChanged<String> onChanged;
  final String placeholder;
  final Duration debounce;
  final String initialValue;

  @override
  State<LsSearchBar> createState() => _LsSearchBarState();
}

class _LsSearchBarState extends State<LsSearchBar> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(value));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      style: tokens.typography.bodyMedium.copyWith(color: tokens.text.primary),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          color: tokens.text.tertiary,
          size: 20,
        ),
        hintText: widget.placeholder,
        filled: true,
        fillColor: tokens.surface.surfaceContainerLow,
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.space.md,
          vertical: tokens.space.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radius.pill),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radius.pill),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radius.pill),
          borderSide: BorderSide(color: tokens.brand.primary, width: 2),
        ),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: AppLocalizations.of(context).commonClearSearch,
                icon: Icon(
                  Icons.close,
                  color: tokens.text.tertiary,
                  size: 18,
                ),
                onPressed: () {
                  _controller.clear();
                  _onChanged('');
                  setState(() {});
                },
              ),
      ),
    );
  }
}
