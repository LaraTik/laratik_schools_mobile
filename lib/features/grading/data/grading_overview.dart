// SPDX-License-Identifier: Proprietary
// Grading admin models — overview + policies + setup context.
//
// The v1 contract returns these as forward-compatible
// [JsonMap]s; the fields the mobile knows about are
// surfaced as named accessors while the full map is
// preserved on [raw] so future schema additions (per-
// branch drill-down, per-subject grade bands, per-term
// summary cuts) flow through without an app update.
//
// The grading surface is read-mostly today (the v1 server
// grants `can_view_grading` to the academic-coordinator
// + school-admin + super-admin roles; the admin is the
// only role that sees this surface on the mobile). The
// wire-only methods (correct_school_grade_record,
// promote_school_assessment_result,
// approve_school_subject_grade_policy) are exposed for
// a future "correct a grade" / "promote a grade" /
// "approve a policy" form on the same screen.

import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

/// Top-level grading operations summary. The wire shape is
/// opaque; the [GradingOverview] factory pulls the canonical
/// fields with safe fallbacks.
@immutable
class GradingOverview extends Equatable {
  const GradingOverview({
    required this.totalGrades,
    required this.publishedGrades,
    required this.draftGrades,
    required this.averageScore,
    required this.passRate,
    required this.coverage,
    required this.feature,
    required this.recentStudents,
    required this.workflowStages,
    required this.raw,
  });

  factory GradingOverview.fromJson(JsonMap json) {
    int? pickInt(String key) {
      final v = json[key];
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    double? pickDouble(String key) {
      final v = json[key];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    // Workflow stages is a child table; the mobile renders the
    // count and the latest stage's label. The full list is
    // preserved on [raw] for a future drill-down.
    final stages = json['workflow_stages'] ?? json['stages'];
    final stageList = stages is List
        ? stages
            .whereType<Map>()
            .map((s) => GradingWorkflowStage.fromJson(
                  Map<String, Object?>.from(s),
                ))
            .toList(growable: false)
        : const <GradingWorkflowStage>[];

    return GradingOverview(
      totalGrades: pickInt('total_grades') ?? pickInt('total') ?? 0,
      publishedGrades: pickInt('published_grades') ?? pickInt('published') ?? 0,
      draftGrades: pickInt('draft_grades') ?? pickInt('draft') ?? 0,
      averageScore: pickDouble('average_score') ?? pickDouble('average') ?? 0,
      passRate: pickDouble('pass_rate') ?? pickDouble('pass_pct'),
      coverage: pickString('coverage') ?? '',
      feature: pickString('feature') ?? '',
      recentStudents: pickString('recent_students') ?? '',
      workflowStages: stageList,
      raw: json,
    );
  }

  /// Total number of grade records (published + draft) for
  /// the school. The mobile renders this as the headline
  /// KPI on the overview tab.
  final int totalGrades;

  /// Number of grades that have been promoted to a grade
  /// record (the wire value is the count of grade records
  /// where `state` is not `Draft`).
  final int publishedGrades;

  /// Number of grades still in `Draft`. The mobile renders
  /// this as a separate KPI so the admin can see "how many
  /// are still pending publish".
  final int draftGrades;

  /// School-wide average score (0..100). Null when the
  /// school has no published grades yet (avoids the
  /// "0% average on a fresh school" lie).
  final double averageScore;

  /// School-wide pass rate (0..100). Null when the school
  /// has no published grades yet. The mobile renders this
  /// as the second headline KPI on the overview tab.
  final double? passRate;

  /// Wire coverage string (e.g. `latest_year_term`,
  /// `all_years`). The mobile renders this as a sub-line.
  final String coverage;

  /// Wire feature string (e.g. `grading_admin_v1`). The
  /// mobile renders this as a sub-line for the support
  /// team to identify the version.
  final String feature;

  /// Wire "recent students" string (free-form; the wire
  /// may grow this into a list). The mobile renders it
  /// as a sub-line.
  final String recentStudents;

  /// Workflow stages (draft → submitted → promoted → ...)
  /// flattened to a list of typed triples. The mobile
  /// renders them as a row of chips so the admin can
  /// see where the pipeline is at a glance.
  final List<GradingWorkflowStage> workflowStages;

  final JsonMap raw;

  /// Pass rate as a 0..100 percentage. Returns null when
  /// no grades are published (avoids the "0% pass on a
  /// fresh school" lie).
  double? get passRatePercent {
    if (passRate == null) return null;
    if (publishedGrades <= 0) return null;
    return passRate;
  }

  @override
  List<Object?> get props => [
        totalGrades,
        publishedGrades,
        draftGrades,
        averageScore,
        passRate,
        coverage,
        feature,
        recentStudents,
        workflowStages,
      ];
}

/// A single workflow stage row. The mobile renders these
/// as a row of chips on the overview tab.
@immutable
class GradingWorkflowStage extends Equatable {
  const GradingWorkflowStage({
    required this.name,
    required this.label,
    required this.count,
    required this.toneFamily,
  });

  factory GradingWorkflowStage.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    int? pickInt(String key) {
      final v = json[key];
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return GradingWorkflowStage(
      name: pickString('name') ?? pickString('stage') ?? '',
      label: pickString('label') ?? pickString('name') ?? '',
      count: pickInt('count') ?? 0,
      toneFamily: _familyFor(pickString('tone') ?? ''),
    );
  }

  /// The wire stage name (e.g. `Draft`, `Submitted`,
  /// `Promoted`, `Corrected`). The mobile renders this
  /// as the chip's tooltip (when supported) and as the
  /// chip's data key.
  final String name;

  /// The human-readable label. The mobile renders this as
  /// the chip's primary text. Falls back to [name] when
  /// the wire doesn't include a separate label.
  final String label;

  /// The count of grade records in this stage. The mobile
  /// renders this as the chip's badge.
  final int count;

  /// The chip tone family. One of `success` / `warning` /
  /// `error` / `info` / `neutral`. The UI maps this to
  /// [LsChipTone] when rendering.
  final String toneFamily;

  /// A coarse stage name family for the chip icon. The
  /// mobile maps:
  ///   * `Draft*` → warning
  ///   * `Submitted*` / `In Progress*` / `in_progress*` → info
  ///   * `Promoted*` / `Approved*` / `Completed*` → success
  ///   * `Corrected*` → info
  ///   * `Rejected*` / `Failed*` → error
  ///   * anything else → neutral
  String get stageFamily {
    final n = name.toLowerCase().replaceAll(' ', '_');
    if (n.startsWith('draft')) return 'draft';
    if (n.startsWith('submitted') || n.startsWith('in_progress')) {
      return 'submitted';
    }
    if (n.startsWith('promoted') ||
        n.startsWith('approved') ||
        n.startsWith('completed')) {
      return 'promoted';
    }
    if (n.startsWith('corrected')) return 'corrected';
    if (n.startsWith('rejected') || n.startsWith('failed')) {
      return 'rejected';
    }
    return 'other';
  }

  static String _familyFor(String wire) {
    return switch (wire.toLowerCase()) {
      'success' || 'completed' => 'success',
      'warning' || 'pending' => 'warning',
      'error' || 'failed' => 'error',
      'info' || 'in_progress' => 'info',
      _ => 'neutral',
    };
  }

  @override
  List<Object?> get props => [name, label, count, toneFamily];
}

/// A single subject grade policy row. The wire shape is
/// open; the mobile renders the canonical display fields
/// with safe fallbacks.
@immutable
class SubjectGradePolicy extends Equatable {
  const SubjectGradePolicy({
    required this.id,
    required this.name,
    required this.subject,
    required this.gradeBand,
    required this.passThreshold,
    required this.status,
    required this.approver,
    required this.approvedAt,
    required this.raw,
  });

  factory SubjectGradePolicy.fromJson(JsonMap json) {
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

    return SubjectGradePolicy(
      id: pickString('name') ?? pickString('id') ?? '',
      name: pickString('title') ??
          pickString('policy_name') ??
          pickString('name') ??
          '',
      subject: pickString('subject') ?? pickString('school_subject') ?? '',
      gradeBand: pickString('grade_band') ?? pickString('band') ?? '',
      passThreshold:
          pickDouble('pass_threshold') ?? pickDouble('pass_pct') ?? 0,
      status: pickString('status') ?? 'Draft',
      approver: pickString('approver') ?? pickString('approved_by') ?? '',
      approvedAt: pickString('approved_at') ?? pickString('approved_on') ?? '',
      raw: json,
    );
  }

  /// The policy's Frappe primary key
  /// (e.g. `EDU-SGP-2026-00001`).
  final String id;

  /// Display name. The mobile uses this as the primary
  /// row label in the policies list.
  final String name;

  /// The subject the policy applies to (e.g.
  /// `Mathematics`, `EDU-SUB-2026-00001`). The mobile
  /// renders this as the row's subtitle.
  final String subject;

  /// The grade band (e.g. `Grade 1-5`, `Grade 6-9`,
  /// `Grade 10-12`). The mobile renders this as a chip
  /// on the row.
  final String gradeBand;

  /// The pass threshold as a 0..100 percentage. The mobile
  /// renders this as a chip on the row so the admin can
  /// compare across subjects at a glance.
  final double passThreshold;

  /// One of `Draft` / `Pending Approval` / `Approved` /
  /// `Rejected` / `Superseded`. The mobile renders this
  /// as a chip with a color tone.
  final String status;

  /// The user that approved the policy (empty when still
  /// in draft). The mobile renders this as a sub-line.
  final String approver;

  /// When the policy was approved (empty when still in
  /// draft). The mobile renders this as a sub-line.
  final String approvedAt;

  final JsonMap raw;

  /// A coarse status family for the chip tone. The mobile
  /// maps:
  ///   * `Approved` → success
  ///   * `Rejected` / `Superseded` → error
  ///   * `Pending Approval` → warning
  ///   * anything else → neutral
  String get statusFamily {
    final s = status.toLowerCase();
    if (s.contains('approved')) return 'approved';
    if (s.contains('rejected') || s.contains('superseded')) {
      return 'rejected';
    }
    if (s.contains('pending')) return 'pending';
    return 'other';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        subject,
        gradeBand,
        passThreshold,
        status,
        approver,
        approvedAt,
      ];
}

/// Paged list of subject grade policies.
@immutable
class SubjectGradePolicyPage extends Equatable {
  const SubjectGradePolicyPage({required this.policies});
  final List<SubjectGradePolicy> policies;

  @override
  List<Object?> get props => [policies];
}

/// Grading policy setup context. The wire returns the role
/// sets that govern the surface; the mobile renders the
/// readonly / required role lists as a "Permissions" section
/// on the policies tab.
@immutable
class GradingPolicySetupContext extends Equatable {
  const GradingPolicySetupContext({
    required this.doctype,
    required this.feature,
    required this.managedDoctypes,
    required this.readRoles,
    required this.requiredRoles,
    required this.nativeLinks,
    required this.raw,
  });

  factory GradingPolicySetupContext.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    JsonMap? pickMap(String key) {
      final v = json[key];
      if (v is Map) return Map<String, Object?>.from(v);
      return null;
    }

    return GradingPolicySetupContext(
      doctype: pickString('doctype') ?? '',
      feature: pickString('feature') ?? '',
      managedDoctypes: pickString('managed_doctypes') ?? '',
      readRoles: switch (json['read_roles']) {
        final List list => List<String>.from(list),
        _ => const <String>[],
      },
      requiredRoles: switch (json['required_roles']) {
        final List list => List<String>.from(list),
        _ => const <String>[],
      },
      nativeLinks: pickMap('native_links') ?? const <String, Object?>{},
      raw: json,
    );
  }

  /// The DocType this setup context governs.
  final String doctype;

  /// The wire feature string (e.g. `grading_admin_v1`).
  final String feature;

  /// The set of managed DocTypes (e.g. `School Subject Grade
  /// Policy,School Assessment Result`). The mobile renders
  /// this as a sub-line.
  final String managedDoctypes;

  /// Roles that can view grading. The mobile renders this
  /// as a chip strip.
  final List<String> readRoles;

  /// Roles required to approve a policy. The mobile renders
  /// this as a chip strip.
  final List<String> requiredRoles;

  final JsonMap nativeLinks;

  final JsonMap raw;

  @override
  List<Object?> get props => [
        doctype,
        feature,
        managedDoctypes,
        readRoles,
        requiredRoles,
      ];
}
