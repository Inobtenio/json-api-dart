import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/client/response.dart';

abstract class Request<R extends Response> {
  static const noPayloadHeader = {'Accept': Document.contentType};
  static const payloadHeader = {
    'Accept': Document.contentType,
    'Content-Type': Document.contentType
  };

  HttpRequest toHttp(Uri uri);

  R decode(HttpResponse response);
}

class FetchCollectionRequest implements Request<Response> {
  FetchCollectionRequest({QueryParameters queryParameters})
      : _query = queryParameters ?? QueryParameters.empty();

  final QueryParameters _query;

  @override
  Response decode(HttpResponse http) => Response(http);

  @override
  HttpRequest toHttp(Uri uri) =>
      HttpRequest(HttpMethod.GET, _query.addToUri(uri),
          headers: Request.noPayloadHeader);
}

class FetchResourceRequest implements Request<Response> {
  FetchResourceRequest({QueryParameters queryParameters})
      : _query = queryParameters ?? QueryParameters.empty();

  final QueryParameters _query;

  @override
  Response decode(HttpResponse http) => Response(http);

  @override
  HttpRequest toHttp(Uri uri) =>
      HttpRequest(HttpMethod.GET, _query.addToUri(uri),
          headers: Request.noPayloadHeader);
}

class FetchToOneRequest implements Request<Response> {
  FetchToOneRequest({QueryParameters queryParameters})
      : _query = queryParameters ?? QueryParameters.empty();

  final QueryParameters _query;

  @override
  Response decode(HttpResponse http) => Response(http);

  @override
  HttpRequest toHttp(Uri uri) =>
      HttpRequest(HttpMethod.GET, _query.addToUri(uri),
          headers: Request.noPayloadHeader);
}

class FetchToManyRequest implements Request<Response> {
  FetchToManyRequest({QueryParameters queryParameters})
      : _query = queryParameters ?? QueryParameters.empty();

  final QueryParameters _query;

  @override
  Response decode(HttpResponse http) => Response(http);

  @override
  HttpRequest toHttp(Uri uri) =>
      HttpRequest(HttpMethod.GET, _query.addToUri(uri),
          headers: Request.noPayloadHeader);
}

class CreateNewResourceRequest implements Request<Response> {
  CreateNewResourceRequest(this._resource);

  final NewResource _resource;

  @override
  Response decode(HttpResponse http) => Response(http);

  @override
  HttpRequest toHttp(Uri uri) => HttpRequest(HttpMethod.POST, uri,
      headers: Request.payloadHeader,
      body: jsonEncode(
          Document(ResourceData(ResourceObject.fromResource(_resource)))));
}

class CreateResourceRequest implements Request<Response> {
  CreateResourceRequest(this._resource);

  final Resource _resource;

  @override
  Response decode(HttpResponse http) => Response(http);

  @override
  HttpRequest toHttp(Uri uri) => HttpRequest(HttpMethod.POST, uri,
      headers: Request.payloadHeader,
      body: jsonEncode(
          Document(ResourceData(ResourceObject.fromResource(_resource)))));
}

class UpdateResourceRequest implements Request<Response> {
  UpdateResourceRequest(this._resource);

  final Resource _resource;

  @override
  Response decode(HttpResponse http) => Response(http);

  @override
  HttpRequest toHttp(Uri uri) => HttpRequest(HttpMethod.PATCH, uri,
      headers: Request.payloadHeader,
      body: jsonEncode(
          Document(ResourceData(ResourceObject.fromResource(_resource)))));
}

class DeleteResourceRequest implements Request<Response> {
  DeleteResourceRequest();

  @override
  Response decode(HttpResponse http) => Response(http);

  @override
  HttpRequest toHttp(Uri uri) =>
      HttpRequest(HttpMethod.PATCH, uri, headers: Request.noPayloadHeader);
}

class ReplaceToOneRequest implements Request<Response> {
  ReplaceToOneRequest(this._identifier);

  final Identifier _identifier;

  @override
  Response decode(HttpResponse http) => Response(http);

  @override
  HttpRequest toHttp(Uri uri) => HttpRequest(HttpMethod.PATCH, uri,
      headers: Request.payloadHeader,
      body: jsonEncode(
          Document(ToOne(IdentifierObject.fromIdentifier(_identifier)))));
}

class DeleteToOneRequest implements Request<Response> {
  DeleteToOneRequest();

  @override
  Response decode(HttpResponse http) => Response(http);

  @override
  HttpRequest toHttp(Uri uri) => HttpRequest(HttpMethod.PATCH, uri,
      headers: Request.payloadHeader,
      body: jsonEncode(Document(ToOne.empty())));
}

class ReplaceToManyRequest implements Request<Response> {
  ReplaceToManyRequest(this._identifiers);

  final Iterable<Identifier> _identifiers;

  @override
  Response decode(HttpResponse http) => Response(http);

  @override
  HttpRequest toHttp(Uri uri) => HttpRequest(HttpMethod.PATCH, uri,
      headers: Request.payloadHeader,
      body: jsonEncode(
          Document(ToMany(_identifiers.map(IdentifierObject.fromIdentifier)))));
}

class DeleteToManyRequest implements Request<Response> {
  DeleteToManyRequest(this._identifiers);

  final Iterable<Identifier> _identifiers;

  @override
  Response decode(HttpResponse http) => Response(http);

  @override
  HttpRequest toHttp(Uri uri) => HttpRequest(HttpMethod.DELETE, uri,
      headers: Request.payloadHeader,
      body: jsonEncode(
          Document(ToMany(_identifiers.map(IdentifierObject.fromIdentifier)))));
}

class AddToManyRequest implements Request<Response> {
  AddToManyRequest(this._identifiers);

  final Iterable<Identifier> _identifiers;

  @override
  Response decode(HttpResponse http) => Response(http);

  @override
  HttpRequest toHttp(Uri uri) => HttpRequest(HttpMethod.POST, uri,
      headers: Request.payloadHeader,
      body: jsonEncode(
          Document(ToMany(_identifiers.map(IdentifierObject.fromIdentifier)))));
}
