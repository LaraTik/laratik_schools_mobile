import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';
import '../ui/app_theme.dart';
import '../ui/design_tokens.dart';
import 'bootstrap.dart';

/// Root widget. Owns the MaterialApp + theme + locale + router; the rest of the
/// composition is in `bootstrap.dart` and the per-feature packages.
class LaratikSchoolsApp extends StatelessWidget {
  const LaratikSchoolsApp({required this.deps, super.key});

  final AppDependencies deps;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // The localized title is resolved at runtime via the
      // generated `AppLocalizations.onTitle` callback. The
      // fallback keeps the splash loading state readable when
      // the localizations aren't ready yet.
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(DesignTokens.forBrightness(Brightness.light)),
      darkTheme: buildAppTheme(DesignTokens.forBrightness(Brightness.dark)),
      themeMode: ThemeMode.system,
      // English + Arabic. The `app_localizations` package is
      // generated from the ARB files in `lib/l10n/` via
      // `flutter gen-l10n`; `flutter pub get` regenerates it on
      // every pub change. The device picks a locale from
      // `supportedLocales` via the standard `LocaleListResolution`.
      // When the user's device locale is anything other than
      // `en` or `ar` we fall through to `en` (the first entry is
      // the default per the Flutter resolution algorithm).
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: deps.router,
    );
  }
}
