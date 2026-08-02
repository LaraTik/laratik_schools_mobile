import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import 'subject.dart';
import 'package:meta/meta.dart';

@immutable
class SubjectPage {
  const SubjectPage({required this.subjects, this.nextCursor});
  final List<Subject> subjects;
  final String? nextCursor;
  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}

@immutable
class TimetablePage {
  const TimetablePage({required this.slots, this.nextCursor});
  final List<TimetableSlot> slots;
  final String? nextCursor;
  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}

@immutable
class BranchPage {
  const BranchPage({required this.branches, this.nextCursor});
  final List<Branch> branches;
  final String? nextCursor;
  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}

@immutable
class SubjectCreationResult {
  const SubjectCreationResult({
    required this.subjectId,
    required this.subjectName,
    required this.status,
  });
  final String subjectId;
  final String subjectName;
  final String status;
}

class AcademicsRepository {
  AcademicsRepository({required LaratikSchoolsApiClient api, Uuid? uuid})
      : _api = api,
        _uuid = uuid ?? const Uuid();

  final LaratikSchoolsApiClient _api;
  final Uuid _uuid;

  Future<Result<SubjectPage, PersonFailure>> listSubjects({
    String? cursor,
    int? limit,
    String? search,
    String? department,
  }) async {
    try {
      final response = await _api.getSchoolSubjects(
        cursor: cursor,
        limit: limit,
      );
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(error: _failureFromApi(response.error));
      }
      final rows = data.subjects ?? const <JsonMap>[];
      final subjects = rows
          .where((row) => _matchesSubjectFilters(row, search, department))
          .map(Subject.fromJson)
          .toList(growable: false);
      return Ok(
          value: SubjectPage(
        subjects: subjects,
        nextCursor: _nextCursorFromMeta(response.meta),
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<SubjectCreationResult, PersonFailure>> createSubject({
    required String subjectName,
    String? subjectCode,
    String? department,
    String? gradeLevel,
    int? creditHours,
    String? description,
  }) async {
    try {
      final idempotencyKey = _uuid.v4();
      final response = await _api.createSchoolSubject(
        payload: <String, Object?>{
          'subject_name': subjectName,
          if (subjectCode != null && subjectCode.isNotEmpty)
            'subject_code': subjectCode,
          if (department != null && department.isNotEmpty)
            'department': department,
          if (gradeLevel != null && gradeLevel.isNotEmpty)
            'grade_level': gradeLevel,
          if (creditHours != null) 'credit_hours': creditHours,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
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
          message: 'The server returned no data for the new subject.',
        ));
      }
      return Ok(
          value: SubjectCreationResult(
        subjectId: data.schoolSubject ?? '',
        subjectName: data.subjectName ?? subjectName,
        status: data.status ?? 'Active',
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<TimetablePage, PersonFailure>> listTimetable({
    String? cursor,
    int? limit,
    String? branch,
    String? academicYear,
  }) async {
    try {
      final response = await _api.getSchoolTimetableSlots(
        cursor: cursor,
        limit: limit,
      );
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(error: _failureFromApi(response.error));
      }
      final rows = data.slots ?? const <JsonMap>[];
      final slots = rows
          .where((row) => _matchesSlotFilters(row, branch, academicYear))
          .map(TimetableSlot.fromJson)
          .toList(growable: false);
      return Ok(
          value: TimetablePage(
        slots: slots,
        nextCursor: _nextCursorFromMeta(response.meta),
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<BranchPage, PersonFailure>> listBranches({
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _api.getSchoolBranches(
        cursor: cursor,
        limit: limit,
      );
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(error: _failureFromApi(response.error));
      }
      final rows = data.branches ?? const <JsonMap>[];
      final branches = rows.map(Branch.fromJson).toList(growable: false);
      return Ok(
          value: BranchPage(
        branches: branches,
        nextCursor: _nextCursorFromMeta(response.meta),
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  bool _matchesSubjectFilters(
    JsonMap row,
    String? search,
    String? department,
  ) {
    if (department != null && department.isNotEmpty) {
      final rowDept = row['department'];
      if (rowDept is String && rowDept != department) return false;
      if (rowDept is! String) return false;
    }
    if (search != null && search.isNotEmpty) {
      final needle = search.toLowerCase();
      final hay = <String>[
        (row['subject_name'] ?? '').toString(),
        (row['subject_code'] ?? '').toString(),
        (row['code'] ?? '').toString(),
        (row['department'] ?? '').toString(),
      ].join(' ').toLowerCase();
      if (!hay.contains(needle)) return false;
    }
    return true;
  }

  bool _matchesSlotFilters(
    JsonMap row,
    String? branch,
    String? academicYear,
  ) {
    if (branch != null && branch.isNotEmpty) {
      final rowBranch = row['branch'];
      if (rowBranch is String && rowBranch != branch) return false;
      if (rowBranch is! String) return false;
    }
    if (academicYear != null && academicYear.isNotEmpty) {
      final rowYear = row['academic_year'];
      if (rowYear is String && rowYear != academicYear) return false;
      if (rowYear is! String) return false;
    }
    return true;
  }

  String? _nextCursorFromMeta(ApiMeta meta) {
    final raw = meta.values;
    for (final key in const ['next_cursor', 'nextCursor', 'cursor']) {
      final v = raw[key];
      if (v is String && v.isNotEmpty) return v;
    }
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
