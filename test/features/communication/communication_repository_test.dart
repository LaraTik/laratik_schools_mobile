// SPDX-License-Identifier: Proprietary
// Tests for the Communication repository.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/communication/data/communication_repository.dart';
import 'package:laratik_schools_mobile/features/people/data/person_failure.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  CommunicationRepository makeRepo(FakeLaratikSchoolsTransport transport) =>
      CommunicationRepository(api: LaratikSchoolsApiClient(transport));

  group('CommunicationRepository.listNotifications', () {
    test('parses rows and exposes read flag + priority', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolMobileNotifications,
        envelopeOk({
          'notifications': [
            {
              'name': 'EDU-NOTIF-2026-00001',
              'title': 'Staff meeting at 3pm',
              'body': 'Quarterly review in the main hall.',
              'category': 'Announcement',
              'priority': 'Normal',
              'read': false,
              'sent_at': '2026-07-28 09:00',
            },
            {
              'name': 'EDU-NOTIF-2026-00002',
              'title': 'Exam window opens today',
              'body': 'Midterm exams are open from 8am to 6pm.',
              'category': 'Exam',
              'priority': 'High',
              'read': true,
              'sent_at': '2026-07-28 08:00',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listNotifications();
      final page = (result as Ok<NotificationPage, PersonFailure>).value;
      expect(page.items, hasLength(2));
      expect(page.items.first.title, 'Staff meeting at 3pm');
      expect(page.items.first.read, isFalse);
      expect(page.items.first.isHighPriority, isFalse);
      expect(page.items.last.priority, 'High');
      expect(page.items.last.isHighPriority, isTrue);
    });

    test('unreadOnly filter drops read items', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolMobileNotifications,
        envelopeOk({
          'notifications': [
            {
              'name': 'EDU-NOTIF-2026-00001',
              'title': 'Unread one',
              'read': false,
            },
            {
              'name': 'EDU-NOTIF-2026-00002',
              'title': 'Already read',
              'read': true,
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listNotifications(unreadOnly: true);
      final page = (result as Ok<NotificationPage, PersonFailure>).value;
      expect(page.items, hasLength(1));
      expect(page.items.first.title, 'Unread one');
    });
  });
}
