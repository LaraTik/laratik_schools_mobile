import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import '../../people/data/person_repository.dart';
import 'attendance_record.dart';

@immutable
class AttendancePage {
  const AttendancePage({required this.records, this.nextCursor});
  final List<AttendanceRecord> records;
  final String? nextCursor;
  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}

@immutable
class AttendanceMarkResult {
  const AttendanceMarkResult({
    required this.attendanceRecord,
    required this.studentName,
    required this.attendanceStatus,
    required this.status,
  });
  final String attendanceRecord;
  final String studentName;
  final String attendanceStatus;
  final String status;
}

@immutable
class AttendanceBatchResult {
  const AttendanceBatchResult({
    required this.succeeded,
    required this.failed,
  });
  final int succeeded;
  final int failed;
}

class AttendanceRepository {
  AttendanceRepository({
    required LaratikSchoolsApiClient api,
    required PersonRepository personRepository,
    Uuid? uuid,
  })  : _api = api,
        _personRepository = personRepository,
        _uuid = uuid ?? const Uuid();

  final LaratikSchoolsApiClient _api;
  final PersonRepository _personRepository;
  final Uuid _uuid;

  Future<Result<AttendancePage, PersonFailure>> listRecords({
    String? cursor,
    int? limit,
    String? classGroup,
    String? date,
  }) async {
    try {
      final response = await _api.getSchoolAttendanceRecords(
        cursor: cursor,
        limit: limit,
      );
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(_failureFromApi(response.error, data));
      }
      final rows = data.records ?? const <JsonMap>[];
      final records = rows
          .where((row) => _matchesFilters(row, classGroup, date))
          .map(AttendanceRecord.fromJson)
          .toList(growable: false);
      return Ok(AttendancePage(
        records: records,
        nextCursor: _nextCursorFromMeta(response.meta),
      ));
    } on Exception catch (e) {
      return Err(_exceptionFailure(e));
    }
  }

  /// Read the current roster of a class group, then wrap each student in
  /// an [AttendanceMark] with the default `Present` status. The operator
  /// mutates the marks on the screen; the repository writes them.
  Future<Result<List<AttendanceMark>, PersonFailure>> loadRoster({
    String? gradeId,
    String? classGroupId,
  }) async {
    final result = await _personRepository.listStudents(
      limit: 100,
      gradeId: gradeId,
      classGroupId: classGroupId,
    );
    return switch (result) {
      Ok(:final value) => Ok(value.people
          .map((p) => AttendanceMark(
                studentId: p.id,
                studentName: p.fullName,
                status: AttendanceStatus.present,
                guardianName: p.guardianName,
              ))
          .toList(growable: false)),
      Err(:final error) => Err(error),
    };
  }

  Future<Result<AttendanceMarkResult, PersonFailure>> submitMark({
    required AttendanceMark mark,
    required String attendanceDate,
    String? period,
    String? classGroup,
    String? notes,
  }) async {
    try {
      final idempotencyKey = _uuid.v4();
      final response = await _api.createSchoolAttendanceRecord(
        payload: <String, Object?>{
          'school_student': mark.studentId,
          'attendance_status': mark.status.value,
          'attendance_date': attendanceDate,
          if (period != null && period.isNotEmpty) 'period': period,
          if (classGroup != null && classGroup.isNotEmpty)
            'class_group': classGroup,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        idempotencyKey: idempotencyKey,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(_failureFromApi(response.error, data));
      }
      if (data == null) {
        return const Err(PersonFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no data for the new attendance record.',
        ));
      }
      return Ok(AttendanceMarkResult(
        attendanceRecord: data.attendanceRecord ?? '',
        studentName: data.studentName ?? mark.studentName,
        attendanceStatus: data.attendanceStatus ?? mark.status.value,
        status: data.status ?? 'Submitted',
      ));
    } on Exception catch (e) {
      return Err(_exceptionFailure(e));
    }
  }

  /// Submit a batch of marks sequentially. Per-mark errors are swallowed
  /// and reported in the aggregate; the caller's UI shows a summary.
  Future<AttendanceBatchResult> submitBatch({
    required List<AttendanceMark> marks,
    required String attendanceDate,
    String? period,
    String? classGroup,
    String? notes,
  }) async {
    var succeeded = 0;
    var failed = 0;
    for (final mark in marks) {
      final result = await submitMark(
        mark: mark,
        attendanceDate: attendanceDate,
        period: period,
        classGroup: classGroup,
        notes: notes,
      );
      switch (result) {
        case Ok():
          succeeded++;
        case Err():
          failed++;
      }
    }
    return AttendanceBatchResult(succeeded: succeeded, failed: failed);
  }

  bool _matchesFilters(JsonMap row, String? classGroup, String? date) {
    if (classGroup != null && classGroup.isNotEmpty) {
      final rowCg = row['class_group'];
      if (rowCg is String && rowCg != classGroup) return false;
      if (rowCg is! String) return false;
    }
    if (date != null && date.isNotEmpty) {
      final rowDate = row['attendance_date'] ?? row['date'];
      if (rowDate is String && rowDate != date) return false;
      if (rowDate is! String) return false;
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

  PersonFailure _exceptionFailure(Exception e) {
    return PersonFailure(
      code: 'EXCEPTION',
      message: e.toString(),
    );
  }
}
