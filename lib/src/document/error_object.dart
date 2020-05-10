import 'package:json_api/document.dart';
import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/nullable.dart';

/// [ErrorObject] represents an error occurred on the server.
///
/// More on this: https://jsonapi.org/format/#errors
class ErrorObject {
  /// Creates an instance of a JSON:API Error.
  /// The [links] map may contain custom links. The about link
  /// passed through the [links['about']] argument takes precedence and will overwrite
  /// the `about` key in [links].
  ErrorObject({
    String id,
    String status,
    String code,
    String title,
    String detail,
    Map<String, Object> meta,
    ErrorSource source,
    Map<String, Link> links,
  })  : id = id ?? '',
        status = status ?? '',
        code = code ?? '',
        title = title ?? '',
        detail = detail ?? '',
        source = source ?? ErrorSource(),
        meta = Map.unmodifiable(meta ?? {}),
        links = Map.unmodifiable(links ?? {});

  static ErrorObject fromJson(Object json) {
    if (json is Map) {
      return ErrorObject(
          id: json['id'],
          status: json['status'],
          code: json['code'],
          title: json['title'],
          detail: json['detail'],
          source: nullable(ErrorSource.fromJson)(json['source']),
          meta: json['meta'],
          links: nullable(Link.mapFromJson)(json['links']));
    }
    throw DocumentException('A JSON:API error must be a JSON object');
  }

  /// A unique identifier for this particular occurrence of the problem.
  /// May be empty.
  final String id;

  /// The HTTP status code applicable to this problem, expressed as a string value.
  /// May be empty.
  final String status;

  /// An application-specific error code, expressed as a string value.
  /// May be empty.
  final String code;

  /// A short, human-readable summary of the problem that SHOULD NOT change
  /// from occurrence to occurrence of the problem, except for purposes of localization.
  /// May be empty.
  final String title;

  /// A human-readable explanation specific to this occurrence of the problem.
  /// Like title, this field’s value can be localized.
  /// May be empty.
  final String detail;

  /// The `source` object.
  final ErrorSource source;

  final Map<String, Object> meta;
  final Map<String, Link> links;

  Map<String, Object> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (status.isNotEmpty) 'status': status,
      if (code.isNotEmpty) 'code': code,
      if (title.isNotEmpty) 'title': title,
      if (detail.isNotEmpty) 'detail': detail,
      if (meta.isNotEmpty) 'meta': meta,
      if (links.isNotEmpty) 'links': links,
      if (source.isNotEmpty) 'source': source,
    };
  }
}

/// An object containing references to the source of the error, optionally including any of the following members:
/// - pointer: a JSON Pointer (RFC6901) to the associated entity in the request document,
///   e.g. "/data" for a primary data object, or "/data/attributes/title" for a specific attribute.
/// - parameter: a string indicating which URI query parameter caused the error.
class ErrorSource {
  ErrorSource({String pointer, String parameter})
      : pointer = pointer ?? '',
        parameter = parameter ?? '';

  static ErrorSource fromJson(Object json) {
    if (json is Map) {
      return ErrorSource(
          pointer: json['pointer'], parameter: json['parameter']);
    }
    throw DocumentException('Can not parse ErrorSource');
  }

  final String pointer;

  final String parameter;

  bool get isNotEmpty => pointer.isNotEmpty || parameter.isNotEmpty;

  Map<String, Object> toJson() => {
        if (pointer.isNotEmpty) 'pointer': pointer,
        if (parameter.isNotEmpty) 'parameter': parameter
      };
}
