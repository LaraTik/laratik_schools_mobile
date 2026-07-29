/// Laratik Schools Mobile — application entry point.
///
/// This file is intentionally minimal: it resolves the active environment
/// config (see `lib/config/`), constructs the app composition root, and
/// hands control to the Flutter run loop. All real work happens in the
/// `app/` and `config/` packages.
///
/// To run against a different environment, pass `--dart-define`:
///   flutter run --dart-define=APP_FLAVOR=dev
///   flutter run --dart-define=APP_FLAVOR=local
///   flutter run --dart-define=APP_FLAVOR=qa
///   flutter run --dart-define=APP_FLAVOR=prod
/// (defaults to `dev` when omitted).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'config/flavor_loader.dart';

Future<void> main() async {
  // Resolve the active environment config first so bootstrap, logging, and
  // the Riverpod graph can all see the same baseUrl / OAuth client / app
  // name. FlavorLoader reads --dart-define=APP_FLAVOR=… at compile time.
  final config = FlavorLoader.load();

  // Surface build-time exceptions to the log so the cryptic
  // "Something went wrong" red/grey panel can be diagnosed from
  // `adb logcat`. The default ErrorWidget swallows the cause.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    return Container(
      color: const Color(0xFFB00020),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Text(
        'Build failed: ${details.exceptionAsString()}',
        // ignore: deprecated_member_use
        style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  };

  // Composition root: build the immutable AppDependencies and pass them down.
  // No business logic lives in main(); the bootstrap is testable in isolation.
  WidgetsFlutterBinding.ensureInitialized();
  final deps = await bootstrap(config: config);

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
