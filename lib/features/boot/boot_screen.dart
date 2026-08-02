import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../core/result.dart';
import '../../ui/app_theme.dart';
import '../../ui/design_tokens.dart';
import 'boot_context.dart';
import 'boot_provider.dart';
import 'boot_service.dart';

/// Splash screen. Drives the boot pipeline and reports its outcome via the
/// supplied callbacks. The router reacts to the outcome; this widget is
/// purely a status surface.
class BootScreen extends ConsumerStatefulWidget {
  const BootScreen({
    required this.deps,
    required this.onReady,
    required this.onError,
    super.key,
  });

  final AppDependencies deps;
  final ValueChanged<BootContext> onReady;
  final ValueChanged<BootFailure> onError;

  @override
  ConsumerState<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends ConsumerState<BootScreen> {
  late final BootService _service = BootService(
    api: widget.deps.api,
    clock: widget.deps.clock,
    logger: widget.deps.logger,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final result = await _service.fetch();
    if (!mounted) return;
    switch (result) {
      case Ok(value: final ctx):
        // Publish the context before calling onReady so the shell
        // and the first frame of the dashboard already see it.
        ref.read(bootContextProvider.notifier).set(ctx);
        widget.onReady(ctx);
      case Err(:final error):
        // Clear any stale value before the router redirects to the
        // error state.
        ref.read(bootContextProvider.notifier).clear();
        widget.onError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Laratik Schools',
              style: tokens.typography.headlineLarge.copyWith(
                color: tokens.text.primary,
              ),
            ),
            SizedBox(height: tokens.space.lg),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: tokens.brand.primary,
                strokeWidth: 2.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
