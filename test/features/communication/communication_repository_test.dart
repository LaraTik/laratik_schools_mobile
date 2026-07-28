import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/communication/data/communication_repository.dart';
import 'package:laratik_schools_mobile/features/communication/data/notification.dart';
import 'package:laratik_schools_mobile/features/people/data/person_failure.dart';

class _FakeCommApi implements LaratikSchoolsApiClient {
  ApiEnvelope<GetSchoolMobileNotificationsData>? notificationsResponse;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  group('CommunicationRepository.listNotifications', () {
    test('parses rows and exposes read flag + priority', () async {
      final api = _FakeCommApi()
        ..notificationsResponse = ApiEnvelope<GetSchoolMobileNotificationsData>(
          data: const GetSchoolMobileNotificationsData(
            notifications: <JsonMap>[
              <String, Object?>{
                'name': 'EDU-NOTIF-2026-00001',
                'title': 'Staff meeting at 3pm',
                'body': 'Quarterly review in the main hall.',
                'category': 'Announcement',
                'priority': 'Normal',
                'read': false,
                'sent_at': '2026-07-28 09:00',
              },
              <String, Object?>{
                'name': 'EDU-NOTIF-2026-00002',
                'title': 'Exam window opens today',
                'body': 'Midterm exams are open from 8am to 6pm.',
                'category': 'Exam',
                'priority': 'High',
                'read': true,
                'sent_at': '2026-07-28 08:00',
              },
            ],
            ),
          error: null,
          meta: const ApiMeta(
            apiVersion: 'v1',
            requestId: 'req-1',
            values: <String, Object?>{'next_cursor': 'cursor-2'},
          ),
          warnings: const <Object?>[],
        );
      final repo = CommunicationRepository(api: api);
      final result = await repo.listNotifications();
      final page = (result as Ok<NotificationPage, PersonFailure>).value;
      expect(page.items, hasLength(2));
      expect(page.items.first.title, 'Staff meeting at 3pm');
      expect(page.items.first.read, isFalse);
      expect(page.items.first.isHighPriority, isFalse);
      expect(page.items.last.priority, 'High');
      expect(page.items.last.isHighPriority, isTrue);
      expect(page.nextCursor, 'cursor-2');
    });

    test('unreadOnly filter drops read items', () async {
      final api = _FakeCommApi()
        ..notificationsResponse = ApiEnvelope<GetSchoolMobileNotificationsData>(
          data: const GetSchoolMobileNotificationsData(
            notifications: <JsonMap>[
              <String, Object?>{
                'name': 'EDU-NOTIF-2026-00001',
                'title': 'Unread one',
                'read': false,
              },
              <String, Object?>{
                'name': 'EDU-NOTIF-2026-00002',
                'title': 'Already read',
                'read': true,
              },
            ],
            ),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        );
      final repo = CommunicationRepository(api: api);
      final result = await repo.listNotifications(unreadOnly: true);
      final page = (result as Ok<NotificationPage, PersonFailure>).value;
      expect(page.items, hasLength(1));
      expect(page.items.first.title, 'Unread one');
    });
  });
}
