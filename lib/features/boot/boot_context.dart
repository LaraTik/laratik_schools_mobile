import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

/// The role-aware, capability-snapshot context the app reads at splash time.
///
/// Built from two backend calls:
///   * `get_school_mobile_boot_context` — app + product + version + feature
///     registry. Cached aggressively because it changes only on release.
///   * `get_school_permission_context` — the current user's roles, primary
///     role, and capability map. Refreshed on sign-in and on demand.
///
/// Feature code reads this value once at boot and re-reads on notify.
class BootContext extends Equatable {
  const BootContext({
    required this.app,
    required this.productName,
    required this.version,
    required this.features,
    required this.primaryRole,
    required this.roles,
    required this.capabilities,
    required this.navigation,
    required this.fetchedAt,
  });

  factory BootContext.fromBootAndPermission({
    required GetBootContextData boot,
    required GetPermissionContextData permission,
    required DateTime fetchedAt,
  }) {
    return BootContext(
      app: boot.app ?? 'mobile',
      productName: boot.productName ?? 'Laratik Schools',
      version: boot.version ?? 'v1',
      features: boot.features ?? const [],
      primaryRole: permission.primaryRole,
      roles: permission.roles ?? const [],
      capabilities: permission.capabilities ?? const {},
      navigation: permission.navigation ?? const [],
      fetchedAt: fetchedAt,
    );
  }

  final String app;
  final String productName;
  final String version;
  final List<JsonMap> features;
  final String? primaryRole;
  final List<String> roles;
  final JsonMap capabilities;
  final List<JsonMap> navigation;
  final DateTime fetchedAt;

  /// True if the user can act in the named role. The permission shape on
  /// the wire is the union of `roles` plus the per-feature `required_roles`
  /// matrices, so this is the simple check for chrome and navigation.
  bool hasRole(String role) => roles.contains(role);

  /// Capability gate — `true` only when the server marked the capability
  /// as enabled for the current user. Feature code uses this to decide
  /// whether to show a surface at all (vs. show-and-error).
  bool hasCapability(String capability) {
    final entry = capabilities[capability];
    if (entry is bool) return entry;
    if (entry is Map && entry['enabled'] is bool) {
      return entry['enabled'] as bool;
    }
    return false;
  }

  /// Top-level navigation surface extracted from the permission context.
  /// The shape is server-driven; the shell renderer interprets it.
  List<JsonMap> get topLevelNavigation => navigation;

  @override
  List<Object?> get props => [
        app,
        productName,
        version,
        features,
        primaryRole,
        roles,
        capabilities,
        navigation,
        fetchedAt,
      ];
}

/// Lifecycle of the boot pipeline. The splash screen drives this state and
/// the router reacts to transitions.
enum BootState {
  /// Boot context has not been fetched yet (cold start).
  initial,

  /// Fetch in flight. The splash shows a stable progress indicator.
  loading,

  /// Boot context loaded; the user is signed in and the shell is ready.
  ready,

  /// Boot failed (network, auth, or version policy). The splash shows the
  /// error and the recovery action.
  error,
}
