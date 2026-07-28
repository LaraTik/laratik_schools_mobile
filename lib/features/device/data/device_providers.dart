import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import '../../people/data/person_providers.dart';
import 'device_service.dart';

final deviceServiceProvider = Provider<DeviceService>((ref) {
  return DeviceService(api: ref.watch(apiClientProvider));
});

final versionPolicyProvider =
    FutureProvider.autoDispose<Result<VersionPolicy, PersonFailure>>((ref) async {
  final service = ref.watch(deviceServiceProvider);
  return service.fetchVersionPolicy();
});
