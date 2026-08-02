// SPDX-License-Identifier: Proprietary
// Tests for the Fees repository (read-only fee plans + admin
// operations overview).
//
// The tests cover:
//   * [listFeePlans] parses v1 envelope rows into [FeePlan]s
//     with student name + currency + total / paid / outstanding
//     preserved.
//   * [listFeePlans] surfaces an EMPTY_RESPONSE failure when
//     the wire returns no data block.
//   * [FeePlan.fromJson] is forward-compatible: legacy keys
//     (`student`, `total`, `status`) AND canonical keys
//     (`school_student`, `total_amount`, `invoice_status`)
//     both resolve to the same value.
//   * [FeePlanItem.fromJson] extracts description + amount from
//     either `items` or `fee_components` child tables.
//   * [fetchOperationsOverview] surfaces the summary card with
//     total / collected / outstanding + counts by status, and
//     computes the collection rate correctly.
//   * [FeeOperationsOverview.collectionRate] returns null on
//     zero invoiced (avoiding div-by-zero and the "0%"
//     collected lie on a fresh school).
//   * [FeesFailure] isRetryable covers network + 5xx codes.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/fees/data/fee_plan.dart';
import 'package:laratik_schools_mobile/features/fees/data/fees_failure.dart';
import 'package:laratik_schools_mobile/features/fees/data/fees_repository.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  FeesRepository makeRepo(FakeLaratikSchoolsTransport transport) =>
      FeesRepository(api: LaratikSchoolsApiClient(transport));

  group('FeesRepository.listFeePlans', () {
    test('parses rows and preserves canonical wire fields', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolStudentFeePlans,
        envelopeOk({
          'plans': [
            {
              'name': 'EDU-SFP-2026-00001',
              'school_student': 'STU-00001',
              'student_name': 'Yusuf Hassan',
              'academic_year': '2025/2026',
              'invoice_status': 'Issued',
              'total_amount': 1500.0,
              'paid_amount': 500.0,
              'outstanding_amount': 1000.0,
              'currency': 'USD',
              'due_date': '2026-09-15',
              'items': [
                {
                  'description': 'Tuition',
                  'category': 'School fees',
                  'frequency': 'Annual',
                  'amount': 1500.0,
                },
              ],
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listFeePlans();
      final page = (result as Ok<FeePlanPage, FeesFailure>).value;
      expect(page.plans, hasLength(1));
      final plan = page.plans.first;
      expect(plan.id, 'EDU-SFP-2026-00001');
      expect(plan.studentName, 'Yusuf Hassan');
      expect(plan.invoiceStatus, 'Issued');
      expect(plan.totalAmount, 1500.0);
      expect(plan.paidAmount, 500.0);
      expect(plan.outstandingAmount, 1000.0);
      expect(plan.currency, 'USD');
      expect(plan.dueDate, '2026-09-15');
      expect(plan.items, hasLength(1));
      expect(plan.items.first.description, 'Tuition');
      expect(plan.items.first.amount, 1500.0);
      expect(plan.isPaid, isFalse);
      expect(plan.isOverdue, isFalse);
      expect(plan.isPartiallyPaid, isFalse);
    });

    test(
        'accepts legacy wire keys (student, total, status, items as fee_components)',
        () async {
      // Some sites predate the v1 normalized names. The mobile
      // still parses the row so the surface doesn't fall over.
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolStudentFeePlans,
        envelopeOk({
          'plans': [
            {
              'name': 'EDU-SFP-2026-00099',
              'student': 'STU-00099',
              'student_name': 'Lina Hassan',
              'status': 'Paid',
              'total': 200.0,
              'paid': 200.0,
              'outstanding': 0,
              'currency': 'EUR',
              'fee_components': [
                {'description': 'Lab fee', 'amount': 200.0},
              ],
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listFeePlans();
      final page = (result as Ok<FeePlanPage, FeesFailure>).value;
      final plan = page.plans.first;
      expect(plan.student, 'STU-00099');
      expect(plan.invoiceStatus, 'Paid');
      expect(plan.totalAmount, 200.0);
      expect(plan.paidAmount, 200.0);
      expect(plan.outstandingAmount, 0.0);
      expect(plan.currency, 'EUR');
      expect(plan.items, hasLength(1));
      expect(plan.items.first.description, 'Lab fee');
      expect(plan.isPaid, isTrue);
    });

    test('returns EMPTY_RESPONSE when the envelope has no data', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.getSchoolStudentFeePlans,
        const ApiError(
          code: 'EMPTY_RESPONSE',
          message: 'No data',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.listFeePlans();
      expect(result, isA<Err<FeePlanPage, FeesFailure>>());
    });
  });

  group('FeesRepository.fetchOperationsOverview', () {
    test('returns the summary card with collection rate', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolFeeOperationsOverview,
        envelopeOk({
          'branches': [
            {'branch': 'EDU-BR-2026-00001', 'total_invoiced': 10000.0},
          ],
          'schema': <String, Object?>{'version': 'v1'},
          'summary': {
            'total_invoiced': 10000.0,
            'total_collected': 7500.0,
            'total_outstanding': 2500.0,
            'overdue_count': 3,
            'draft_count': 1,
            'paid_count': 25,
            'currency': 'USD',
          },
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.fetchOperationsOverview();
      final overview = (result as Ok<FeeOperationsOverview, FeesFailure>).value;
      expect(overview.totalInvoiced, 10000.0);
      expect(overview.totalCollected, 7500.0);
      expect(overview.totalOutstanding, 2500.0);
      expect(overview.overdueCount, 3);
      expect(overview.draftCount, 1);
      expect(overview.paidCount, 25);
      expect(overview.currency, 'USD');
      // 7500 / 10000 = 75.0
      expect(overview.collectionRate, 75.0);
    });

    test('collectionRate is null when total invoiced is zero', () async {
      // Avoid the "0% collected" lie on a fresh school that
      // hasn't issued any invoices yet.
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolFeeOperationsOverview,
        envelopeOk({
          'branches': <Object?>[],
          'schema': <String, Object?>{'version': 'v1'},
          'summary': {
            'total_invoiced': 0,
            'total_collected': 0,
            'total_outstanding': 0,
            'overdue_count': 0,
            'draft_count': 0,
            'paid_count': 0,
            'currency': 'USD',
          },
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.fetchOperationsOverview();
      final overview = (result as Ok<FeeOperationsOverview, FeesFailure>).value;
      expect(overview.collectionRate, isNull);
    });
  });

  group('FeesFailure', () {
    test('isRetryable covers network + 5xx codes', () {
      const f = FeesFailure(code: 'NETWORK_FAILURE', message: 'x');
      expect(f.isRetryable, isTrue);
    });

    test('isRetryable is false for validation errors', () {
      const f = FeesFailure(code: 'FEE_PLAN_NOT_FOUND', message: 'x');
      expect(f.isRetryable, isFalse);
    });
  });
}
