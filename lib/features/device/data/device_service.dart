import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';

/// The v1 `get_school_mobile_version_policy` envelope, narrowed to the
/// fields the mobile client needs. The forward-compatible `raw` map on
/// the SDK data class is preserved on the wire; this model picks out
/// the well-known fields and folds the rest into [VersionPolicy]'s
/// derived helpers.
@immutable
class VersionPolicy {
  const VersionPolicy({
    required this.minimumVersion,
    required this.recommendedVersion,
    required this.action,
    required this.rolloutEligible,
    required this.rolloutPercent,
    this.storeUrl,
  });

  factory VersionPolicy.fromData(GetSchoolMobileVersionPolicyData data) {
    return VersionPolicy(
      minimumVersion: data.minimumVersion ?? '',
      recommendedVersion: data.recommendedVersion ?? '',
      action: data.action,
      rolloutEligible: data.rolloutEligible,
      rolloutPercent: data.rolloutPercent,
      storeUrl: data.storeUrl,
    );
  }

  /// Lowest app version still allowed to call the API. Empty string
  /// means "no minimum enforced".
  final String minimumVersion;

  /// Soft-target version. The store card points here when an update
  /// is available.
  final String recommendedVersion;

  /// `soft` | `force` | `none` — drives the [isForced] flag and the
  /// update card copy.
  final String action;

  /// True if the current installation is in the rollout window.
  final bool rolloutEligible;

  /// 0..100 percent of the user base currently included.
  final int rolloutPercent;

  /// App-store / play-store deep link for the latest published build.
  final String? storeUrl;

  bool get isForced => action.toLowerCase() == 'force';
}

@immutable
class DeviceRegistrationResult {
  const DeviceRegistrationResult({
    required this.device,
    required this.status,
    this.pushToken,
  });
  final String device;
  final String status;
  final String? pushToken;
}

class DeviceService {
  DeviceService({required LaratikSchoolsApiClient api}) : _api = api;

  final LaratikSchoolsApiClient _api;

  Future<Result<VersionPolicy, PersonFailure>> fetchVersionPolicy({
    String? platform,
    String? releaseChannel,
    String? installedVersion,
    String? installationId,
  }) async {
    try {
      final response = await _api.getSchoolMobileVersionPolicy(
        platform: platform,
        releaseChannel: releaseChannel,
        installedVersion: installedVersion,
        installationId: installationId,
      );
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(error: _failureFromApi(response.error));
      }
      return Ok(value: VersionPolicy.fromData(data));
    } on Exception catch (e) {
      return Err(
        error: PersonFailure(code: 'EXCEPTION', message: e.toString()),
      );
    }
  }

  Future<Result<DeviceRegistrationResult, PersonFailure>> register({
    required String installationId,
    required String appVersion,
    required String platform,
    String? pushToken,
    String? releaseChannel,
  }) async {
    try {
      // The v1 contract takes a `RegisterSchoolMobileDevicePayload`
      // that requires a `pushToken` and a `pushTokenFingerprint`.
      // The mobile client never has the raw push token at this
      // layer — the system push plugin holds it and surfaces a
      // fingerprint via the OS. We pass an empty placeholder when
      // nothing is available yet and let the server reconcile when
      // the bootstrap completes.
      final response = await _api.registerSchoolMobileDevice(
        payload: RegisterSchoolMobileDevicePayload(
          appVersion: appVersion,
          installationId: installationId,
          platform: platform,
          pushToken: pushToken ?? '',
          releaseChannel: releaseChannel,
        ),
        idempotencyKey: installationId,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: PersonFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no data for the device registration.',
          ),
        );
      }
      return Ok(
        value: DeviceRegistrationResult(
          device: data.device,
          status: data.status,
          pushToken: data.pushToken,
        ),
      );
    } on Exception catch (e) {
      return Err(
        error: PersonFailure(code: 'EXCEPTION', message: e.toString()),
      );
    }
  }

  Future<Result<bool, PersonFailure>> revoke(String installationId) async {
    try {
      final response = await _api.revokeSchoolMobileDevice(
        payload:
            RevokeSchoolMobileDevicePayload(installationId: installationId),
        idempotencyKey: installationId,
      );
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      return const Ok(value: true);
    } on Exception catch (e) {
      return Err(
        error: PersonFailure(code: 'EXCEPTION', message: e.toString()),
      );
    }
  }

  PersonFailure _failureFromApi(ApiError? error) {
    if (error == null) {
      return const PersonFailure(
        code: 'EMPTY_RESPONSE',
        message: 'The server returned no data.',
      );
    }
    return PersonFailure(
      code: error.code,
      message: error.message,
      fieldErrors: error.fieldErrors,
    );
  }
}
