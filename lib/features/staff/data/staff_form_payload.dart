import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

/// Immutable form state for the staff create flow.
///
/// The wire shape matches the v1 `School Staff` DocType. Empty fields are
/// dropped server-side; the repository is responsible for the idempotency
/// key (UUIDv4) on the create call.
@immutable
class StaffFormPayload extends Equatable {
  const StaffFormPayload({
    required this.firstName,
    required this.lastName,
    this.staffRole,
    this.gender,
    this.nationality,
    this.country,
    this.branch,
    this.dateOfJoining,
    this.email,
    this.phone,
    this.notes,
    this.extra = const <String, Object?>{},
  });

  factory StaffFormPayload.fromDefaults(JsonMap defaults) {
    String? pick(String k) => defaults[k] is String ? defaults[k] as String : null;
    return StaffFormPayload(
      firstName: pick('first_name') ?? '',
      lastName: pick('last_name') ?? '',
      staffRole: pick('staff_role'),
      gender: pick('gender'),
      nationality: pick('nationality'),
      country: pick('country'),
      branch: pick('branch'),
      dateOfJoining: pick('date_of_joining'),
      email: pick('email'),
      phone: pick('phone'),
      notes: pick('notes'),
    );
  }

  final String firstName;
  final String lastName;
  final String? staffRole;
  final String? gender;
  final String? nationality;
  final String? country;
  final String? branch;
  final String? dateOfJoining;
  final String? email;
  final String? phone;
  final String? notes;
  final JsonMap extra;

  StaffFormPayload copyWith({
    String? firstName,
    String? lastName,
    Object? staffRole = _noChange,
    Object? gender = _noChange,
    Object? nationality = _noChange,
    Object? country = _noChange,
    Object? branch = _noChange,
    Object? dateOfJoining = _noChange,
    Object? email = _noChange,
    Object? phone = _noChange,
    Object? notes = _noChange,
    JsonMap? extra,
  }) {
    return StaffFormPayload(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      staffRole: _resolved(staffRole, this.staffRole),
      gender: _resolved(gender, this.gender),
      nationality: _resolved(nationality, this.nationality),
      country: _resolved(country, this.country),
      branch: _resolved(branch, this.branch),
      dateOfJoining: _resolved(dateOfJoining, this.dateOfJoining),
      email: _resolved(email, this.email),
      phone: _resolved(phone, this.phone),
      notes: _resolved(notes, this.notes),
      extra: extra ?? this.extra,
    );
  }

  JsonMap toJson() {
    return <String, Object?>{
      'first_name': firstName,
      'last_name': lastName,
      if (staffRole != null && staffRole!.isNotEmpty) 'staff_role': staffRole,
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      if (nationality != null && nationality!.isNotEmpty)
        'nationality': nationality,
      if (country != null && country!.isNotEmpty) 'country': country,
      if (branch != null && branch!.isNotEmpty) 'branch': branch,
      if (dateOfJoining != null && dateOfJoining!.isNotEmpty)
        'date_of_joining': dateOfJoining,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      ...extra,
    };
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        staffRole,
        gender,
        nationality,
        country,
        branch,
        dateOfJoining,
        email,
        phone,
        notes,
      ];

  static const Object _noChange = Object();

  static T? _resolved<T>(Object marker, T? current) {
    if (identical(marker, _noChange)) return current;
    return marker as T?;
  }
}
