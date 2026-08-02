import 'package:laratik_schools_api/laratik_schools_api.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import 'notification.dart';
import 'package:meta/meta.dart';

@immutable
class NotificationPage {
  const NotificationPage({required this.items, this.nextCursor});
  final List<NotificationItem> items;
  final String? nextCursor;
  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}

@immutable
class CommunicationLogPage {
  const CommunicationLogPage({required this.entries, this.nextCursor});
  final List<CommunicationLogEntry> entries;
  final String? nextCursor;
  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}

class CommunicationRepository {
  CommunicationRepository({required LaratikSchoolsApiClient api}) : _api = api;

  final LaratikSchoolsApiClient _api;

  Future<Result<NotificationPage, PersonFailure>> listNotifications({
    String? cursor,
    int? limit,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _api.getSchoolMobileNotifications(
        cursor: cursor,
        limit: limit,
      );
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(error: _failureFromApi(response.error));
      }
      final rows = data.notifications ?? const <JsonMap>[];
      final items = rows
          .where((row) => !unreadOnly || _isUnread(row))
          .map(NotificationItem.fromJson)
          .toList(growable: false);
      return Ok(
          value: NotificationPage(
        items: items,
        nextCursor: _nextCursorFromMeta(response.meta),
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<CommunicationLogPage, PersonFailure>> listCommunicationLogs({
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _api.getSchoolCommunicationLogs(
        cursor: cursor,
        limit: limit,
      );
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(error: _failureFromApi(response.error));
      }
      final rows = data.logs ?? const <JsonMap>[];
      final entries =
          rows.map(CommunicationLogEntry.fromJson).toList(growable: false);
      return Ok(
          value: CommunicationLogPage(
        entries: entries,
        nextCursor: _nextCursorFromMeta(response.meta),
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  bool _isUnread(JsonMap row) {
    final v = row['read'];
    if (v is bool) return !v;
    if (v is String) {
      final s = v.toLowerCase();
      return !(s == 'true' || s == '1' || s == 'yes');
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
