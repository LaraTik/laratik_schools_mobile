import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_mobile/auth/session.dart';

void main() {
  group('SecureTokenStore.inMemory', () {
    test('round-trips access and refresh tokens', () async {
      final store = SecureTokenStore.inMemory();
      expect(await store.readAccess(), isNull);
      expect(await store.readRefresh(), isNull);

      await store.writeAccess('access-1');
      await store.writeRefresh('refresh-1');
      expect(await store.readAccess(), 'access-1');
      expect(await store.readRefresh(), 'refresh-1');

      await store.deleteAll();
      expect(await store.readAccess(), isNull);
      expect(await store.readRefresh(), isNull);
    });

    test('isolates state across instances', () async {
      final a = SecureTokenStore.inMemory();
      final b = SecureTokenStore.inMemory();
      await a.writeAccess('only-a');
      expect(await a.readAccess(), 'only-a');
      expect(await b.readAccess(), isNull);
    });
  });

  group('SecureTokenStore.noop', () {
    test('all reads return null, all writes succeed silently', () async {
      const store = SecureTokenStore.noop();
      expect(await store.readAccess(), isNull);
      expect(await store.readRefresh(), isNull);
      await store.writeAccess('x');
      await store.writeRefresh('y');
      expect(await store.readAccess(), isNull);
      expect(await store.readRefresh(), isNull);
      await store.deleteAll(); // no-op, no throw
    });
  });
}
