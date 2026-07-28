import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

@immutable
class GuardianFormPayload extends Equatable {
  const GuardianFormPayload({
    required this.guardianName,
    this.relation,
    this.phone,
    this.email,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.postalCode,
    this.country,
    this.nationality,
    this.occupation,
    this.linkedStudents = const <String>[],
    this.extra = const <String, Object?>{},
  });

  factory GuardianFormPayload.fromDefaults(JsonMap defaults) {
    String? pick(String k) =>
        defaults[k] is String ? defaults[k] as String : null;
    final linked = defaults['students'];
    final linkedList = linked is List
        ? linked.map((e) => e is String ? e : e.toString()).toList()
        : const <String>[];
    return GuardianFormPayload(
      guardianName: pick('guardian_name') ?? '',
      relation: pick('relation'),
      phone: pick('phone'),
      email: pick('email'),
      addressLine1: pick('address_line_1'),
      addressLine2: pick('address_line_2'),
      city: pick('city'),
      postalCode: pick('postal_code'),
      country: pick('country'),
      nationality: pick('nationality'),
      occupation: pick('occupation'),
      linkedStudents: linkedList,
    );
  }

  final String guardianName;
  final String? relation;
  final String? phone;
  final String? email;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? nationality;
  final String? occupation;
  final List<String> linkedStudents;
  final JsonMap extra;

  GuardianFormPayload copyWith({
    String? guardianName,
    Object? relation = _noChange,
    Object? phone = _noChange,
    Object? email = _noChange,
    Object? addressLine1 = _noChange,
    Object? addressLine2 = _noChange,
    Object? city = _noChange,
    Object? postalCode = _noChange,
    Object? country = _noChange,
    Object? nationality = _noChange,
    Object? occupation = _noChange,
    List<String>? linkedStudents,
    JsonMap? extra,
  }) {
    return GuardianFormPayload(
      guardianName: guardianName ?? this.guardianName,
      relation: _resolved(relation, this.relation),
      phone: _resolved(phone, this.phone),
      email: _resolved(email, this.email),
      addressLine1: _resolved(addressLine1, this.addressLine1),
      addressLine2: _resolved(addressLine2, this.addressLine2),
      city: _resolved(city, this.city),
      postalCode: _resolved(postalCode, this.postalCode),
      country: _resolved(country, this.country),
      nationality: _resolved(nationality, this.nationality),
      occupation: _resolved(occupation, this.occupation),
      linkedStudents: linkedStudents ?? this.linkedStudents,
      extra: extra ?? this.extra,
    );
  }

  JsonMap toJson() {
    return <String, Object?>{
      'guardian_name': guardianName,
      if (relation != null && relation!.isNotEmpty) 'relation': relation,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (addressLine1 != null && addressLine1!.isNotEmpty)
        'address_line_1': addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty)
        'address_line_2': addressLine2,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (postalCode != null && postalCode!.isNotEmpty)
        'postal_code': postalCode,
      if (country != null && country!.isNotEmpty) 'country': country,
      if (nationality != null && nationality!.isNotEmpty)
        'nationality': nationality,
      if (occupation != null && occupation!.isNotEmpty)
        'occupation': occupation,
      if (linkedStudents.isNotEmpty) 'students': linkedStudents,
      ...extra,
    };
  }

  @override
  List<Object?> get props => [
        guardianName,
        relation,
        phone,
        email,
        addressLine1,
        addressLine2,
        city,
        postalCode,
        country,
        nationality,
        occupation,
        linkedStudents,
      ];

  static const Object _noChange = Object();

  static T? _resolved<T>(Object? marker, T? current) {
    if (identical(marker, _noChange)) return current;
    return marker as T?;
  }
}
