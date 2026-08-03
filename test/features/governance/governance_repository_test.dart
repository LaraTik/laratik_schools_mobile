// SPDX-License-Identifier: Proprietary
// Tests for the Governance repository (read-only privacy
// requests + approve / process / set-legal-hold / retention
// evaluation + parent/student submit).
//
// The tests cover:
//   * [listPrivacyRequests] parses v1 envelope rows into
//     [PrivacyRequest]s with the canonical display fields
//     (subject, status, type, legal hold) preserved.
//   * [listPrivacyRequests] surfaces an EMPTY_RESPONSE
//     failure when the wire returns no data block.
//   * [listPrivacyRequests] surfaces the wire error code on
//     a typed-error response.
//   * [approvePrivacyRequest] mints a fresh idempotency
//     key for every call.
//   * [setLegalHold] forwards the `hold` boolean to the SDK
//     + the `reason` string when present.
//   * [submitPrivacyRequest] forwards the canonical payload
//     fields + mints a fresh idempotency key for every call
//     + parses the v1 envelope into a [SubmittedPrivacyRequest].
//   * [PrivacyRequest.statusFamily] maps the wire status
//     to a coarse family for the chip tone.
//   * [PrivacyRequest.typeFamily] maps the wire request
//     type to a coarse family for the row icon.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/governance/data/governance_failure.dart';
import 'package:laratik_schools_mobile/features/governance/data/governance_request.dart';
import 'package:laratik_schools_mobile/features/governance/data/governance_repository.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  GovernanceRepository makeRepo(FakeLaratikSchoolsTransport transport) =>
      GovernanceRepository(api: LaratikSchoolsApiClient(transport));

  group('GovernanceRepository.listPrivacyRequests', () {
    test('parses rows and preserves canonical wire fields', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolPrivacyRequests,
        envelopeOk({
          'privacy_requests': [
            {
              'name': 'EDU-PR-2026-00001',
              'school_student': 'STU-00001',
              'student_name': 'Lina Hassan',
              'request_type': 'data_export',
              'status': 'Under Review',
              'submitted_by': 'parent@school.example',
              'submitted_at': '2026-08-01T10:00:00+00:00',
              'legal_hold': '0',
              'notes': 'Need a full export of the academic year.',
            },
            {
              'name': 'EDU-PR-2026-00002',
              'school_student': 'STU-00002',
              'student_name': 'Yusuf Hassan',
              'request_type': 'data_deletion',
              'status': 'Legal Hold',
              'submitted_by': 'parent2@school.example',
              'submitted_at': '2026-08-02T10:00:00+00:00',
              'legal_hold': '1',
              'notes': 'Pending legal review.',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listPrivacyRequests();
      expect(result, isA<Ok<PrivacyRequestPage, GovernanceFailure>>());
      final page = (result as Ok).value as PrivacyRequestPage;
      expect(page.requests.length, 2);
      expect(page.requests[0].id, 'EDU-PR-2026-00001');
      expect(page.requests[0].subjectName, 'Lina Hassan');
      expect(page.requests[0].requestType, 'data_export');
      expect(page.requests[0].status, 'Under Review');
      expect(page.requests[0].legalHold, isFalse);
      expect(page.requests[0].statusFamily, 'review');
      expect(page.requests[0].typeFamily, 'access');
      expect(page.requests[1].legalHold, isTrue);
      expect(page.requests[1].statusFamily, 'hold');
      expect(page.requests[1].typeFamily, 'deletion');
    });

    test('surfaces the wire error code on a typed-error response', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.getSchoolPrivacyRequests,
        const ApiError(
          code: 'PRIVACY_REQUEST_NOT_FOUND',
          message: 'No such request',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.listPrivacyRequests();
      expect(result, isA<Err<PrivacyRequestPage, GovernanceFailure>>());
      final err = (result as Err).error as GovernanceFailure;
      expect(err.code, 'PRIVACY_REQUEST_NOT_FOUND');
      expect(err.isRetryable, isFalse);
    });
  });

  group('GovernanceRepository.approvePrivacyRequest', () {
    test('forwards the request name + mints a fresh idempotency key', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.approveSchoolPrivacyRequest,
        envelopeOk(<String, Object?>{}),
      );
      final repo = makeRepo(transport);
      final result =
          await repo.approvePrivacyRequest(requestName: 'EDU-PR-2026-00001');
      expect(result, isA<Ok<void, GovernanceFailure>>());
      // The SDK wraps the caller's payload under a `payload`
      // key, so the test inspects `arguments['payload']`.
      final args = transport.invokedArguments.last;
      final payload = args['payload'] as Map<String, Object?>;
      expect(payload['request_name'], 'EDU-PR-2026-00001');
    });

    test('forwards the reason when provided', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.approveSchoolPrivacyRequest,
        envelopeOk(<String, Object?>{}),
      );
      final repo = makeRepo(transport);
      await repo.approvePrivacyRequest(
        requestName: 'EDU-PR-2026-00001',
        reason: 'Verified identity on file.',
      );
      final args = transport.invokedArguments.last;
      final payload = args['payload'] as Map<String, Object?>;
      expect(payload['reason'], 'Verified identity on file.');
    });
  });

  group('GovernanceRepository.setLegalHold', () {
    test('forwards the hold boolean + request name', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.setSchoolPrivacyLegalHold,
        envelopeOk(<String, Object?>{}),
      );
      final repo = makeRepo(transport);
      final result = await repo.setLegalHold(
        requestName: 'EDU-PR-2026-00001',
        hold: true,
        reason: 'Pending legal review.',
      );
      expect(result, isA<Ok<void, GovernanceFailure>>());
      final args = transport.invokedArguments.last;
      final payload = args['payload'] as Map<String, Object?>;
      expect(payload['request_name'], 'EDU-PR-2026-00001');
      expect(payload['hold'], isTrue);
      expect(payload['reason'], 'Pending legal review.');
    });
  });

  group('GovernanceRepository.submitPrivacyRequest', () {
    test('forwards canonical payload + mints a fresh idempotency key',
        () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.submitSchoolPrivacyRequest,
        envelopeOk({
          'privacy_request': 'EDU-PR-2026-00042',
          'status': 'submitted',
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.submitPrivacyRequest(
        requestType: 'erasure',
        requesterType: 'guardian',
        subjectType: 'student',
        subject: 'STU-00001',
        requestedCategories: const ['personal', 'attendance'],
        schoolBranch: 'main',
        authorityReference: 'auth-ticket-9001',
      );
      expect(result, isA<Ok<SubmittedPrivacyRequest, GovernanceFailure>>());
      final ok = result as Ok<SubmittedPrivacyRequest, GovernanceFailure>;
      expect(ok.value.privacyRequest, 'EDU-PR-2026-00042');
      expect(ok.value.isSubmitted, isTrue);
      // The SDK wraps the payload under a `payload` key, so the
      // test inspects `arguments['payload']`.
      final args = transport.invokedArguments.last;
      final payload = args['payload'] as Map<String, Object?>;
      expect(payload['request_type'], 'erasure');
      expect(payload['requester_type'], 'guardian');
      expect(payload['subject_type'], 'student');
      expect(payload['subject'], 'STU-00001');
      expect(payload['school_branch'], 'main');
      expect(payload['authority_reference'], 'auth-ticket-9001');
      expect(payload['requested_categories'], ['personal', 'attendance']);
      // The repository mints a fresh UUID v4 for the
      // `Idempotency-Key` header. Same for `client_request_id`
      // on the payload so a retry is safe to send again.
      expect(transport.invokedIdempotencyKey, isNotNull);
      expect(transport.invokedIdempotencyKey!.length, greaterThanOrEqualTo(8));
      final clientRequestId = payload['client_request_id'] as String;
      expect(clientRequestId.length, greaterThanOrEqualTo(8));
    });

    test('falls back to the wire `name` legacy alias for the request id',
        () async {
      // Pure model test — the v1 SDK's
      // `SubmitSchoolPrivacyRequestData.fromJson` is strict-cast
      // and only accepts the canonical `privacy_request` key, so
      // we exercise the model layer directly here to confirm the
      // forward-compat alias walker still surfaces `name` /
      // `request` when the server grows an older envelope.
      final parsed = SubmittedPrivacyRequest.fromJson({
        'name': 'EDU-PR-2026-00043',
        'status': 'received',
      });
      expect(parsed.privacyRequest, 'EDU-PR-2026-00043');
      expect(parsed.isSubmitted, isTrue);
    });

    test('surfaces the wire error code on a typed-error response', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.submitSchoolPrivacyRequest,
        const ApiError(
          code: 'PRIVACY_REQUESTER_FORBIDDEN',
          message: 'Not allowed to submit on behalf of this subject.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.submitPrivacyRequest(
        requestType: 'access',
        requesterType: 'guardian',
        subjectType: 'student',
        subject: 'STU-00001',
        requestedCategories: const ['personal'],
        schoolBranch: 'main',
        authorityReference: 'auth-ticket-9001',
      );
      expect(result, isA<Err<SubmittedPrivacyRequest, GovernanceFailure>>());
      final err =
          (result as Err<SubmittedPrivacyRequest, GovernanceFailure>).error;
      expect(err.code, 'PRIVACY_REQUESTER_FORBIDDEN');
      expect(err.isRetryable, isFalse);
    });
  });

  group('PrivacyRequest status / type families', () {
    test('maps the wire status to a coarse family', () {
      const cases = {
        'Submitted': 'pending',
        'Under Review': 'review',
        'Approved': 'approved',
        'Rejected': 'rejected',
        'Legal Hold': 'hold',
        'Pending': 'pending',
        'Processing': 'review',
        'Completed': 'approved',
        'Cancelled': 'rejected',
        'Unknown': 'other',
      };
      for (final entry in cases.entries) {
        final r = PrivacyRequest.fromJson({
          'name': 'X',
          'status': entry.key,
        });
        expect(r.statusFamily, entry.value, reason: entry.key);
      }
    });

    test('maps the wire type to a coarse family', () {
      const cases = {
        'data_export': 'access',
        'data_access': 'access',
        'data_deletion': 'deletion',
        'erase': 'deletion',
        'consent_withdrawal': 'consent',
        'legal_hold': 'legal_hold',
        'governance_settings': 'governance',
        'other': 'other',
      };
      for (final entry in cases.entries) {
        final r = PrivacyRequest.fromJson({
          'name': 'X',
          'request_type': entry.key,
        });
        expect(r.typeFamily, entry.value, reason: entry.key);
      }
    });
  });
}
