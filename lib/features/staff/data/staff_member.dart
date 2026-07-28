import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

/// A row from the `get_school_staff` list.
///
/// Mirrors the v1 `School Staff` DocType and the wire shape produced by
/// `laratik_schools.core.staff.create_school_staff_records`. The forward-
/// compatible raw map is preserved on [raw] so future schema additions
/// (additional link fields, role tags) flow through without an app update.
@immutable
class StaffMember extends Equatable {
  const StaffMember({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.staffName,
    required this.staffRole,
    required this.gender,
    required this.nationality,
    required this.country,
    required this.branch,
    required this.status,
    required this.dateOfJoining,
    required this.erpnextEmployee,
    required this.user,
    required this.photoUrl,
    required this.raw,
  });

  factory StaffMember.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    final firstName = pickString('first_name') ?? '';
    final lastName = pickString('last_name') ?? '';
    final fullName = pickString('full_name') ?? '$firstName $lastName'.trim();
    final staffName = pickString('staff_name') ?? fullName;

    return StaffMember(
      id: pickString('name') ?? pickString('id') ?? '',
      firstName: firstName,
      lastName: lastName,
      fullName: fullName,
      staffName: staffName,
      staffRole: pickString('staff_role') ?? pickString('role'),
      gender: pickString('gender'),
      nationality: pickString('nationality'),
      country: pickString('country'),
      branch: pickString('branch'),
      status: pickString('status') ?? 'Active',
      dateOfJoining: pickString('date_of_joining'),
      erpnextEmployee: pickString('erpnext_employee'),
      user: pickString('user'),
      photoUrl: pickString('photo_url') ?? pickString('image'),
      raw: json,
    );
  }

  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String staffName;
  final String? staffRole;
  final String? gender;
  final String? nationality;
  final String? country;
  final String? branch;
  final String status;
  final String? dateOfJoining;
  final String? erpnextEmployee;
  final String? user;
  final String? photoUrl;
  final JsonMap raw;

  bool get isActive => status.toLowerCase() == 'active';

  /// The school's local staff number, used for QR badges and operator
  /// scan-and-search. Wire shape first, document name as fallback.
  String? get schoolStaffNumber {
    final raw = this.raw['school_staff_number'];
    if (raw is String && raw.isNotEmpty) return raw;
    return id.isEmpty ? null : id;
  }

  /// Best-effort role classification for the chip tone. The wire carries
  /// whatever string the server emits, so unknown values fall back to
  /// neutral.
  bool get isTeachingRole {
    final role = (staffRole ?? '').toLowerCase();
    return role.contains('teacher') || role.contains('instructor');
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        fullName,
        staffName,
        staffRole,
        gender,
        nationality,
        country,
        branch,
        status,
        dateOfJoining,
        erpnextEmployee,
        user,
        photoUrl,
      ];
}
