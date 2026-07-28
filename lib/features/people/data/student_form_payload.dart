import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

/// Immutable form state for the student create flow.
///
/// The form layer mutates a working copy, the repository serializes the
/// final state via [toJson] and ships it as the v1 `payload`. The field
/// set is the union of the documented `School Student` fields Phase 1
/// actually edits; the underlying `raw` map on [StudentFormPayload] lets
/// the form surface schema fields the typed model doesn't know about yet.
@immutable
class StudentFormPayload extends Equatable {
  const StudentFormPayload({
    required this.firstName,
    required this.lastName,
    this.guardian,
    this.guardianEmail,
    this.guardianPhone,
    this.nationality,
    this.country,
    this.gender,
    this.dateOfBirth,
    this.grade,
    this.classGroup,
    this.academicYear,
    this.schoolStudentNumber,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.postalCode,
    this.emergencyContact,
    this.emergencyPhone,
    this.notes,
    this.extra = const <String, Object?>{},
  });

  /// Best-effort decode of a server default block (from
  /// `get_student_setup_context.defaults`) into a working form payload.
  factory StudentFormPayload.fromDefaults(JsonMap defaults) {
    String? pick(String k) => defaults[k] is String ? defaults[k] as String : null;
    return StudentFormPayload(
      firstName: pick('first_name') ?? '',
      lastName: pick('last_name') ?? '',
      guardian: pick('guardian'),
      guardianEmail: pick('guardian_email'),
      guardianPhone: pick('guardian_phone'),
      nationality: pick('nationality'),
      country: pick('country'),
      gender: pick('gender'),
      dateOfBirth: pick('date_of_birth'),
      grade: pick('grade'),
      classGroup: pick('class_group'),
      academicYear: pick('academic_year'),
      schoolStudentNumber: pick('school_student_number'),
      addressLine1: pick('address_line_1'),
      addressLine2: pick('address_line_2'),
      city: pick('city'),
      postalCode: pick('postal_code'),
      emergencyContact: pick('emergency_contact'),
      emergencyPhone: pick('emergency_phone'),
      notes: pick('notes'),
    );
  }

  final String firstName;
  final String lastName;
  final String? guardian;
  final String? guardianEmail;
  final String? guardianPhone;
  final String? nationality;
  final String? country;
  final String? gender;
  final String? dateOfBirth;
  final String? grade;
  final String? classGroup;
  final String? academicYear;
  final String? schoolStudentNumber;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? postalCode;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? notes;

  /// Free-form fields. Reserved for additive schema entries the typed
  /// payload doesn't yet know about. Phase 1 leaves this empty.
  final JsonMap extra;

  StudentFormPayload copyWith({
    String? firstName,
    String? lastName,
    Object? guardian = _noChange,
    Object? guardianEmail = _noChange,
    Object? guardianPhone = _noChange,
    Object? nationality = _noChange,
    Object? country = _noChange,
    Object? gender = _noChange,
    Object? dateOfBirth = _noChange,
    Object? grade = _noChange,
    Object? classGroup = _noChange,
    Object? academicYear = _noChange,
    Object? schoolStudentNumber = _noChange,
    Object? addressLine1 = _noChange,
    Object? addressLine2 = _noChange,
    Object? city = _noChange,
    Object? postalCode = _noChange,
    Object? emergencyContact = _noChange,
    Object? emergencyPhone = _noChange,
    Object? notes = _noChange,
    JsonMap? extra,
  }) {
    return StudentFormPayload(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      guardian: _resolved(guardian, this.guardian),
      guardianEmail: _resolved(guardianEmail, this.guardianEmail),
      guardianPhone: _resolved(guardianPhone, this.guardianPhone),
      nationality: _resolved(nationality, this.nationality),
      country: _resolved(country, this.country),
      gender: _resolved(gender, this.gender),
      dateOfBirth: _resolved(dateOfBirth, this.dateOfBirth),
      grade: _resolved(grade, this.grade),
      classGroup: _resolved(classGroup, this.classGroup),
      academicYear: _resolved(academicYear, this.academicYear),
      schoolStudentNumber:
          _resolved(schoolStudentNumber, this.schoolStudentNumber),
      addressLine1: _resolved(addressLine1, this.addressLine1),
      addressLine2: _resolved(addressLine2, this.addressLine2),
      city: _resolved(city, this.city),
      postalCode: _resolved(postalCode, this.postalCode),
      emergencyContact: _resolved(emergencyContact, this.emergencyContact),
      emergencyPhone: _resolved(emergencyPhone, this.emergencyPhone),
      notes: _resolved(notes, this.notes),
      extra: extra ?? this.extra,
    );
  }

  /// Serialize to the v1 wire shape. Empty fields are dropped; the backend
  /// applies its own defaults. The §1.3 service invariant lives on the
  /// server — we just send what the operator typed.
  JsonMap toJson() {
    return <String, Object?>{
      'first_name': firstName,
      'last_name': lastName,
      if (guardian != null && guardian!.isNotEmpty) 'guardian': guardian,
      if (guardianEmail != null && guardianEmail!.isNotEmpty)
        'guardian_email': guardianEmail,
      if (guardianPhone != null && guardianPhone!.isNotEmpty)
        'guardian_phone': guardianPhone,
      if (nationality != null && nationality!.isNotEmpty)
        'nationality': nationality,
      if (country != null && country!.isNotEmpty) 'country': country,
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      if (dateOfBirth != null && dateOfBirth!.isNotEmpty)
        'date_of_birth': dateOfBirth,
      if (grade != null && grade!.isNotEmpty) 'grade': grade,
      if (classGroup != null && classGroup!.isNotEmpty)
        'class_group': classGroup,
      if (academicYear != null && academicYear!.isNotEmpty)
        'academic_year': academicYear,
      if (schoolStudentNumber != null && schoolStudentNumber!.isNotEmpty)
        'school_student_number': schoolStudentNumber,
      if (addressLine1 != null && addressLine1!.isNotEmpty)
        'address_line_1': addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty)
        'address_line_2': addressLine2,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (postalCode != null && postalCode!.isNotEmpty)
        'postal_code': postalCode,
      if (emergencyContact != null && emergencyContact!.isNotEmpty)
        'emergency_contact': emergencyContact,
      if (emergencyPhone != null && emergencyPhone!.isNotEmpty)
        'emergency_phone': emergencyPhone,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      ...extra,
    };
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        guardian,
        guardianEmail,
        guardianPhone,
        nationality,
        country,
        gender,
        dateOfBirth,
        grade,
        classGroup,
        academicYear,
        schoolStudentNumber,
        addressLine1,
        addressLine2,
        city,
        postalCode,
        emergencyContact,
        emergencyPhone,
        notes,
      ];

  static const Object _noChange = Object();

  static T? _resolved<T>(Object marker, T? current) {
    if (identical(marker, _noChange)) return current;
    return marker as T?;
  }
}
