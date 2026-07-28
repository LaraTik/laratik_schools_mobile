// SPDX-License-Identifier: Proprietary
// Test fake for the v1 SDK client.
//
// The generated `LaratikSchoolsApiClient` is a `final class` and
// therefore cannot be implemented or extended outside of the SDK
// library. mocktail's `Mock` shim is a no-go for the same reason.
//
// The v1 transport, by contrast, is an `abstract interface class` and
// CAN be implemented by tests. The production wiring is
// `LaratikSchoolsApiClient(transport)` — feature code never touches
// the transport directly, so the cleanest test seam is the transport
// itself.
//
// Each test queues one or more canned response envelopes keyed by the
// SDK method name (`LaratikSchoolsApiMethods.*`). The fake routes
// the next invocation through the queue and surfaces a `StateError`
// if no response is queued (which is almost always a missing stub).

import 'package:laratik_schools_api/laratik_schools_api.dart';

/// Hand-rolled fake of the v1 transport that returns canned wire
/// envelopes. Tests build the wire shape with [envelopeOk] /
/// [envelopeErr] and push it into the queue.
class FakeLaratikSchoolsTransport implements LaratikSchoolsTransport {
  final Map<String, List<JsonMap>> _queue = {};
  final List<String> _invokedMethods = [];

  /// Read-only list of method names the fake has seen, in call order.
  /// Useful for assertions like "the controller called the
  /// eligibility endpoint before the attempt endpoint".
  List<String> get invokedMethods => List.unmodifiable(_invokedMethods);

  /// Queue one or more wire envelopes to be returned for [method] in
  /// order. The first invocation consumes the first envelope, etc.
  void enqueue(String method, List<JsonMap> envelopes) {
    _queue.putIfAbsent(method, () => []).addAll(envelopes);
  }

  /// Convenience for a single canned response.
  void respondOnce(String method, JsonMap envelope) =>
      enqueue(method, [envelope]);

  /// Convenience for an error-only response.
  void respondError(String method, ApiError error) =>
      respondOnce(method, envelopeErr(error));

  @override
  Future<JsonMap> invoke({
    required String method,
    required HttpVerb verb,
    JsonMap arguments = const {},
    String? idempotencyKey,
  }) async {
    _invokedMethods.add(method);
    final queue = _queue[method];
    if (queue == null || queue.isEmpty) {
      throw StateError(
        'No stub queued for $method. Call enqueue() / respondOnce() '
        'in setUp or arrange the test to expect an error.',
      );
    }
    return queue.removeAt(0);
  }
}

/// Build a wire envelope whose `data` block is [dataJson]. The SDK
/// will run the typed data factory against it.
JsonMap envelopeOk(
  Map<String, Object?> dataJson, {
  String requestId = 'test-req',
  String apiVersion = 'v1',
  List<Object?> warnings = const <Object?>[],
}) {
  return <String, Object?>{
    'data': dataJson,
    'error': null,
    'meta': <String, Object?>{
      'api_version': apiVersion,
      'request_id': requestId,
    },
    'warnings': warnings,
  };
}

/// Build a wire envelope with a typed error and no data.
JsonMap envelopeErr(
  ApiError error, {
  String requestId = 'test-req',
  String apiVersion = 'v1',
  List<Object?> warnings = const <Object?>[],
}) {
  return <String, Object?>{
    'data': null,
    'error': error.toJson(),
    'meta': <String, Object?>{
      'api_version': apiVersion,
      'request_id': requestId,
    },
    'warnings': warnings,
  };
}

/// Common default metadata for tests.
ApiMeta defaultMeta({String requestId = 'test-req'}) =>
    ApiMeta(apiVersion: 'v1', requestId: requestId);
