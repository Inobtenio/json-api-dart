import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';

/// The JSON:API client
class JsonApiClient {
  JsonApiClient(this._http, this._uri);

  final HttpHandler _http;
  final UriFactory _uri;

  /// Fetches a primary resource collection by [type].
  Future<Response> fetchCollection(String type,
          {Map<String, String> headers, QueryParameters queryParameters}) =>
      send(FetchCollectionRequest(queryParameters: queryParameters),
          _uri.collection(type),
          headers: headers);

  /// Fetches a related resource collection. Guesses the URI by [type], [id], [relationship].
  Future<Response> fetchRelatedCollection(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters queryParameters}) =>
      send(FetchCollectionRequest(queryParameters: queryParameters),
          _uri.related(type, id, relationship),
          headers: headers);

  /// Fetches a primary resource by [type] and [id].
  Future<Response> fetchResource(String type, String id,
          {Map<String, String> headers, QueryParameters queryParameters}) =>
      send(FetchResourceRequest(queryParameters: queryParameters),
          _uri.resource(type, id),
          headers: headers);

  /// Fetches a related resource by [type], [id], [relationship].
  Future<Response> fetchRelatedResource(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters queryParameters}) =>
      send(FetchResourceRequest(queryParameters: queryParameters),
          _uri.related(type, id, relationship),
          headers: headers);

  /// Fetches a to-one relationship by [type], [id], [relationship].
  Future<Response> fetchToOne(String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters queryParameters}) =>
      send(FetchToOneRequest(queryParameters: queryParameters),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Fetches a to-many relationship by [type], [id], [relationship].
  Future<Response> fetchToMany(String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters queryParameters}) =>
      send(
        FetchToManyRequest(queryParameters: queryParameters),
        _uri.relationship(type, id, relationship),
        headers: headers,
      );

  /// Creates the [resource] on the server.
  Future<Response> createResource(Resource resource,
          {Map<String, String> headers}) =>
      send(CreateResourceRequest(resource), _uri.collection(resource.type),
          headers: headers);

  /// Creates a new [resource] on the server.
  Future<Response> createNewResource(NewResource resource,
          {Map<String, String> headers}) =>
      send(CreateNewResourceRequest(resource), _uri.collection(resource.type),
          headers: headers);

  /// Deletes the resource by [type] and [id].
  Future<Response> deleteResource(String type, String id,
          {Map<String, String> headers}) =>
      send(DeleteResourceRequest(), _uri.resource(type, id), headers: headers);

  /// Updates the [resource].
  Future<Response> updateResource(Resource resource,
          {Map<String, String> headers}) =>
      send(UpdateResourceRequest(resource),
          _uri.resource(resource.type, resource.id),
          headers: headers);

  /// Replaces the to-one [relationship] of [type] : [id].
  Future<Response> replaceToOne(
          String type, String id, String relationship, Identifier identifier,
          {Map<String, String> headers}) =>
      send(ReplaceToOneRequest(identifier),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Deletes the to-one [relationship] of [type] : [id].
  Future<Response> deleteToOne(String type, String id, String relationship,
          {Map<String, String> headers}) =>
      send(DeleteToOneRequest(), _uri.relationship(type, id, relationship),
          headers: headers);

  /// Deletes the [identifiers] from the to-many [relationship] of [type] : [id].
  Future<Response> deleteFromToMany(String type, String id, String relationship,
          Iterable<Identifier> identifiers, {Map<String, String> headers}) =>
      send(DeleteToManyRequest(identifiers),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Replaces the to-many [relationship] of [type] : [id] with the [identifiers].
  Future<Response> replaceToMany(String type, String id, String relationship,
          Iterable<Identifier> identifiers, {Map<String, String> headers}) =>
      send(ReplaceToManyRequest(identifiers),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Adds the [identifiers] to the to-many [relationship] of [type] : [id].
  Future<Response> addToMany(String type, String id, String relationship,
          Iterable<Identifier> identifiers, {Map<String, String> headers}) =>
      send(AddToManyRequest(identifiers),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Sends the request to the [uri] via [handler] and returns the response.
  /// Extra [headers] may be added to the request.
  Future<R> send<R extends Response>(Request<R> request, Uri uri,
          {Map<String, String> headers}) async =>
      request.decode(await _http.call(request.toHttp(uri)));
}
