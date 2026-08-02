import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import 'staff_form_payload.dart';
import 'staff_member.dart';
import 'package:meta/meta.dart';

@immutable
class StaffPage {
  const StaffPage({required this.staff, this.nextCursor});

  final List<StaffMember> staff;
  final String? nextCursor;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}

@immutable
class StaffCreationResult {
  const StaffCreationResult({
    required this.schoolStaff,
    required this.staffName,
    required this.staffRole,
    required this.status,
    required this.erpnextEmployee,
    required this.warnings,
  });

  final String schoolStaff;
  final String staffName;
  final String? staffRole;
  final String status;
  final String? erpnextEmployee;
  final List<String> warnings;
}

@immutable
class StaffProfile {
  const StaffProfile({
    required this.member,
    required this.summary,
    required this.raw,
  });

  final StaffMember member;
  final JsonMap summary;
  final JsonMap raw;
}

class StaffRepository {
  StaffRepository({required LaratikSchoolsApiClient api, Uuid? uuid})
      : _api = api,
        _uuid = uuid ?? const Uuid();

  final LaratikSchoolsApiClient _api;
  final Uuid _uuid;

  Future<Result<JsonMap, PersonFailure>> fetchSetupContext() async {
    try {
      final response = await _api.getStaffSetupContext();
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(error: _failureFromApi(response.error));
      }
      return Ok(value: <String, Object?>{
        'defaults': data.defaults ?? const <String, Object?>{},
        'doctype': data.doctype ?? 'School Staff',
        'feature': data.feature ?? 'staff',
        'native_links': data.nativeLinks ?? const <String, Object?>{},
        'read_roles': data.readRoles ?? const <String>[],
        'required_roles': data.requiredRoles ?? const <String>[],
      });
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<StaffPage, PersonFailure>> listStaff({
    String? cursor,
    int? limit,
    String? search,
    String? staffRole,
    String? branchId,
  }) async {
    try {
      final response = await _api.getSchoolStaff(
        cursor: cursor,
        limit: limit,
      );
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(error: _failureFromApi(response.error));
      }
      final rows = data.staff ?? const <JsonMap>[];
      final staff = rows
          .where((row) => _matchesFilters(row, search, staffRole, branchId))
          .map(StaffMember.fromJson)
          .toList(growable: false);
      return Ok(
          value: StaffPage(
        staff: staff,
        nextCursor: _nextCursorFromResponse(response, rows.length),
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<StaffProfile, PersonFailure>> fetchProfile(
    String staffId,
  ) async {
    try {
      final response = await _api.getSchoolStaff(
        cursor: null,
        limit: 1,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      final rows = data?.staff ?? const <JsonMap>[];
      final match = rows.firstWhere(
        (row) => (row['name'] ?? '').toString() == staffId,
        orElse: () => <String, Object?>{'name': staffId},
      );
      return Ok(
          value: StaffProfile(
        member: StaffMember.fromJson(match),
        summary: const <String, Object?>{},
        raw: <String, Object?>{'staff': staffId},
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<StaffCreationResult, PersonFailure>> createStaff(
    StaffFormPayload payload,
  ) async {
    try {
      final idempotencyKey = _uuid.v4();
      final response = await _api.createSchoolStaff(
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
          message: 'The server returned no data for the new staff member.',
        ));
      }
      return Ok(
          value: StaffCreationResult(
        schoolStaff: data.schoolStaff ?? '',
        staffName: data.staffName ?? '',
        staffRole: data.staffRole,
        status: data.status ?? 'Active',
        erpnextEmployee: data.erpnextEmployee,
        warnings: response.warnings
            .map((w) => w?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList(growable: false),
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  bool _matchesFilters(
    JsonMap row,
    String? search,
    String? staffRole,
    String? branchId,
  ) {
    if (staffRole != null && staffRole.isNotEmpty) {
      final rowRole = row['staff_role'] ?? row['role'];
      if (rowRole is String && rowRole != staffRole) return false;
      if (rowRole is! String) return false;
    }
    if (branchId != null && branchId.isNotEmpty) {
      final rowBranch = row['branch'];
      if (rowBranch is String && rowBranch != branchId) return false;
      if (rowBranch is! String) return false;
    }
    if (search != null && search.isNotEmpty) {
      final needle = search.toLowerCase();
      final hay = <String>[
        (row['first_name'] ?? '').toString(),
        (row['last_name'] ?? '').toString(),
        (row['full_name'] ?? '').toString(),
        (row['staff_name'] ?? '').toString(),
        (row['staff_role'] ?? '').toString(),
      ].join(' ').toLowerCase();
      if (!hay.contains(needle)) return false;
    }
    return true;
  }

  String? _nextCursorFromResponse(
    ApiEnvelope<GetSchoolStaffData> response,
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
