import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:attendance_app/platform/api/network_strings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum HttpMethod { get, post, put, delete, patch }

class NetworkHelper {
  final String url;
  final String path;
  final Map<String, dynamic>? headers;
  final Map<String, dynamic>? queryParams;
  final dynamic body;
  final String errorMessage;
  final HttpMethod method;
  final Duration timeout;

  NetworkHelper({
    required this.url,
    required this.path,
    this.headers,
    this.queryParams,
    this.body,
    required this.errorMessage,
    this.method = HttpMethod.get,
    this.timeout = const Duration(seconds: 30),
  });

  Future<Map<String, dynamic>?> getData() async {
    try {
      final uri = buildUri();
      debugPrint('Built URI: $uri');
      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      http.Response response;

      switch (method) {
        case HttpMethod.get:
          try {
            response = await http.get(uri, headers: defaultHeaders).timeout(
                  timeout,
                  onTimeout: () => throw TimeoutException(
                    NetworkStrings.connectionTimeOut,
                  ),
                );
          } catch (e) {
            debugPrint('HTTP GET error: $e');
            rethrow;
          }
          break;
        case HttpMethod.post:
          try {
            response = await http
                .post(uri,
                    headers: defaultHeaders,
                    body: body != null ? jsonEncode(body) : null)
                .timeout(
                  timeout,
                  onTimeout: () => throw TimeoutException(
                    NetworkStrings.connectionTimeOut,
                  ),
                );
          } catch (e) {
            debugPrint('HTTP POST error: $e');
            rethrow;
          }
          break;
        case HttpMethod.put:
          response = await http
              .put(uri,
                  headers: defaultHeaders,
                  body: body != null ? jsonEncode(body) : null)
              .timeout(
                timeout,
                onTimeout: () => throw TimeoutException(
                  NetworkStrings.connectionTimeOut,
                ),
              );
          break;
        case HttpMethod.delete:
          response = await http
              .delete(uri,
                  headers: defaultHeaders,
                  body: body != null ? jsonEncode(body) : null)
              .timeout(
                timeout,
                onTimeout: () => throw TimeoutException(
                  NetworkStrings.connectionTimeOut,
                ),
              );
          break;
        case HttpMethod.patch:
          response = await http
              .patch(uri,
                  headers: defaultHeaders,
                  body: body != null ? jsonEncode(body) : null)
              .timeout(
                timeout,
                onTimeout: () => throw TimeoutException(
                  NetworkStrings.connectionTimeOut,
                ),
              );
          break;
      }

      return handleResponse(response);
    } on SocketException {
      throw NetworkException(NetworkStrings.internetError);
    } on TimeoutException {
      throw NetworkException(NetworkStrings.connectionTimeOut);
    } on HandshakeException {
      throw NetworkException(NetworkStrings.handShakeError);
    } on CertificateException {
      throw NetworkException(NetworkStrings.certificateError);
    } on http.ClientException {
      throw NetworkException(NetworkStrings.internetError);
    } on FormatException {
      throw NetworkException(NetworkStrings.formatError);
    } catch (e, st) {
      debugPrint('Network error: $e');
      debugPrint('Stack trace: $st');
      throw NetworkException(NetworkStrings.somethingWentWrong);
    }
  }

  Uri buildUri() {
    final baseUri = Uri.parse(url);
    // Ensure query parameters are all strings (Uri expects String or
    // Iterable<String> values). Convert any non-null values to their
    // string representation to avoid runtime type errors when building
    // the URI (server sometimes sends ints in query params).
    Map<String, String>? qp;
    if (queryParams != null) {
      qp = queryParams!
          .map((key, value) => MapEntry(key, value?.toString() ?? ''));
    }

    return Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.port,
      path: '${baseUri.path}$path',
      queryParameters: qp,
    );
  }

  Map<String, dynamic>? handleResponse(http.Response response) {
    debugPrint('Response Status: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      try {
        final decoded = jsonDecode(response.body);

        // If the server returned a JSON object/map, return it directly.
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        // If the server returned any other JSON type (list, number, string),
        // wrap it in a map under the 'data' key so callers can handle it
        // consistently (they still must validate the shape of response['data']).
        return {'data': decoded};
      } catch (e) {
        throw NetworkException(NetworkStrings.formatError);
      }
    } else if (response.statusCode == 400) {
      throw NetworkException(NetworkStrings.badRequest);
    } else if (response.statusCode == 401) {
      throw NetworkException(NetworkStrings.unauthorized);
    } else if (response.statusCode == 403) {
      throw NetworkException(NetworkStrings.forbidden);
    } else if (response.statusCode == 404) {
      throw NetworkException(NetworkStrings.notFound);
    } else if (response.statusCode == 429) {
      throw NetworkException(NetworkStrings.tooManyRequests);
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      throw NetworkException(NetworkStrings.serverError);
    } else {
      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final message = errorData['message'] ?? errorData['error'];
        if (message != null) {
          throw NetworkException(message.toString());
        }
      } catch (_) {}
      throw NetworkException('$errorMessage: HTTP ${response.statusCode}');
    }
  }
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => message;
}
