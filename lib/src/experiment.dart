
import 'dart:collection';

class Document with Meta {
  Document({Api api, Map<String, Object> meta}) : api = api ?? Api() {
    this.meta.addAll(meta ?? {});
  }

  static const contentType = 'application/vnd.api+json';

  final Api api;

  Map<String, Object> toJson() => {
    'meta': meta,
    if (api.isNonTrivial) 'jsonapi': api,
  };
}

class DataDocument<D> extends Document with Links {
  DataDocument(this.data,
      {Map<String, Object> meta, Map<String, Link> links, Api api})
      : super(api: api, meta: meta) {
    ArgumentError.checkNotNull(data, 'data');
    this.links.addAll(links ?? {});
  }

  final D data;

  @override
  Map<String, Object> toJson() => {
    'data': data,
    if (meta.isNotEmpty) 'meta': meta,
    if (api.isNonTrivial) 'jsonapi': api,
  };
}

class CompoundDocument<D> extends DataDocument<D> {
  CompoundDocument(D data, Iterable<Resource> included,
      {Map<String, Object> meta, Map<String, Link> links, Api api})
      : super(data, meta: meta, links: links, api: api) {
    this.included.addAll(included);
  }

  final included = <Resource>[];

  @override
  Map<String, Object> toJson() => super.toJson()..['included'] = included;
}

class Resource extends ResourceBase {
  Resource(this.type, this.id,
      {Map<String, Object> meta,
        Map<String, Object> attributes,
        Map<String, Relationship> relationships}) {
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(id, 'id');
    this.meta.addAll(meta ?? {});
    this.attributes.addAll(attributes ?? {});
    this.relationships.addAll(relationships ?? {});
  }

  final String type;
  final String id;

  @override
  Map<String, Object> toJson() => super.toJson()
    ..['type'] = type
    ..['id'] = id;
}

class NewResource extends ResourceBase {
  NewResource(this.type,
      {Map<String, Object> meta,
        Map<String, Object> attributes,
        Map<String, Relationship> relationships}) {
    ArgumentError.checkNotNull(type, 'type');
    this.meta.addAll(meta ?? {});
    this.attributes.addAll(attributes ?? {});
    this.relationships.addAll(relationships ?? {});
  }

  final String type;

  @override
  Map<String, Object> toJson() => super.toJson()..['type'] = type;
}

abstract class ResourceBase with Meta {
  final attributes = <String, Object>{};
  final relationships = <String, Relationship>{};

  Map<String, Object> toJson() => {
    if (meta.isNotEmpty) 'meta': meta,
    if (attributes.isNotEmpty) 'attributes': attributes,
    if (relationships.isNotEmpty) 'relationship': relationships,
  };
}

class Relationship with Meta, Links {}

class ToOne
    with Meta, Links, IterableMixin<Identifier>
    implements Relationship, Iterable<Identifier> {
  ToOne(Identifier identifier) {
    ArgumentError.checkNotNull(identifier, 'identifier');
    _identifiers.add(identifier);
  }

  ToOne.empty();

  Identifier orElse(Identifier val) => isNotEmpty ? _identifiers.first : val;

  Identifier orElseGet(Identifier Function() getValue) =>
      isNotEmpty ? _identifiers.first : getValue();

  Identifier orElseThrow(Object Function() getThrowable) =>
      isNotEmpty ? _identifiers.first : throw getThrowable();

  final _identifiers = <Identifier>[];

  @override
  Iterator<Identifier> get iterator => _identifiers.iterator;
}

class ToMany
    with Meta, Links, IterableMixin<Identifier>
    implements Relationship, Iterable<Identifier> {
  ToMany(Iterable<Identifier> identifiers) {
    _identifiers.addAll(identifiers);
  }

  final _identifiers = <Identifier>[];

  @override
  Iterator<Identifier> get iterator => _identifiers.iterator;
}

class Identifier with Meta {
  Identifier(this.type, this.id, {Map<String, Object> meta}) {
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(id, 'id');
    this.meta.addAll(meta ?? {});
  }

  final String type;
  final String id;
}

class ErrorDocument extends Document {
  ErrorDocument(
      {Map<String, Object> meta, Iterable<ErrorObject> errors, Api api})
      : super(api: api, meta: meta) {
    this.errors.addAll(errors ?? []);
  }

  final errors = <ErrorObject>[];
}

/// [ErrorObject] represents an error occurred on the server.
///
/// More on this: https://jsonapi.org/format/#errors
class ErrorObject with Meta, Links {
  ErrorObject(
      {String id,
        String status,
        String code,
        String title,
        String detail,
        ErrorSource source,
        Map<String, Object> meta,
        Map<String, Link> links})
      : id = id ?? '',
        status = status ?? '',
        code = code ?? '',
        title = title ?? '',
        detail = detail ?? '',
        source = source ?? ErrorSource() {
    this.meta.addAll(meta ?? {});
    this.links.addAll(links ?? {});
  }

  /// Creates an instance of a JSON:API Error.

  static ErrorObject fromJson(Object json) {
    if (json is Map) {
      final e = ErrorObject(
          id: json['id'],
          status: json['status'],
          code: json['code'],
          title: json['title'],
          detail: json['detail'],
          source: nullable(ErrorSource.fromJson)(json['source']));
      if (json['meta'] is Map) {
        e.meta.addAll(json['meta']);
      }
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

  /// The error source
  final ErrorSource source;

  Map<String, Object> toJson() => {
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

/// An object containing references to the source of the error, optionally including any of the following members:
/// - pointer: a JSON Pointer (RFC6901) to the associated entity in the request document,
///   e.g. "/data" for a primary data object, or "/data/attributes/title" for a specific attribute.
/// - parameter: a string indicating which URI query parameter caused the error.
class ErrorSource {
  ErrorSource({String pointer, String parameter})
      : pointer = pointer ?? '',
        parameter = parameter ?? '';

  final String pointer;
  final String parameter;

  static ErrorSource fromJson(Object json) {
    if (json is Map) {
      return ErrorSource(
          parameter: json['parameter'], pointer: json['pointer']);
    }
    throw DocumentException('A JSON:API error source must be a JSON object');
  }

  bool get isNotEmpty => pointer.isNotEmpty || parameter.isNotEmpty;

  Map<String, Object> toJson() => {
    if (pointer.isNotEmpty) 'pointer': pointer,
    if (parameter.isNotEmpty) 'parameter': parameter,
  };
}

class Api with Meta {
  Api({this.version = v1}) {
    ArgumentError.checkNotNull(version, 'version');
  }

  static const v1 = '1.0';

  final String version;

  bool get isNonTrivial => meta.isNotEmpty || version != v1;

  Map<String, Object> toJson() => {
    if (meta.isNotEmpty) 'meta': meta,
    if (version != v1) 'version': version
  };
}

/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link with Meta {
  Link(this.uri) {
    ArgumentError.checkNotNull(uri, 'uri');
  }

  final Uri uri;

  /// Reconstructs the link from the [json] object
  static Link fromJson(Object json) {
    if (json is String) return Link(Uri.parse(json));
    if (json is Map) {
      return Link(Uri.parse(json['href']))..meta.addAll(json['meta'] ?? {});
    }
    throw DocumentException(
        'A JSON:API link must be a JSON string or a JSON object');
  }

  /// Reconstructs the document's `links` member into a map.
  /// Details on the `links` member: https://jsonapi.org/format/#document-links
  static Map<String, Link> mapFromJson(Object json) {
    if (json is Map) {
      return json.map((k, v) => MapEntry(k.toString(), Link.fromJson(v)));
    }
    throw DocumentException('A JSON:API links object must be a JSON object');
  }

  Object toJson() =>
      meta.isEmpty ? uri.toString() : {'href': uri.toString(), 'meta': meta};

  @override
  String toString() => uri.toString();
}

mixin Meta {
  /// A meta object containing non-standard meta-information. May be empty.
  final meta = <String, Object>{};
}

mixin Links {
  /// The `links` object.
  /// May be empty.
  /// https://jsonapi.org/format/#document-links
  final links = <String, Link>{};
}

/// Indicates a violation of JSON:API Document structure or data constraints.
class DocumentException implements Exception {
  DocumentException(this.message);

  /// Human-readable text explaining the issue.
  final String message;
}

U Function(V v) nullable<V, U>(U Function(V v) f) =>
        (v) => v == null ? null : f(v);
