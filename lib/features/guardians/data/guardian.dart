import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

/// A row from the `get_school_guardians` list.
///
/// The School Guardian DocType is linked to one or more School Students.
/// The wire format is forward-compatible: the linked students list is
/// preserved verbatim on [linkedStudents] for the screen layer to render.
@immutable
class Guardian extends Equatable {
  const Guardian({
    required this.id,
    required this.guardianName,
    required this.relation,
    required this.phone,
    required this.email,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.postalCode,
    required this.country,
    required this.nationality,
    required this.occupation,
    required this.status,
    required this.linkedStudents,
    required this.raw,
  });

  factory Guardian.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    final linkedStudents = (json['students'] ?? json['linked_students'])
        is List
        ? List<JsonMap>.from(
            ((json['students'] ?? json['linked_students']) as List)
                .where((e) => e is Map)
                .map((e) => Map<String, Object?>.from(e as Map)),
          )
        : const <JsonMap>[];

    return Guardian(
      id: pickString('name') ?? pickString('id') ?? '',
      guardianName: pickString('guardian_name') ?? '',
      relation: pickString('relation') ?? pickString('relationship'),
      phone: pickString('phone') ?? pickString('mobile_no'),
      email: pickString('email'),
      addressLine1: pickString('address_line_1'),
      addressLine2: pickString('address_line_2'),
      city: pickString('city'),
      postalCode: pickString('postal_code'),
      country: pickString('country'),
      nationality: pickString('nationality'),
      occupation: pickString('occupation'),
      status: pickString('status') ?? 'Active',
      linkedStudents: linkedStudents,
      raw: json,
    );
  }

  final String id;
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
  final String status;
  final List<JsonMap> linkedStudents;
  final JsonMap raw;

  bool get isActive => status.toLowerCase() == 'active';

  /// Stable subtitle for the list row. The wire shape can carry either a
  /// relation (preferred) or a phone number.
  String get subtitle {
    if (relation != null && relation!.isNotEmpty) return relation!;
    if (phone != null && phone!.isNotEmpty) return phone!;
    return 'Guardian';
  }

  /// Flat list of student names extracted from the link rows. Used to
  /// show the children count on the list row and the children list on
  /// the detail screen.
  List<String> get linkedStudentNames => linkedStudents
      .map((s) => (s['student_name'] ?? s['name'] ?? '').toString())
      .where((s) => s.isNotEmpty)
      .toList(growable: false);

  @override
  List<Object?> get props => [
        id,
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
        status,
        linkedStudents,
      ];
}
