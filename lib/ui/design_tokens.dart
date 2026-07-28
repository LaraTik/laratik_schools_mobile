import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Design tokens for the Laratik Schools mobile app.
///
/// The tokens are the single source of truth for spacing, type, color, and
/// motion. Feature code MUST read tokens from here — never hand-roll spacing
/// or copy color hex into a widget.
///
/// Design direction (see `docs/adr/0001-design-system.md`):
///   * Operator-first: dense enough for daily work, calm enough to scan.
///   * Material 3, calm professional palette, both light and dark themes.
///   * English-first copy, RTL-safe layout (logical edges, no fixed LTR
///     directionality, type scale mirrored in Arabic locale).
///   * 44x44px minimum touch targets; 8px spacing scale; 16px body.
@immutable
class DesignTokens {
  const DesignTokens({
    required this.brightness,
    required this.brand,
    required this.surface,
    required this.text,
    required this.status,
    required this.space,
    required this.radius,
    required this.elevations,
    required this.motion,
    required this.typography,
    required this.touch,
  });

  /// Picks the right token set for the current platform brightness.
  factory DesignTokens.forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? darkTokens : lightTokens;
  }

  final Brightness brightness;
  final BrandPalette brand;
  final SurfacePalette surface;
  final TextPalette text;
  final StatusPalette status;
  final SpaceScale space;
  final RadiusScale radius;
  final ElevationTokens elevations;
  final MotionTokens motion;
  final TypographyTokens typography;

  /// Minimum 44x44pt touch target — required by the Laratik UI rules.
  final TouchTokens touch;
}

// ============================================================================
// COLOR
// ============================================================================

@immutable
class BrandPalette {
  const BrandPalette({
    required this.primary,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.secondaryContainer,
  });

  /// Indigo-blue, used for primary actions and active state.
  final Color primary;

  /// Tinted primary, used for chip backgrounds and subtle accents.
  final Color primaryContainer;

  final Color onPrimary;
  final Color onPrimaryContainer;

  /// Teal accent, used sparingly for highlights and live indicators.
  final Color secondary;
  final Color secondaryContainer;
}

@immutable
class SurfacePalette {
  const SurfacePalette({
    required this.canvas,
    required this.surface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.outline,
    required this.outlineVariant,
    required this.scrim,
  });

  /// Page background.
  final Color canvas;

  /// Default surface for cards and panels.
  final Color surface;

  /// Lifted surface used for menus and popovers above [surface].
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;

  /// 1px hairlines, dividers, control borders.
  final Color outline;

  /// Lighter divider color used inside dense tables.
  final Color outlineVariant;

  final Color scrim;
}

@immutable
class TextPalette {
  const TextPalette({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.disabled,
    required this.inverse,
    required this.onStatus,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color disabled;
  final Color inverse;

  /// Text color used on top of status backgrounds (success/warn/error).
  final Color onStatus;
}

@immutable
class StatusPalette {
  const StatusPalette({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;
}

// ============================================================================
// SPACING — 8px base scale, 4px half-step for dense UI.
// ============================================================================

@immutable
class SpaceScale {
  const SpaceScale({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
  });

  /// 4px — half-step for dense tables.
  final double xxs;

  /// 8px — base step.
  final double xs;

  /// 12px.
  final double sm;

  /// 16px — default page gutter.
  final double md;

  /// 24px — section gap.
  final double lg;

  /// 32px — major section break.
  final double xl;

  /// 48px — page header.
  final double xxl;

  /// 64px — top-level page margin.
  final double xxxl;

  static const SpaceScale standard = SpaceScale(
    xxs: 4,
    xs: 8,
    sm: 12,
    md: 16,
    lg: 24,
    xl: 32,
    xxl: 48,
    xxxl: 64,
  );
}

// ============================================================================
// RADIUS
// ============================================================================

@immutable
class RadiusScale {
  const RadiusScale({
    required this.none,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.pill,
  });

  final double none;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double pill;

  static const RadiusScale standard = RadiusScale(
    none: 0,
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    pill: 999,
  );
}

// ============================================================================
// ELEVATION
// ============================================================================

@immutable
class ElevationTokens {
  const ElevationTokens({
    required this.level0,
    required this.level1,
    required this.level2,
    required this.level3,
    required this.level4,
  });

  final double level0;
  final double level1;
  final double level2;
  final double level3;
  final double level4;

  static const ElevationTokens standard = ElevationTokens(
    level0: 0,
    level1: 1,
    level2: 3,
    level3: 6,
    level4: 12,
  );
}

// ============================================================================
// MOTION — 150–300ms sweet spot. Stays short for operator tools.
// ============================================================================

@immutable
class MotionTokens {
  const MotionTokens({
    required this.fast,
    required this.normal,
    required this.slow,
    required this.pageTransition,
  });

  final Duration fast; // 150ms — taps, hover.
  final Duration normal; // 220ms — panel/segment transitions.
  final Duration slow; // 300ms — page transitions.
  final Duration pageTransition; // 240ms — go_router default.

  static const MotionTokens standard = MotionTokens(
    fast: Duration(milliseconds: 150),
    normal: Duration(milliseconds: 220),
    slow: Duration(milliseconds: 300),
    pageTransition: Duration(milliseconds: 240),
  );
}

// ============================================================================
// TYPOGRAPHY — 16px body, 1.4 line height, semantic roles.
// ============================================================================

@immutable
class TypographyTokens {
  const TypographyTokens({
    required this.displayLarge,
    required this.displayMedium,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.monoFamily,
  });

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  /// Used for IDs, request IDs, and code-like metadata.
  final String monoFamily;

  /// The canonical type ramp. Sized for operator-first density.
  static TypographyTokens standardOf(Brightness brightness) {
    final base = brightness == Brightness.dark ? 0.95 : 1.0;
    TextStyle s(
      double size, {
      FontWeight weight = FontWeight.w400,
      double height = 1.4,
      double? letterSpacing,
    }) =>
        TextStyle(
          fontSize: size * base,
          fontWeight: weight,
          height: height,
          letterSpacing: letterSpacing,
        );
    return TypographyTokens(
      displayLarge: s(40, weight: FontWeight.w600, height: 1.2, letterSpacing: -0.5),
      displayMedium: s(32, weight: FontWeight.w600, height: 1.2, letterSpacing: -0.25),
      headlineLarge: s(28, weight: FontWeight.w600, height: 1.25),
      headlineMedium: s(24, weight: FontWeight.w600, height: 1.3),
      titleLarge: s(20, weight: FontWeight.w600, height: 1.3),
      titleMedium: s(18, weight: FontWeight.w600, height: 1.35),
      titleSmall: s(16, weight: FontWeight.w600, height: 1.4),
      bodyLarge: s(17, weight: FontWeight.w400, height: 1.45),
      bodyMedium: s(16, weight: FontWeight.w400, height: 1.45),
      bodySmall: s(14, weight: FontWeight.w400, height: 1.45),
      labelLarge: s(15, weight: FontWeight.w500, height: 1.3, letterSpacing: 0.1),
      labelMedium: s(13, weight: FontWeight.w500, height: 1.3, letterSpacing: 0.2),
      labelSmall: s(12, weight: FontWeight.w500, height: 1.3, letterSpacing: 0.3),
      monoFamily: 'monospace',
    );
  }
}

// ============================================================================
// TOUCH — 44x44 minimum, per Laratik UI rules.
// ============================================================================

@immutable
class TouchTokens {
  const TouchTokens({
    required this.minTarget,
    required this.comfortableTarget,
    required this.minSpacing,
  });

  /// iOS HIG and Material guidance: 44pt minimum. Laratik UI rules adopt 48dp
  /// on Android for parity with Material 3; 44 is the strict minimum.
  final double minTarget;

  /// 48pt — preferred target for primary actions.
  final double comfortableTarget;

  /// 8pt minimum spacing between adjacent touch targets.
  final double minSpacing;

  static const TouchTokens standard = TouchTokens(
    minTarget: 44,
    comfortableTarget: 48,
    minSpacing: 8,
  );
}

// ============================================================================
// TOKEN DEFINITIONS — LIGHT & DARK
// ============================================================================

// Material 3 TypeTheme needs const typography values; we keep two
// token instances and let the theme builder pick one at runtime.
final TypographyTokens _lightTypography = TypographyTokens.standardOf(Brightness.light);
final TypographyTokens _darkTypography = TypographyTokens.standardOf(Brightness.dark);

final DesignTokens lightTokens = DesignTokens(
  brightness: Brightness.light,
  brand: BrandPalette(
    primary: Color(0xFF1F4D8C), // calm indigo-blue
    primaryContainer: Color(0xFFDCE6F5),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryContainer: Color(0xFF0B1E3A),
    secondary: Color(0xFF1E7A6E), // teal accent
    secondaryContainer: Color(0xFFCFE9E4),
  ),
  surface: SurfacePalette(
    canvas: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF1F3F6),
    surfaceContainer: Color(0xFFEAECF0),
    surfaceContainerHigh: Color(0xFFE2E5EA),
    surfaceContainerHighest: Color(0xFFD9DDE3),
    outline: Color(0xFFBFC4CC),
    outlineVariant: Color(0xFFE2E5EA),
    scrim: Color(0x66000000),
  ),
  text: TextPalette(
    primary: Color(0xFF101828),
    secondary: Color(0xFF475467),
    tertiary: Color(0xFF667085),
    disabled: Color(0xFF98A2B3),
    inverse: Color(0xFFFFFFFF),
    onStatus: Color(0xFFFFFFFF),
  ),
  status: StatusPalette(
    success: Color(0xFF15803D),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFDCFCE7),
    warning: Color(0xFFB45309),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFEF3C7),
    error: Color(0xFFB42318),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEE4E2),
    info: Color(0xFF1F4D8C),
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFFDCE6F5),
  ),
  space: SpaceScale.standard,
  radius: RadiusScale.standard,
  elevations: ElevationTokens.standard,
  motion: MotionTokens.standard,
  typography: _lightTypography,
  touch: TouchTokens.standard,
);

final DesignTokens darkTokens = DesignTokens(
  brightness: Brightness.dark,
  brand: BrandPalette(
    primary: Color(0xFF8AB4F8), // lighter indigo for dark surfaces
    primaryContainer: Color(0xFF1F3A66),
    onPrimary: Color(0xFF0B1E3A),
    onPrimaryContainer: Color(0xFFDCE6F5),
    secondary: Color(0xFF6BC2B3),
    secondaryContainer: Color(0xFF1E4A43),
  ),
  surface: SurfacePalette(
    canvas: Color(0xFF0B0F1A),
    surface: Color(0xFF111726),
    surfaceContainerLowest: Color(0xFF0B0F1A),
    surfaceContainerLow: Color(0xFF161D2F),
    surfaceContainer: Color(0xFF1B2238),
    surfaceContainerHigh: Color(0xFF222B45),
    surfaceContainerHighest: Color(0xFF2A3352),
    outline: Color(0xFF3D4663),
    outlineVariant: Color(0xFF222B45),
    scrim: Color(0x88000000),
  ),
  text: TextPalette(
    primary: Color(0xFFF5F7FA),
    secondary: Color(0xFFB8C0CF),
    tertiary: Color(0xFF8A93A6),
    disabled: Color(0xFF56607A),
    inverse: Color(0xFF101828),
    onStatus: Color(0xFF0B0F1A),
  ),
  status: StatusPalette(
    success: Color(0xFF4ADE80),
    onSuccess: Color(0xFF052E16),
    successContainer: Color(0xFF14532D),
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF451A03),
    warningContainer: Color(0xFF78350F),
    error: Color(0xFFF87171),
    onError: Color(0xFF410E0B),
    errorContainer: Color(0xFF7F1D1D),
    info: Color(0xFF8AB4F8),
    onInfo: Color(0xFF0B1E3A),
    infoContainer: Color(0xFF1F3A66),
  ),
  space: SpaceScale.standard,
  radius: RadiusScale.standard,
  elevations: ElevationTokens.standard,
  motion: MotionTokens.standard,
  typography: _darkTypography,
  touch: TouchTokens.standard,
);

/// Build a Material 3 [ThemeData] from a [DesignTokens] bundle.
ThemeData buildTheme(DesignTokens tokens) {
  final scheme = ColorScheme(
    brightness: tokens.brightness,
    primary: tokens.brand.primary,
    onPrimary: tokens.brand.onPrimary,
    primaryContainer: tokens.brand.primaryContainer,
    onPrimaryContainer: tokens.brand.onPrimaryContainer,
    secondary: tokens.brand.secondary,
    onSecondary: tokens.text.inverse,
    secondaryContainer: tokens.brand.secondaryContainer,
    onSecondaryContainer: tokens.brand.onPrimaryContainer,
    error: tokens.status.error,
    onError: tokens.status.onError,
    errorContainer: tokens.status.errorContainer,
    onErrorContainer: tokens.status.onError,
    surface: tokens.surface.surface,
    onSurface: tokens.text.primary,
    surfaceContainerLowest: tokens.surface.surfaceContainerLowest,
    surfaceContainerLow: tokens.surface.surfaceContainerLow,
    surfaceContainer: tokens.surface.surfaceContainer,
    surfaceContainerHigh: tokens.surface.surfaceContainerHigh,
    surfaceContainerHighest: tokens.surface.surfaceContainerHighest,
    onSurfaceVariant: tokens.text.secondary,
    outline: tokens.surface.outline,
    outlineVariant: tokens.surface.outlineVariant,
    shadow: Colors.black,
    scrim: tokens.surface.scrim,
    inverseSurface: tokens.surface.surfaceContainerHigh,
    onInverseSurface: tokens.text.primary,
    inversePrimary: tokens.brand.primary,
  );

  final t = tokens.typography;
  final textTheme = TextTheme(
    displayLarge: t.displayLarge.copyWith(color: tokens.text.primary),
    displayMedium: t.displayMedium.copyWith(color: tokens.text.primary),
    headlineLarge: t.headlineLarge.copyWith(color: tokens.text.primary),
    headlineMedium: t.headlineMedium.copyWith(color: tokens.text.primary),
    titleLarge: t.titleLarge.copyWith(color: tokens.text.primary),
    titleMedium: t.titleMedium.copyWith(color: tokens.text.primary),
    titleSmall: t.titleSmall.copyWith(color: tokens.text.primary),
    bodyLarge: t.bodyLarge.copyWith(color: tokens.text.primary),
    bodyMedium: t.bodyMedium.copyWith(color: tokens.text.primary),
    bodySmall: t.bodySmall.copyWith(color: tokens.text.secondary),
    labelLarge: t.labelLarge.copyWith(color: tokens.text.primary),
    labelMedium: t.labelMedium.copyWith(color: tokens.text.secondary),
    labelSmall: t.labelSmall.copyWith(color: tokens.text.tertiary),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: tokens.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: tokens.surface.canvas,
    textTheme: textTheme,
    visualDensity: VisualDensity.standard,
    splashFactory: InkRipple.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
      },
    ),
  );
}
