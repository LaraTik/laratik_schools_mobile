import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/features/people/data/student_form_payload.dart';

void main() {
  group('StudentFormPayload', () {
    test('serializes only non-empty fields to the wire', () {
      const payload = StudentFormPayload(
        firstName: 'Layla',
        lastName: 'Hassan',
        guardian: 'Aisha Hassan',
        guardianPhone: '+962791234567',
        country: 'Jordan',
        notes: '',
      );
      final json = payload.toJson();
      expect(json['first_name'], 'Layla');
      expect(json['last_name'], 'Hassan');
      expect(json['guardian'], 'Aisha Hassan');
      expect(json['guardian_phone'], '+962791234567');
      expect(json['country'], 'Jordan');
      expect(json.containsKey('notes'), isFalse);
      expect(json.containsKey('grade'), isFalse);
    });

    test('copyWith preserves omitted fields', () {
      const original = StudentFormPayload(
        firstName: 'Layla',
        lastName: 'Hassan',
        guardian: 'Aisha',
        country: 'Jordan',
      );
      final updated = original.copyWith(country: 'United Arab Emirates');
      expect(updated.country, 'United Arab Emirates');
      expect(updated.firstName, 'Layla');
      expect(updated.lastName, 'Hassan');
      expect(updated.guardian, 'Aisha');
    });

    test('copyWith can clear a field with a sentinel', () {
      const original = StudentFormPayload(
        firstName: 'Layla',
        lastName: 'Hassan',
        country: 'Jordan',
      );
      final cleared = original.copyWith(country: null);
      expect(cleared.country, isNull);
    });

    test('fromDefaults picks well-known keys', () {
      final defaults = <String, Object?>{
        'first_name': 'Layla',
        'last_name': 'Hassan',
        'guardian': 'Aisha',
        'country': 'Jordan',
      };
      final payload = StudentFormPayload.fromDefaults(defaults);
      expect(payload.firstName, 'Layla');
      expect(payload.lastName, 'Hassan');
      expect(payload.guardian, 'Aisha');
      expect(payload.country, 'Jordan');
    });

    test('toJson merges extra fields', () {
      const payload = StudentFormPayload(
        firstName: 'Layla',
        lastName: 'Hassan',
        extra: <String, Object?>{'custom_field': 'value'},
      );
      final json = payload.toJson();
      expect((json as JsonMap)['custom_field'], 'value');
    });
  });
}
