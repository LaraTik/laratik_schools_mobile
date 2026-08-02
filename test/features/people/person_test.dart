import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_mobile/features/people/data/person.dart';

void main() {
  group('Person.fromJson', () {
    test('parses well-known fields and keeps the raw map', () {
      final json = <String, Object?>{
        'name': 'EDU-STU-2026-00001',
        'first_name': 'Layla',
        'last_name': 'Hassan',
        'full_name': 'Layla Hassan',
        'student_name': 'Layla Hassan',
        'guardian_name': 'Aisha Hassan',
        'grade': 'Grade 3',
        'class_group': 'A',
        'academic_year': 'AY 2026/2027',
        'status': 'Active',
        'enrollment_status': 'Enrolled',
        'activation_status': 'Active',
        'nationality': 'Jordanian',
        'country': 'Jordan',
        'country_was_defaulted': false,
        'residential_country_mismatch': false,
        'erpnext_customer': 'CUST-0001',
        'photo_url': 'https://cdn.example.test/avatar.png',
        'school_id': 'S-2026-001',
        'extra_field_we_do_not_know_about': 'kept verbatim',
      };

      final person = Person.fromJson(json);

      expect(person.id, 'EDU-STU-2026-00001');
      expect(person.firstName, 'Layla');
      expect(person.lastName, 'Hassan');
      expect(person.fullName, 'Layla Hassan');
      expect(person.studentName, 'Layla Hassan');
      expect(person.guardianName, 'Aisha Hassan');
      expect(person.grade, 'Grade 3');
      expect(person.classGroup, 'A');
      expect(person.academicYear, 'AY 2026/2027');
      expect(person.status, 'Active');
      expect(person.nationality, 'Jordanian');
      expect(person.country, 'Jordan');
      expect(person.countryWasDefaulted, isFalse);
      expect(person.residentialCountryMismatch, isFalse);
      expect(person.erpnextCustomer, 'CUST-0001');
      expect(person.photoUrl, 'https://cdn.example.test/avatar.png');
      expect(person.isActive, isTrue);
      expect(person.hasGuardianWarning, isFalse);
      expect(person.hasCountryWarning, isFalse);
      expect(
        person.raw['extra_field_we_do_not_know_about'],
        'kept verbatim',
      );
    });

    test('surfaces §1.3 country flags', () {
      final person = Person.fromJson(<String, Object?>{
        'name': 'EDU-STU-2026-00002',
        'first_name': 'Ahmad',
        'last_name': 'Saleh',
        'status': 'Active',
        'nationality': 'Syrian',
        'country': 'Jordan',
        'country_was_defaulted': 'true',
        'residential_country_mismatch': '1',
      });

      expect(person.countryWasDefaulted, isTrue);
      expect(person.residentialCountryMismatch, isTrue);
      expect(person.hasCountryWarning, isTrue);
    });

    test('falls back to the classgroup alias when class_group is missing', () {
      final person = Person.fromJson(<String, Object?>{
        'name': 'EDU-STU-2026-00003',
        'first_name': 'Mona',
        'last_name': 'Karim',
        'classgroup': 'B',
      });
      expect(person.classGroup, 'B');
    });

    test('hasGuardianWarning true when guardian_name is empty', () {
      final person = Person.fromJson(<String, Object?>{
        'name': 'EDU-STU-2026-00004',
        'first_name': 'Khalid',
        'last_name': 'Nasser',
        'guardian_name': '',
      });
      expect(person.hasGuardianWarning, isTrue);
    });

    test('fullName falls back to student_name when first/last are missing', () {
      // The v1 list endpoint doesn't return first_name/last_name; it
      // returns `student_name` (the Frappe title field). When the row
      // has no first/last, the parser must use the student_name so
      // the dashboard's "Acting as: …" card can show a useful name
      // instead of the document id.
      final person = Person.fromJson(<String, Object?>{
        'school_student': 'STU-00061',
        'student_name': 'Aaron Test Student',
        'status': 'Active',
      });
      expect(person.fullName, 'Aaron Test Student');
      expect(person.studentName, 'Aaron Test Student');
    });
  });
}
