// SPDX-License-Identifier: Proprietary
// A row from the `get_school_student_fee_plans` list.
//
// The v1 contract returns each row as a forward-compatible
// [JsonMap]; the fields the mobile knows about are surfaced here
// as named accessors while the full map is preserved on [raw] so
// future schema additions (multi-currency, per-line discounts,
// recurring schedules) flow through without an app update.
//
// Today's "invoice status" shape is intentionally narrow — the
// server is the source of truth for the full lifecycle (Draft,
// Issued, Paid, Partially Paid, Overdue, Cancelled, etc.). The
// mobile renders the wire value as-is and groups rows by it
// in the operations overview.

import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

@immutable
class FeePlan extends Equatable {
  const FeePlan({
    required this.id,
    required this.student,
    required this.studentName,
    required this.academicYear,
    required this.invoiceStatus,
    required this.totalAmount,
    required this.paidAmount,
    required this.outstandingAmount,
    required this.currency,
    required this.dueDate,
    required this.items,
    required this.raw,
  });

  factory FeePlan.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    double? pickDouble(String key) {
      final v = json[key];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    // Items is a child table (`items` or `fee_components` on the
    // wire). The mobile renders the count and the sum; the full
    // breakdown is in [raw] for the detail screen.
    final itemsList =
        json['items'] ?? json['fee_components'] ?? json['components'];
    final itemCount = itemsList is List ? itemsList.length : 0;

    return FeePlan(
      id: pickString('name') ?? pickString('id') ?? '',
      student: pickString('school_student') ?? pickString('student') ?? '',
      studentName:
          pickString('student_name') ?? pickString('school_student_name') ?? '',
      academicYear: pickString('academic_year') ??
          pickString('school_academic_year') ??
          '',
      invoiceStatus:
          pickString('invoice_status') ?? pickString('status') ?? 'Draft',
      totalAmount: pickDouble('total_amount') ??
          pickDouble('grand_total') ??
          pickDouble('total') ??
          0,
      paidAmount: pickDouble('paid_amount') ?? pickDouble('paid') ?? 0,
      outstandingAmount: pickDouble('outstanding_amount') ??
          pickDouble('balance') ??
          pickDouble('outstanding') ??
          0,
      currency: pickString('currency') ?? '',
      dueDate: pickString('due_date'),
      items: List<FeePlanItem>.unmodifiable(
        itemsList is List
            ? itemsList
                .whereType<Map>()
                .map((e) => FeePlanItem.fromJson(
                      Map<String, Object?>.from(e),
                    ))
                .toList(growable: false)
            : const <FeePlanItem>[],
      ),
      raw: json,
    );
  }

  /// The fee plan's Frappe primary key (e.g. `EDU-SFP-2026-00001`).
  final String id;

  /// The student the plan belongs to (e.g. `STU-00001`).
  final String student;

  /// Display name for the student. The mobile uses this as the
  /// primary row subtitle in the parent + admin lists.
  final String studentName;

  /// The academic year the plan covers (e.g. `2025/2026`).
  final String academicYear;

  /// The invoice status. One of `Draft`, `Issued`, `Paid`,
  /// `Partially Paid`, `Overdue`, `Cancelled`. The mobile
  /// renders the wire value as-is; the operations overview
  /// groups by this field.
  final String invoiceStatus;

  /// Total amount due for this plan (the sum of items before any
  /// payments or discounts).
  final double totalAmount;

  /// Total amount already paid against this plan.
  final double paidAmount;

  /// Amount still outstanding ([totalAmount] - [paidAmount] when
  /// the server doesn't compute it).
  final double outstandingAmount;

  /// The currency code the amounts are denominated in (e.g.
  /// `USD`, `EUR`, `SYP`). The mobile does not format on the
  /// client today — the wire value is rendered as a plain
  /// number with the code as a prefix.
  final String currency;

  /// When the next payment is due, if any.
  final String? dueDate;

  /// The per-line items (subjects, fees, discounts). Kept as a
  /// typed list so the detail screen can render a breakdown
  /// without re-parsing the raw map.
  final List<FeePlanItem> items;

  final JsonMap raw;

  /// True when the plan has nothing outstanding. Used by the list
  /// to surface a "Paid" chip vs. a "Due" chip.
  bool get isPaid => outstandingAmount <= 0;

  /// True when the plan is overdue (status says so on the wire).
  bool get isOverdue => invoiceStatus.toLowerCase() == 'overdue';

  /// True when the plan has at least one partial payment.
  bool get isPartiallyPaid => invoiceStatus.toLowerCase() == 'partially paid';

  @override
  List<Object?> get props => [
        id,
        student,
        studentName,
        academicYear,
        invoiceStatus,
        totalAmount,
        paidAmount,
        outstandingAmount,
        currency,
        dueDate,
        items,
      ];
}

/// A single line item on a fee plan. Surfaces the
/// description / amount pair; the full row is preserved on
/// [raw] for future fields (recurrence, tax, proration, etc.).
@immutable
class FeePlanItem extends Equatable {
  const FeePlanItem({
    required this.description,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.raw,
  });

  factory FeePlanItem.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    double? pickDouble(String key) {
      final v = json[key];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return FeePlanItem(
      description: pickString('description') ??
          pickString('fee_category') ??
          pickString('item_name') ??
          'Item',
      amount: pickDouble('amount') ?? pickDouble('total') ?? 0,
      category: pickString('category') ?? pickString('fee_category') ?? '',
      frequency: pickString('frequency') ?? '',
      raw: json,
    );
  }

  final String description;
  final double amount;
  final String category;
  final String frequency;
  final JsonMap raw;

  @override
  List<Object?> get props => [description, amount, category, frequency];
}

/// Paged list of fee plans. The v1 SDK does not expose a cursor
/// on `get_school_student_fee_plans` today, so the page is
/// "everything we fetched".
class FeePlanPage {
  const FeePlanPage({required this.plans});
  final List<FeePlan> plans;
  bool get hasMore => false;
}

/// Operations overview summary card. The wire shape is opaque;
/// the mobile renders the most common fields with safe
/// fallbacks.
@immutable
class FeeOperationsOverview extends Equatable {
  const FeeOperationsOverview({
    required this.totalInvoiced,
    required this.totalCollected,
    required this.totalOutstanding,
    required this.overdueCount,
    required this.draftCount,
    required this.paidCount,
    required this.currency,
    required this.raw,
  });

  factory FeeOperationsOverview.fromJson(JsonMap json) {
    double? pickDouble(String key) {
      final v = json[key];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    int? pickInt(String key) {
      final v = json[key];
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    return FeeOperationsOverview(
      totalInvoiced: pickDouble('total_invoiced') ??
          pickDouble('invoiced') ??
          pickDouble('grand_total') ??
          0,
      totalCollected: pickDouble('total_collected') ??
          pickDouble('collected') ??
          pickDouble('paid') ??
          0,
      totalOutstanding: pickDouble('total_outstanding') ??
          pickDouble('outstanding') ??
          pickDouble('balance') ??
          0,
      overdueCount: pickInt('overdue_count') ?? 0,
      draftCount: pickInt('draft_count') ?? 0,
      paidCount: pickInt('paid_count') ?? 0,
      currency: pickString('currency') ?? '',
      raw: json,
    );
  }

  final double totalInvoiced;
  final double totalCollected;
  final double totalOutstanding;
  final int overdueCount;
  final int draftCount;
  final int paidCount;
  final String currency;
  final JsonMap raw;

  /// Collection rate as a 0..100 percentage. Returns null when
  /// the total invoiced is zero (avoiding div-by-zero and the
  /// "0% collected" lie that would otherwise show on a fresh
  /// school).
  double? get collectionRate {
    if (totalInvoiced <= 0) return null;
    final p = (totalCollected / totalInvoiced) * 100;
    return p.isFinite ? double.parse(p.toStringAsFixed(1)) : null;
  }

  @override
  List<Object?> get props => [
        totalInvoiced,
        totalCollected,
        totalOutstanding,
        overdueCount,
        draftCount,
        paidCount,
        currency,
      ];
}
