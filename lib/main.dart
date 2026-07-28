/// Laratik Schools Mobile — application entry point.
///
/// This file is intentionally minimal: it constructs the app composition root
/// (dependency wiring, logging, theming, locale, routing) and hands control to
/// the Flutter run loop. All real work happens in the `app/` package.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  // Composition root: build the immutable AppDependencies and pass them down.
  // No business logic lives in main(); the bootstrap is testable in isolation.
  WidgetsFlutterBinding.ensureInitialized();
  final deps = await bootstrap();

  // Hand the typed API client + auth pieces to the Riverpod graph so
  // feature providers and the login screen can resolve the same objects
  // the bootstrap owns.
  runApp(
    ProviderScope(
      overrides: deps.riverpodOverrides,
      child: LaratikSchoolsApp(deps: deps),
    ),
  );
}
