import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum HttpMethod { get, post, put, patch, delete, head, options }

class NetworkHelper {
  final String url;
  final String path;
  final Map<String, dynamic>? headers;
  final Map<String, dynamic>? queryParams;
  final String errorMessage;
  final HttpMethod method;
  final dynamic body;
  final Encoding? encoding;

  NetworkHelper({
    required this.url,
    required this.path,
    this.headers,
    this.queryParams,
    required this.errorMessage,
    this.method = HttpMethod.get,
    this.body,
    this.encoding,
  });

  /// Public entry point that performs the request and returns the decoded body
  /// (or null on error).
  Future<dynamic> getData() async {
    try {
      final uri = buildUri();
      final response = await makeHttpRequest(uri);
      return processResponse(response);
    } catch (e) {
      return handleError(e);
    }
  }

  Uri buildUri() {
    final base = Uri.parse('$url$path');
    if (queryParams == null) return base;
    final qp = queryParams?.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    return base.replace(queryParameters: qp);
  }

  Future<http.Response> makeHttpRequest(Uri uri) async {
    final stringHeaders = convertHeadersToString();

    switch (method) {
      case HttpMethod.get:
        return await http.get(uri, headers: stringHeaders);
      case HttpMethod.post:
        return await http.post(uri,
            headers: stringHeaders, body: prepareBody(), encoding: encoding);
      case HttpMethod.put:
        return await http.put(uri,
            headers: stringHeaders, body: prepareBody(), encoding: encoding);
      case HttpMethod.patch:
        return await http.patch(uri,
            headers: stringHeaders, body: prepareBody(), encoding: encoding);
      case HttpMethod.delete:
        // http.delete supports a body in the newer http package versions
        return await http.delete(uri,
            headers: stringHeaders, body: prepareBody(), encoding: encoding);
      case HttpMethod.head:
        return await http.head(uri, headers: stringHeaders);
      case HttpMethod.options:
        // The http package does not expose an options() helper. Use a generic
        // Request via the Client to support arbitrary verbs.
        return await _sendGenericRequest('OPTIONS', uri, stringHeaders);
    }
  }

  /// Convert provided headers to a Map<String,String>. Also ensures the
  /// content-type is set when a JSON body is provided and no content-type
  /// exists already.
  Map<String, String>? convertHeadersToString() {
    final map = headers?.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    if (map == null) return null;
    // If there's a body that's a Map and no content-type provided, default to JSON
    if (body != null &&
        body is Map &&
        !map.keys.any((k) => k.toLowerCase() == 'content-type')) {
      map['content-type'] = 'application/json';
    }
    return Map<String, String>.from(map);
  }

  /// Prepare the body for http.* helpers. If it's a Map or Iterable, encode
  /// to JSON. Otherwise return as-is (String, List<int>, etc.).
  dynamic prepareBody() {
    if (body == null) return null;
    if (body is String || body is List<int> || body is List<int>?) return body;
    try {
      return jsonEncode(body);
    } catch (_) {
      return body.toString();
    }
  }

  /// Generic request sender for HTTP verbs not directly exposed by the
  /// high-level helpers (or as a fallback).
  Future<http.Response> _sendGenericRequest(
      String verb, Uri uri, Map<String, String>? stringHeaders) async {
    final client = http.Client();
    try {
      final req = http.Request(verb.toUpperCase(), uri);
      if (stringHeaders != null) req.headers.addAll(stringHeaders);
      final prepared = prepareBody();
      if (prepared != null) {
        if (prepared is String) {
          req.body = prepared;
        } else if (prepared is List<int>) {
          req.bodyBytes = prepared;
        } else {
          req.body = prepared.toString();
        }
      }

      final streamed = await client.send(req);
      return await http.Response.fromStream(streamed);
    } finally {
      client.close();
    }
  }

  dynamic processResponse(http.Response response) {
    if (isSuccessfulResponse(response)) {
      return parseResponseBody(response.body);
    }

    throw createHttpException(response);
  }

  bool isSuccessfulResponse(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  dynamic parseResponseBody(String responseBody) {
    if (responseBody.isEmpty) return null;
    try {
      return jsonDecode(responseBody);
    } catch (e) {
      throw FormatException('Failed to parse JSON response: $e');
    }
  }

  Exception createHttpException(http.Response response) {
    // Include body for easier debugging
    final bodySnippet =
        response.body.isNotEmpty ? '\nBody: ${response.body}' : '';
    return HttpException(
      '$errorMessage: HTTP ${response.statusCode}$bodySnippet',
      uri: response.request?.url,
    );
  }

  dynamic handleError(dynamic error) {
    logError(error);
    return null;
  }

  void logError(dynamic error) {
    final errorType = getErrorType(error);
    debugPrint('Network Error [$errorType]: $error');
  }

  String getErrorType(dynamic error) {
    if (error is SocketException) return 'Connection';
    if (error is HttpException) return 'HTTP';
    if (error is FormatException) return 'Parsing';
    if (error is TimeoutException) return 'Timeout';
    return 'Unknown';
  }
}
