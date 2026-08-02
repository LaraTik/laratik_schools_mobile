import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import 'person.dart';
import 'person_failure.dart';
import 'student_form_payload.dart';
import 'package:meta/meta.dart';

/// Paged result of a list call. The cursor is opaque and must be returned
/// verbatim on the next call to keep server-side keyset pagination stable.
@immutable
class PersonPage {
  const PersonPage({required this.people, this.nextCursor});

  final List<Person> people;
  final String? nextCursor;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}

/// Repository over the v1 People contract. Wraps the typed SDK client and
/// converts envelopes into [Result]s with [PersonFailure] on the error
/// branch.
///
/// Phase 1 surface:
///   * list students (keyset pagination, grade + classGroup filter,
///     case-insensitive name search)
///   * student detail (profile + summary)
///   * student setup context (schema + defaults)
///   * create student (form payload + idempotency key)
class PersonRepository {
  PersonRepository({
    required LaratikSchoolsApiClient api,
    Uuid? uuid,
  })  : _api = api,
        _uuid = uuid ?? const Uuid();

  final LaratikSchoolsApiClient _api;
  final Uuid _uuid;

  /// Fetch the schema + defaults that drive the student create form.
  /// Cached by the provider layer; the response is small and changes only
  /// on release.
  Future<Result<JsonMap, PersonFailure>> fetchStudentSetupContext() async {
    try {
      final response = await _api.getStudentSetupContext();
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(error: _failureFromApi(response.error));
      }
      return Ok(value: <String, Object?>{
        'defaults': data.defaults ?? const <String, Object?>{},
        'doctype': data.doctype ?? 'School Student',
        'feature': data.feature ?? 'students',
        'native_links': data.nativeLinks ?? const <String, Object?>{},
        'read_roles': data.readRoles ?? const <String>[],
        'required_roles': data.requiredRoles ?? const <String>[],
      });
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Page through the student list. [limit] is bounded by the server
  /// (MAX_PAGE_SIZE = 100 per the v1 contract). The [search], [gradeId],
  /// and [classGroupId] filters are applied server-side; the [cursor]
  /// from the previous call returns the next page.
  Future<Result<PersonPage, PersonFailure>> listStudents({
    String? cursor,
    int? limit,
    String? search,
    String? gradeId,
    String? classGroupId,
  }) async {
    try {
      final response = await _api.getSchoolStudents(
        cursor: cursor,
        limit: limit,
      );
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(error: _failureFromApi(response.error));
      }
      final rows = data.students ?? const <JsonMap>[];
      final people = rows
          .where((row) => _matchesFilters(row, search, gradeId, classGroupId))
          .map(Person.fromJson)
          .toList(growable: false);
      return Ok(
          value: PersonPage(
        people: people,
        nextCursor: _nextCursorFromResponse(response, rows.length),
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Fetch the full student profile (overview + summary, attendance, grade
  /// records, fee plans, guardians, report cards).
  Future<Result<PersonProfile, PersonFailure>> fetchStudentProfile(
    String studentId,
  ) async {
    try {
      final response = await _api.getSchoolStudentProfile(
        payload: <String, Object?>{'student': studentId},
      );
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(error: _failureFromApi(response.error));
      }
      final student = data.student != null && data.student!.isNotEmpty
          ? data.student
          : studentId;
      return Ok(
          value: PersonProfile(
        person: Person.fromJson(<String, Object?>{'name': student}),
        summary: data.summary ?? const <String, Object?>{},
        attendanceRecordsId: data.attendanceRecords,
        currentEnrollmentId: data.currentEnrollment,
        feePlansId: data.feePlans,
        gradeRecords: data.gradeRecords ?? const <JsonMap>[],
        guardians: data.guardians ?? const <JsonMap>[],
        reportCards: data.reportCards ?? const <JsonMap>[],
        raw: Map<String, Object?>.unmodifiable(<String, Object?>{
          'student': student,
          if (data.summary != null) 'summary': data.summary!,
          if (data.attendanceRecords != null)
            'attendance_records': data.attendanceRecords!,
          if (data.currentEnrollment != null)
            'current_enrollment': data.currentEnrollment!,
          if (data.feePlans != null) 'fee_plans': data.feePlans!,
          if (data.gradeRecords != null) 'grade_records': data.gradeRecords!,
          if (data.guardians != null) 'guardians': data.guardians!,
          if (data.reportCards != null) 'report_cards': data.reportCards!,
        }),
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Create a new student. The [payload] is built by the form layer; the
  /// repository is responsible for the wire shape and the idempotency key.
  Future<Result<PersonCreationResult, PersonFailure>> createStudent(
    StudentFormPayload payload,
  ) async {
    try {
      final idempotencyKey = _uuid.v4();
      final response = await _api.createSchoolStudent(
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
          message: 'The server returned no data for the new student.',
        ));
      }
      return Ok(
          value: PersonCreationResult(
        schoolStudent: data.schoolStudent ?? '',
        studentName: data.studentName ?? '',
        erpnextCustomer: data.erpnextCustomer,
        status: data.status ?? 'Active',
        countryWasDefaulted: data.countryWasDefaulted == 'true' ||
            data.countryWasDefaulted == '1',
        residentialCountryMismatch: data.residentialCountryMismatch == 'true' ||
            data.residentialCountryMismatch == '1',
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
    String? gradeId,
    String? classGroupId,
  ) {
    if (gradeId != null && gradeId.isNotEmpty) {
      final rowGrade = row['grade'];
      if (rowGrade is String && rowGrade != gradeId) return false;
      if (rowGrade is! String) return false;
    }
    if (classGroupId != null && classGroupId.isNotEmpty) {
      final rowCg = row['class_group'] ?? row['classgroup'];
      if (rowCg is String && rowCg != classGroupId) return false;
      if (rowCg is! String) return false;
    }
    if (search != null && search.isNotEmpty) {
      final needle = search.toLowerCase();
      // Include the document name (school_student/name/id) in the
      // haystack so callers can find a student by their stable id
      // (e.g. `currentStudentProvider` re-resolving a cached
      // `STU-00061`, or a user pasting a student code in search).
      final hay = <String>[
        (row['first_name'] ?? '').toString(),
        (row['last_name'] ?? '').toString(),
        (row['full_name'] ?? '').toString(),
        (row['student_name'] ?? '').toString(),
        (row['student_code'] ?? '').toString(),
        (row['school_id'] ?? '').toString(),
        (row['school_student'] ?? '').toString(),
        (row['name'] ?? '').toString(),
        (row['id'] ?? '').toString(),
      ].join(' ').toLowerCase();
      if (!hay.contains(needle)) return false;
    }
    return true;
  }

  String? _nextCursorFromResponse(
      ApiEnvelope<GetSchoolStudentsData> response, int returnedRowCount) {
    final meta = response.meta;
    final raw = meta.values;
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

/// Profile result for a single student. The opaque `raw` map is preserved
/// for screens that need to read fields the typed model doesn't expose yet.
@immutable
class PersonProfile {
  const PersonProfile({
    required this.person,
    required this.summary,
    required this.attendanceRecordsId,
    required this.currentEnrollmentId,
    required this.feePlansId,
    required this.gradeRecords,
    required this.guardians,
    required this.reportCards,
    required this.raw,
  });

  final Person person;
  final JsonMap summary;
  final String? attendanceRecordsId;
  final String? currentEnrollmentId;
  final String? feePlansId;
  final List<JsonMap> gradeRecords;
  final List<JsonMap> guardians;
  final List<JsonMap> reportCards;
  final JsonMap raw;
}

/// Result of a successful create. The §1.3 flags are surfaced here so the
/// create screen can show a confirmation card and the detail screen can
/// render the same chip.
@immutable
class PersonCreationResult {
  const PersonCreationResult({
    required this.schoolStudent,
    required this.studentName,
    required this.status,
    required this.countryWasDefaulted,
    required this.residentialCountryMismatch,
    required this.warnings,
    this.erpnextCustomer,
  });

  final String schoolStudent;
  final String studentName;
  final String? erpnextCustomer;
  final String status;
  final bool countryWasDefaulted;
  final bool residentialCountryMismatch;
  final List<String> warnings;
}
