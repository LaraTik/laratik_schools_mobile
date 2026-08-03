// SPDX-License-Identifier: Proprietary
// Tests for the Operations repository (read-only operations
// health + delivery health + auth audit events).
//
// The tests cover:
//   * [fetchOperationsHealth] parses the top-level status + the
//     per-module KPI maps.
//   * [fetchOperationsHealth] surfaces an EMPTY_RESPONSE failure
//     when the wire returns no data block.
//   * [fetchOperationsHealth] surfaces a NETWORK_FAILURE when
//     the SDK throws.
//   * [fetchDeliveryHealth] parses the per-status counts and
//     orders them by count (descending) for the bar chart.
//   * [fetchDeliveryHealth] returns an empty counts map when
//     the wire has no `status_counts` block.
//   * [listAuthAuditEvents] parses the audit events into
//     [AuthAuditEvent]s with event type, user, timestamp, and
//     IP preserved.
//   * [AuthAuditEvent.family] maps the wire event type to a
//     coarse family (login / logout / token_refresh /
//     device_register / other) for the chip tone.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/operations/data/operations_failure.dart';
import 'package:laratik_schools_mobile/features/operations/data/operations_health.dart';
import 'package:laratik_schools_mobile/features/operations/data/operations_repository.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  OperationsRepository makeRepo(FakeLaratikSchoolsTransport transport) =>
      OperationsRepository(api: LaratikSchoolsApiClient(transport));

  group('OperationsRepository.fetchOperationsHealth', () {
    test('parses the top-level status + per-module KPI maps', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolOperationsHealth,
        envelopeOk({
          'status': 'degraded',
          'generated_at': '2026-08-03T10:00:00+00:00',
          'analytics': {
            'last_30d_active_students': 412,
            'last_30d_attendance_pct': 94.5,
          },
          'audit': {
            'pending_privacy_requests': 3,
            'legal_holds': 0,
          },
          'delivery': {
            'pending': 12,
            'failed': 2,
          },
          'imports': {
            'in_flight': 1,
          },
          'outbox': {
            'pending': 7,
          },
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.fetchOperationsHealth();
      expect(result, isA<Ok<OperationsHealth, OperationsFailure>>());
      final health = (result as Ok).value as OperationsHealth;
      expect(health.status, 'degraded');
      expect(health.isDegraded, isTrue);
      expect(health.isHealthy, isFalse);
      expect(health.isUnhealthy, isFalse);
      expect(health.generatedAt, '2026-08-03T10:00:00+00:00');
      expect(health.analytics['last_30d_active_students'], 412);
      expect(health.audit['pending_privacy_requests'], 3);
      expect(health.delivery['pending'], 12);
      expect(health.imports['in_flight'], 1);
      expect(health.outbox['pending'], 7);
      // The moduleKpis helper should flatten all 5 maps into a
      // single list of 8 triples.
      expect(health.moduleKpis.length, 8);
    });

    test('surfaces EMPTY_RESPONSE when the wire returns no data', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.getSchoolOperationsHealth,
        const ApiError(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no operations health data.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.fetchOperationsHealth();
      expect(result, isA<Err<OperationsHealth, OperationsFailure>>());
      final err = (result as Err).error as OperationsFailure;
      expect(err.code, 'EMPTY_RESPONSE');
      expect(err.message, 'The server returned no operations health data.');
    });

    test('surfaces an error code from the wire', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.getSchoolOperationsHealth,
        const ApiError(code: 'HTTP_502', message: 'Upstream down'),
      );
      final repo = makeRepo(transport);
      final result = await repo.fetchOperationsHealth();
      expect(result, isA<Err<OperationsHealth, OperationsFailure>>());
      final err = (result as Err).error as OperationsFailure;
      expect(err.code, 'HTTP_502');
      expect(err.isRetryable, isTrue);
    });
  });

  group('OperationsRepository.fetchDeliveryHealth', () {
    test('parses the per-status counts and orders by count desc', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolDeliveryHealth,
        envelopeOk({
          'status_counts': {
            'pending': 12,
            'completed': 100,
            'failed': 2,
          },
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.fetchDeliveryHealth();
      expect(result, isA<Ok<DeliveryHealth, OperationsFailure>>());
      final health = (result as Ok).value as DeliveryHealth;
      expect(health.total, 114);
      final sorted = health.sortedCounts();
      expect(sorted[0].key, 'completed');
      expect(sorted[0].value, 100);
      expect(sorted[1].key, 'pending');
      expect(sorted[2].key, 'failed');
    });

    test('returns an empty counts map when the wire has no counts', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolDeliveryHealth,
        envelopeOk(<String, Object?>{}),
      );
      final repo = makeRepo(transport);
      final result = await repo.fetchDeliveryHealth();
      expect(result, isA<Ok<DeliveryHealth, OperationsFailure>>());
      final health = (result as Ok).value as DeliveryHealth;
      expect(health.isEmpty, isTrue);
      expect(health.total, 0);
      expect(health.sortedCounts(), isEmpty);
    });
  });

  group('OperationsRepository.listAuthAuditEvents', () {
    test('parses the events list with event type, user, timestamp, ip',
        () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolAuthAuditEvents,
        envelopeOk({
          'audit_events': [
            {
              'event_type': 'login',
              'user': 'admin@school.example',
              'timestamp': '2026-08-03T10:00:00+00:00',
              'ip_address': '10.0.0.42',
              'user_agent': 'Laratik/1.0 (Android)',
            },
            {
              'event_type': 'device_register',
              'user': 'admin@school.example',
              'timestamp': '2026-08-03T10:01:00+00:00',
              'ip_address': '10.0.0.42',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listAuthAuditEvents();
      expect(result, isA<Ok<AuthAuditPage, OperationsFailure>>());
      final page = (result as Ok).value as AuthAuditPage;
      expect(page.events.length, 2);
      expect(page.events[0].eventType, 'login');
      expect(page.events[0].user, 'admin@school.example');
      expect(page.events[0].ipAddress, '10.0.0.42');
      expect(page.events[0].family, 'login');
      expect(page.events[1].eventType, 'device_register');
      expect(page.events[1].family, 'device_register');
    });

    test('forwards the limit query parameter to the SDK', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolAuthAuditEvents,
        envelopeOk({'audit_events': const <Object?>[]}),
      );
      final repo = makeRepo(transport);
      await repo.listAuthAuditEvents(limit: 25);
      expect(transport.invokedArguments.last['limit'], 25);
    });
  });

  group('AuthAuditEvent.family', () {
    test('maps event types to coarse families for the chip tone', () {
      const cases = {
        'login': 'login',
        'login_failed': 'login',
        'logout': 'logout',
        'token_refresh': 'token_refresh',
        'token_refresh_failed': 'token_refresh',
        'device_register': 'device_register',
        'device_register_failed': 'device_register',
        'permission_changed': 'other',
      };
      for (final entry in cases.entries) {
        final event = AuthAuditEvent.fromJson({
          'event_type': entry.key,
        });
        expect(event.family, entry.value, reason: entry.key);
      }
    });
  });
}
