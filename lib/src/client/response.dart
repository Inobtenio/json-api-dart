import 'package:json_api/http.dart';
import 'package:json_api/src/client/status_code.dart';

/// A JSON:API response
class Response {
  Response(this.http);

  /// The HTTP response.
  final HttpResponse http;

  /// Was the query successful?
  ///
  /// For pending (202 Accepted) requests both [isSuccessful] and [isFailed]
  /// are always false.
  bool get isSuccessful => StatusCode(http.statusCode).isSuccessful;

  /// This property is an equivalent of `202 Accepted` HTTP status.
  /// It indicates that the query is accepted but not finished yet (e.g. queued).
  /// See: https://jsonapi.org/recommendations/#asynchronous-processing
  bool get isPending => StatusCode(http.statusCode).isPending;

  /// Any non 2** status code is considered a failed operation.
  /// For failed requests, [document] is expected to contain [ErrorDocument]
  bool get isFailed => StatusCode(http.statusCode).isFailed;
}
