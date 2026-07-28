import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../../core/result.dart';
import '../people/data/person_failure.dart';

@immutable
class VersionPolicy {
  const VersionPolicy({
    required this.minimumVersion,
    required this.recommendedVersion,
    required this.updateMode,
    required this.storeUrl,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.rolloutPercent,
    this.releaseChannel,
  });

  factory VersionPolicy.fromJson(JsonMap json) {
    return VersionPolicy(
      minimumVersion: (json['minimum_version'] ?? '').toString(),
      recommendedVersion: (json['recommended_version'] ?? '').toString(),
      updateMode: (json['update_mode'] ?? 'Soft').toString(),
      storeUrl: (json['store_url'] ?? '').toString(),
      effectiveFrom: (json['effective_from'] ?? '').toString(),
      effectiveTo: (json['effective_to'] ?? '').toString(),
      rolloutPercent: int.tryParse('${json['rollout_percent'] ?? 0}') ?? 0,
      releaseChannel: json['release_channel']?.toString(),
    );
  }

  final String minimumVersion;
  final String recommendedVersion;
  final String updateMode;
  final String storeUrl;
  final String effectiveFrom;
  final String effectiveTo;
  final int rolloutPercent;
  final String? releaseChannel;

  bool get isForced => updateMode.toLowerCase() == 'force';
}

@immutable
class DeviceRegistrationResult {
  const DeviceRegistrationResult({
    required this.installationId,
    required this.appVersion,
    required this.platform,
    required this.status,
  });
  final String installationId;
  final String appVersion;
  final String platform;
  final String status;
}

class DeviceService {
  DeviceService({required LaratikSchoolsApiClient api}) : _api = api;

  final LaratikSchoolsApiClient _api;

  Future<Result<VersionPolicy, PersonFailure>> fetchVersionPolicy() async {
    try {
      final response = await _api.getSchoolMobileVersionPolicy();
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(_failureFromApi(response.error, data));
      }
      return Ok(VersionPolicy(
        minimumVersion: data.minimumVersion ?? '',
        recommendedVersion: data.recommendedVersion ?? '',
        updateMode: data.updateMode ?? 'Soft',
        storeUrl: data.storeUrl ?? '',
        effectiveFrom: data.effectiveFrom ?? '',
        effectiveTo: data.effectiveTo ?? '',
        rolloutPercent: data.rolloutPercent ?? 0,
        releaseChannel: data.releaseChannel,
      ));
    } on Exception catch (e) {
      return Err(PersonFailure(code: 'EXCEPTION', message: e.toString()));
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
      final response = await _api.registerSchoolMobileDevice(
        payload: <String, Object?>{
          'installation_id': installationId,
          'app_version': appVersion,
          'platform': platform,
          if (pushToken != null && pushToken.isNotEmpty) 'push_token': pushToken,
          if (releaseChannel != null && releaseChannel.isNotEmpty)
            'release_channel': releaseChannel,
        },
        idempotencyKey: installationId,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(_failureFromApi(response.error, data));
      }
      if (data == null) {
        return const Err(PersonFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no data for the device registration.',
        ));
      }
      return Ok(DeviceRegistrationResult(
        installationId: data.installationId ?? installationId,
        appVersion: data.appVersion ?? appVersion,
        platform: data.platform ?? platform,
        status: data.status ?? 'Active',
      ));
    } on Exception catch (e) {
      return Err(PersonFailure(code: 'EXCEPTION', message: e.toString()));
    }
  }

  Future<Result<bool, PersonFailure>> revoke(String installationId) async {
    try {
      final response = await _api.revokeSchoolMobileDevice(
        installationId: installationId,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(_failureFromApi(response.error, data));
      }
      return Ok((data?.status ?? 'Revoked').toLowerCase() != 'active');
    } on Exception catch (e) {
      return Err(PersonFailure(code: 'EXCEPTION', message: e.toString()));
    }
  }

  PersonFailure _failureFromApi(ApiError? error, JsonMap? data) {
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
