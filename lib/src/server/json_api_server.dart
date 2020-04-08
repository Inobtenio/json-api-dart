import 'dart:async';
import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/controller_response.dart';
import 'package:json_api/src/server/resolvable_request.dart';
import 'package:json_api/src/server/route.dart';

/// A simple implementation of JSON:API server
class JsonApiServer implements HttpHandler {
  JsonApiServer(this._controller,
      {Routing routing, DocumentFactory documentFactory})
      : _routing = routing ?? StandardRouting(),
        _doc = documentFactory ?? DocumentFactory();

  final Routing _routing;
  final Controller _controller;
  final DocumentFactory _doc;

  @override
  Future<HttpResponse> call(HttpRequest httpRequest) async {
    final routeFactory = RouteFactory();
    _routing.match(httpRequest.uri, routeFactory);
    final route = routeFactory.route;

    if (route == null) {
      return _convert(ErrorResponse(404, [
        ErrorObject(
          status: '404',
          title: 'Not Found',
          detail: 'The requested URL does exist on the server',
        )
      ]));
    }

    final allowed = (route.allowedMethods + ['OPTIONS']).join(', ');

    if (httpRequest.isOptions) {
      return HttpResponse(200, headers: {
        'Access-Control-Allow-Methods': allowed,
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Max-Age': '3600',
      });
    }

    if (!route.allowedMethods.contains(httpRequest.method)) {
      return HttpResponse(405, headers: {'Allow': allowed});
    }

    try {
      final controllerRequest = route.convertRequest(httpRequest);
      return _convert(await controllerRequest.resolveBy(_controller));
    } on FormatException catch (e) {
      return _convert(ErrorResponse(400, [
        ErrorObject(
          status: '400',
          title: 'Bad Request',
          detail: 'Invalid JSON. ${e.message}',
        )
      ]));
    } on DocumentException catch (e) {
      return _convert(ErrorResponse(400, [
        ErrorObject(
          status: '400',
          title: 'Bad Request',
          detail: e.message,
        )
      ]));
    } on IncompleteRelationshipException {
      return _convert(ErrorResponse(400, [
        ErrorObject(
          status: '400',
          title: 'Bad Request',
          detail: 'Incomplete relationship object',
        )
      ]));
    }
  }

  HttpResponse _convert(ControllerResponse r) {
    return HttpResponse(r.status,
        body: jsonEncode(r.document(_doc, _routing)),
        headers: {
          ...r.headers(_routing),
          'Access-Control-Allow-Origin': '*',
        });
  }
}
