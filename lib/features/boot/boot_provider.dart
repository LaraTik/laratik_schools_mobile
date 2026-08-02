/// Boot context — the single source of truth for "who is the user
/// and what can they do?".
///
/// The [BootContext] is fetched exactly once per app session (splash)
/// and then read by every role-aware surface. The previous design
/// passed it as a callback argument into the router, which meant
/// feature screens couldn't see it without plumbing it through
/// every constructor. This provider fixes that: the splash screen
/// pushes the value into [bootContextProvider], and the rest of the
/// app reads it.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'boot_context.dart';

/// The active [BootContext], or `null` while the splash is fetching
/// it (or after a failed fetch).
final bootContextProvider = NotifierProvider<BootContextNotifier, BootContext?>(
  BootContextNotifier.new,
);

class BootContextNotifier extends Notifier<BootContext?> {
  @override
  BootContext? build() => null;

  /// Set the active boot context. Called by the splash screen once
  /// the boot pipeline has resolved. Subsequent calls replace the
  /// value (e.g. after a sign-in / sign-out cycle).
  void set(BootContext? value) {
    state = value;
  }

  /// Convenience: clear the context (used on sign-out).
  void clear() {
    state = null;
  }
}

/// Common role identifiers used by the permission context. The server
/// is the source of truth for the full set; this enum is a typed
/// guard for the values the mobile cares about.
enum LaratikRole {
  student('Student'),
  teacher('Teacher'),
  guardian('Guardian'),
  registrar('Registrar'),
  schoolAdmin('School Admin'),
  operator('Operator'),
  unknown('');

  const LaratikRole(this.wire);
  final String wire;

  static LaratikRole fromWire(String? value) {
    if (value == null) return LaratikRole.unknown;
    for (final r in LaratikRole.values) {
      if (r == LaratikRole.unknown) continue;
      if (r.wire.toLowerCase() == value.toLowerCase()) return r;
    }
    return LaratikRole.unknown;
  }
}

/// Read the active [BootContext] and return the typed
/// [LaratikRole] for [BootContext.primaryRole]. Returns
/// [LaratikRole.unknown] if the boot context is not yet loaded
/// (splash still fetching) or if the server returned an empty role
/// for this user.
LaratikRole activeRole(WidgetRef ref) {
  final ctx = ref.watch(bootContextProvider);
  return LaratikRole.fromWire(ctx?.primaryRole);
}

/// Read the active [BootContext] and return the full [Set] of roles.
/// Empty if the boot context is not yet loaded.
Set<LaratikRole> activeRoles(WidgetRef ref) {
  final ctx = ref.watch(bootContextProvider);
  return (ctx?.roles ?? const <String>[])
      .map(LaratikRole.fromWire)
      .where((r) => r != LaratikRole.unknown)
      .toSet();
}

/// Capability gate — `true` only when the server marked the capability
/// as enabled for the current user. Defaults to `false` while the
/// boot context is still loading.
bool hasCapability(WidgetRef ref, String capability) {
  final ctx = ref.read(bootContextProvider);
  if (ctx == null) return false;
  return ctx.hasCapability(capability);
}
