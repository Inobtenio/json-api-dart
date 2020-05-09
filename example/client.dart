import 'package:http/http.dart' as http;
import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';

/// This example shows how to use the JSON:API client.
/// Run the server first!
void main() async {
  /// Use the standard routing
  final routing = StandardRouting(Uri.parse('http://localhost:8080'));

  /// Create the HTTP client. We're using Dart's native client.
  /// Do not forget to call [Client.close] when you're done using it.
  final httpClient = http.Client();

  /// We'll use a logging handler wrapper to show the requests and responses.
  final httpHandler = LoggingHttpHandler(DartHttp(httpClient),
      onRequest: (r) => print('${r.method} ${r.uri}'),
      onResponse: (r) => print('${r.statusCode}'));

  /// The JSON:API client
  final client = JsonApiClient(httpHandler, routing);

  /// Create the first resource.
  await client
      .createResource('writers', '1', attributes: {'name': 'Martin Fowler'});

  /// Create the second resource.
  await client.createResource('books', '2', attributes: {
    'title': 'Refactoring'
  }, relationships: {
    'authors': Many([Identifier('writers', '1')])
  });

  /// Fetch the book, including its authors.
  final response = await client.fetchResource('books', '2',
      include: ['authors']);

  final document = response.decodeDocument();

  /// Extract the primary resource.
  final book = document.data.unwrap();

  /// Extract the included resource.
  final author = document.included.first.unwrap();

  print('Book: $book');
  print('Author: $author');

  /// Do not forget to always close the HTTP client.
  httpClient.close();
}
