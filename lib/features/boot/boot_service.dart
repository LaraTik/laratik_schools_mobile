import 'package:flutter/foundation.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../../core/clock.dart';
import '../../core/logging.dart';
import '../../core/result.dart';
import 'boot_context.dart';
import 'package:meta/meta.dart';

/// Fetches and caches the role-aware boot context.
///
/// Two server calls in parallel (boot + permission), then a single
/// [BootContext] value the shell renderer can consume. Pure: no globals,
/// takes the API client and clock by constructor.
class BootService {
  BootService({
    required LaratikSchoolsApiClient api,
    required Clock clock,
    required RedactingLogger logger,
  })  : _api = api,
        _clock = clock,
        _logger = logger;

  final LaratikSchoolsApiClient _api;
  final Clock _clock;
  final RedactingLogger _logger;

  BootContext? _cached;

  /// The most recent successful [BootContext], or `null` if none.
  BootContext? get cached => _cached;

  /// Run the boot pipeline. Returns a typed [Result] so the splash screen
  /// can switch on success/failure without throwing.
  Future<Result<BootContext, BootFailure>> fetch() async {
    try {
      final bootFuture = _api.getBootContext();
      final permissionFuture = _api.getPermissionContext();
      final bootResponse = await bootFuture;
      final permissionResponse = await permissionFuture;

      final bootData = bootResponse.data;
      final permissionData = permissionResponse.data;

      if (bootResponse.error != null) {
        return Err(error: _failureFromApi(bootResponse.error!, 'boot'));
      }
      if (permissionResponse.error != null) {
        return Err(error: _failureFromApi(permissionResponse.error!, 'permission'));
      }
      if (bootData == null || permissionData == null) {
        return const Err(error: BootFailure(
          code: 'EMPTY_RESPONSE',
          message: 'Boot or permission response had no data.',
        ));
      }

      final context = BootContext.fromBootAndPermission(
        boot: bootData,
        permission: permissionData,
        fetchedAt: _clock.nowUtc(),
      );
      _cached = context;
      _logger.logInfo('boot.fetched', fields: {
        'app': context.app,
        'product': context.productName,
        'version': context.version,
        'role': context.primaryRole ?? 'unknown',
        'roles_count': context.roles.length,
        'capabilities_count': context.capabilities.length,
      });
      return Ok(value: context);
    } on Exception catch (e, st) {
      _logger.logTransportFailure(
        method: 'laratik.boot',
        attempt: 1,
        reason: 'exception',
        error: e,
        stack: st,
      );
      return Err(error: BootFailure(
        code: 'EXCEPTION',
        message: e.toString(),
      ));
    }
  }

  BootFailure _failureFromApi(ApiError error, String phase) {
    return BootFailure(
      code: error.code,
      message: error.message,
      fieldErrors: error.fieldErrors,
      phase: phase,
    );
  }
}

/// Strongly-typed failure for the boot pipeline.
@immutable
class BootFailure implements Exception {
  const BootFailure({
    required this.code,
    required this.message,
    this.fieldErrors = const {},
    this.phase,
  });

  final String code;
  final String message;
  final Map<String, List<String>> fieldErrors;
  final String? phase;

  @override
  String toString() => 'BootFailure($code @ $phase): $message';
}
