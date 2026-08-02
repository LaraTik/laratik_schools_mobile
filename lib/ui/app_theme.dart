/// App-wide theme plumbing. Wires the existing [DesignTokens] bundle
/// into the [ThemeData] via [ThemeExtension] so every widget can read
/// tokens from `context.laratik` (or `Theme.of(context).extension<LaratikTokens>()`).
///
/// Why a [ThemeExtension] (and not the older
/// `DesignTokens.forBrightness(MediaQuery.platformBrightnessOf(context))`)?
///
/// * The MaterialApp owns the active theme (`theme` / `darkTheme` +
///   `themeMode`). Reading the *device* brightness via
///   `MediaQuery.platformBrightnessOf` *bypasses* the app theme — the
///   widget would render light tokens even when the app is in dark
///   mode, and vice versa. Wiring tokens as a [ThemeExtension] means
///   the MaterialApp's resolved theme is the single source of truth.
/// * The [ThemeExtension] survives `Theme.of(context).copyWith(...)`
///   — a future feature can override a single palette and the
///   extension will follow.
/// * `lerp` is implemented for both brightnesses so the framework can
///   cross-fade if the user toggles the system theme mid-session.
///
/// Existing widgets still call [DesignTokens.forBrightness] for
/// backward compatibility, but the migration target is `context.laratik`
/// — every new widget should reach for that.
library;

import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// [ThemeExtension] wrapper around the existing [DesignTokens] bundle.
/// The underlying token *bundles* (light + dark) are still defined in
/// [design_tokens.dart]; this class is just the bridge that lets them
/// live inside the [ThemeData] graph.
@immutable
class LaratikTokens extends ThemeExtension<LaratikTokens> {
  const LaratikTokens({required this.tokens});

  final DesignTokens tokens;

  /// Look up the [LaratikTokens] for the active [Theme]. Returns the
  /// light bundle as a last-resort fallback so legacy widgets that
  /// still reach for the token bundle directly (without going through
  /// the [Theme]) cannot NPE during the migration window.
  static LaratikTokens of(BuildContext context) {
    return Theme.of(context).extension<LaratikTokens>() ??
        LaratikTokens(tokens: lightTokens);
  }

  @override
  LaratikTokens copyWith({DesignTokens? tokens}) =>
      LaratikTokens(tokens: tokens ?? this.tokens);

  @override
  LaratikTokens lerp(LaratikTokens? other, double t) {
    // Token bundles are discrete (we only have two). Cross-fade is a
    // no-op for now; if we ever add a third palette we can interpolate
    // individual colors via `Color.lerp` here.
    return t < 0.5 ? this : other ?? this;
  }
}

/// Ergonomic accessor — `final tokens = context.laratik;` reads the
/// token bundle for the active theme in one line. Replaces the
/// `DesignTokens.forBrightness(MediaQuery.platformBrightnessOf(context))`
/// pattern.
extension LaratikContextX on BuildContext {
  DesignTokens get laratik => LaratikTokens.of(this).tokens;
}

/// Build a Material 3 [ThemeData] from a [DesignTokens] bundle and
/// attach the [LaratikTokens] extension so widgets can read tokens
/// from `context.laratik`. This is the replacement for the bare
/// `buildTheme(DesignTokens.forBrightness(...))` call in [MaterialApp].
ThemeData buildAppTheme(DesignTokens tokens) {
  return buildTheme(tokens).copyWith(
    extensions: <ThemeExtension<dynamic>>[LaratikTokens(tokens: tokens)],
  );
}
