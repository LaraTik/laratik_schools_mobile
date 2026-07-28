import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

/// A row from the `get_school_students` list.
///
/// The v1 contract returns each row as a forward-compatible [JsonMap]; the
/// fields the mobile client knows about are surfaced here as named accessors
/// while the full map is preserved on [raw] so future schema additions
/// (e.g. additional link fields, custom role tags) flow through without an
/// app update.
///
/// §1.3 of the backend DocType audit is honored at this layer:
///   * `country_was_defaulted` and `residential_country_mismatch` surface
///     to the operator as visible chips on the detail screen.
///   * The form keeps the user's input verbatim — the service layer
///     decides the canonical value and reports the flag.
@immutable
class Person extends Equatable {
  const Person({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.studentName,
    required this.guardianName,
    required this.grade,
    required this.classGroup,
    required this.academicYear,
    required this.status,
    required this.enrollmentStatus,
    required this.activationStatus,
    required this.nationality,
    required this.country,
    required this.countryWasDefaulted,
    required this.residentialCountryMismatch,
    required this.erpnextCustomer,
    required this.photoUrl,
    required this.raw,
  });

  /// Parse a `School Student` row from the wire. The v1 contract intentionally
  /// keeps the row shape opaque so the SDK stays additive; this constructor
  /// is the single place we narrow it.
  factory Person.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    bool pickBool(String key) {
      final v = json[key];
      if (v is bool) return v;
      if (v is String) {
        final s = v.toLowerCase();
        return s == 'true' || s == '1' || s == 'yes';
      }
      return false;
    }

    final firstName = pickString('first_name') ?? '';
    final lastName = pickString('last_name') ?? '';
    final fullName =
        pickString('full_name') ?? '$firstName $lastName'.trim();
    final studentName = pickString('student_name') ?? fullName;

    return Person(
      id: pickString('name') ?? pickString('id') ?? '',
      firstName: firstName,
      lastName: lastName,
      fullName: fullName,
      studentName: studentName,
      guardianName: pickString('guardian_name'),
      grade: pickString('grade'),
      classGroup: pickString('class_group') ?? pickString('classgroup'),
      academicYear: pickString('academic_year'),
      status: pickString('status') ?? 'Active',
      enrollmentStatus: pickString('enrollment_status'),
      activationStatus: pickString('activation_status'),
      nationality: pickString('nationality'),
      country: pickString('country'),
      countryWasDefaulted: pickBool('country_was_defaulted'),
      residentialCountryMismatch: pickBool('residential_country_mismatch'),
      erpnextCustomer: pickString('erpnext_customer'),
      photoUrl: pickString('photo_url') ?? pickString('image'),
      raw: json,
    );
  }

  /// The `School Student` name (e.g. `EDU-STU-2026-00001`). Stable and unique.
  final String id;

  final String firstName;
  final String lastName;
  final String fullName;
  final String studentName;

  final String? guardianName;
  final String? grade;
  final String? classGroup;
  final String? academicYear;

  /// One of `Active`, `Inactive`, `Graduated`, `Transferred`, `Withdrawn`.
  /// The wire format is preserved as-is.
  final String status;

  final String? enrollmentStatus;
  final String? activationStatus;

  final String? nationality;
  final String? country;
  final bool countryWasDefaulted;
  final bool residentialCountryMismatch;

  /// ERPNext `Customer` name created as a side-effect of student creation.
  final String? erpnextCustomer;

  final String? photoUrl;

  /// The full opaque row. Feature code MUST NOT depend on undocumented keys;
  /// if a screen needs a field the model doesn't expose, add it to this
  /// class first and surface it via a named getter.
  final JsonMap raw;

  bool get isActive => status.toLowerCase() == 'active';
  bool get hasGuardianWarning => (guardianName ?? '').isEmpty;
  bool get hasCountryWarning =>
      countryWasDefaulted || residentialCountryMismatch;

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        fullName,
        studentName,
        guardianName,
        grade,
        classGroup,
        academicYear,
        status,
        enrollmentStatus,
        activationStatus,
        nationality,
        country,
        countryWasDefaulted,
        residentialCountryMismatch,
        erpnextCustomer,
        photoUrl,
      ];
}
