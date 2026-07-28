import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../ui/design_tokens.dart';
import 'bootstrap.dart';
import 'router.dart';

/// Root widget. Owns the MaterialApp + theme + locale + router; the rest of the
/// composition is in `bootstrap.dart` and the per-feature packages.
class LaratikSchoolsApp extends StatelessWidget {
  const LaratikSchoolsApp({required this.deps, super.key});

  final AppDependencies deps;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Laratik Schools',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(DesignTokens.forBrightness(Brightness.light)),
      darkTheme: buildTheme(DesignTokens.forBrightness(Brightness.dark)),
      themeMode: ThemeMode.system,
      // English source; Arabic locale is layered in when locale support lands
      // (OpenSpec Phase 1, ui-ux-pro-max design system).
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      routerConfig: deps.router,
    );
  }
}
