/// Time abstraction so the auth, sync, and cache layers are testable without
/// the system clock.
library;

abstract class Clock {
  DateTime nowUtc();
  DateTime nowLocal();
}

class SystemClock implements Clock {
  SystemClock([DateTime Function()? now]) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  @override
  DateTime nowUtc() => _now().toUtc();

  @override
  DateTime nowLocal() => _now().toLocal();
}

/// Fixed clock for tests and replay. Returns the same instant for every call.
class FixedClock implements Clock {
  FixedClock(this._instant);

  final DateTime _instant;

  @override
  DateTime nowUtc() => _instant.toUtc();

  @override
  DateTime nowLocal() => _instant.toLocal();
}
