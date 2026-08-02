import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import 'guardian.dart';
import 'guardian_form_payload.dart';
import 'package:meta/meta.dart';

@immutable
class GuardianPage {
  const GuardianPage({required this.guardians, this.nextCursor});

  final List<Guardian> guardians;
  final String? nextCursor;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}

@immutable
class GuardianCreationResult {
  const GuardianCreationResult({
    required this.schoolGuardian,
    required this.guardianName,
    required this.status,
    required this.warnings,
  });

  final String schoolGuardian;
  final String guardianName;
  final String status;
  final List<String> warnings;
}

@immutable
class GuardianProfile {
  const GuardianProfile({
    required this.guardian,
    required this.summary,
    required this.raw,
  });

  final Guardian guardian;
  final JsonMap summary;
  final JsonMap raw;
}

class GuardianRepository {
  GuardianRepository({required LaratikSchoolsApiClient api, Uuid? uuid})
      : _api = api,
        _uuid = uuid ?? const Uuid();

  final LaratikSchoolsApiClient _api;
  final Uuid _uuid;

  Future<Result<JsonMap, PersonFailure>> fetchSetupContext() async {
    try {
      final response = await _api.getGuardianSetupContext();
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(error: _failureFromApi(response.error));
      }
      return Ok(value: <String, Object?>{
        'defaults': data.defaults ?? const <String, Object?>{},
        'doctype': data.doctype ?? 'School Guardian',
        'feature': data.feature ?? 'guardians',
        'native_links': data.nativeLinks ?? const <String, Object?>{},
        'read_roles': data.readRoles ?? const <String>[],
        'required_roles': data.requiredRoles ?? const <String>[],
      });
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<GuardianPage, PersonFailure>> listGuardians({
    String? cursor,
    int? limit,
    String? search,
    String? relation,
  }) async {
    try {
      final response = await _api.getSchoolGuardians(
        cursor: cursor,
        limit: limit,
      );
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(error: _failureFromApi(response.error));
      }
      final rows = data.guardians ?? const <JsonMap>[];
      final guardians = rows
          .where((row) => _matchesFilters(row, search, relation))
          .map(Guardian.fromJson)
          .toList(growable: false);
      return Ok(
          value: GuardianPage(
        guardians: guardians,
        nextCursor: _nextCursorFromResponse(response, rows.length),
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<GuardianProfile, PersonFailure>> fetchProfile(
    String guardianId,
  ) async {
    try {
      final response = await _api.getSchoolGuardians(
        cursor: null,
        limit: 1,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      final rows = data?.guardians ?? const <JsonMap>[];
      final match = rows.firstWhere(
        (row) => (row['name'] ?? '').toString() == guardianId,
        orElse: () => <String, Object?>{'name': guardianId},
      );
      return Ok(
          value: GuardianProfile(
        guardian: Guardian.fromJson(match),
        summary: const <String, Object?>{},
        raw: <String, Object?>{'guardian': guardianId},
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<GuardianCreationResult, PersonFailure>> createGuardian(
    GuardianFormPayload payload,
  ) async {
    try {
      final idempotencyKey = _uuid.v4();
      final response = await _api.createSchoolGuardian(
        payload: payload.toJson(),
        idempotencyKey: idempotencyKey,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
            error: PersonFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no data for the new guardian.',
        ));
      }
      return Ok(
          value: GuardianCreationResult(
        schoolGuardian: data.schoolGuardian ?? '',
        guardianName: data.guardianName ?? '',
        status: data.status ?? 'Active',
        warnings: response.warnings
            .map((w) => w?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList(growable: false),
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  bool _matchesFilters(JsonMap row, String? search, String? relation) {
    if (relation != null && relation.isNotEmpty) {
      final rowRel = row['relation'] ?? row['relationship'];
      if (rowRel is String && rowRel != relation) return false;
      if (rowRel is! String) return false;
    }
    if (search != null && search.isNotEmpty) {
      final needle = search.toLowerCase();
      final hay = <String>[
        (row['guardian_name'] ?? '').toString(),
        (row['phone'] ?? '').toString(),
        (row['mobile_no'] ?? '').toString(),
        (row['email'] ?? '').toString(),
      ].join(' ').toLowerCase();
      if (!hay.contains(needle)) return false;
    }
    return true;
  }

  String? _nextCursorFromResponse(
    ApiEnvelope<GetSchoolGuardiansData> response,
    int returnedRowCount,
  ) {
    final raw = response.meta.values;
    for (final key in const ['next_cursor', 'nextCursor', 'cursor']) {
      final v = raw[key];
      if (v is String && v.isNotEmpty) return v;
    }
    if (returnedRowCount == 0) return null;
    return null;
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

  PersonFailure _exceptionFailure(Exception e) {
    return PersonFailure(
      code: 'EXCEPTION',
      message: e.toString(),
    );
  }
}
