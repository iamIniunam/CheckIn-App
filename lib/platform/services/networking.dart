import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NetworkHelper {
  final String url;
  final String path;
  final Map<String, dynamic>? headers;
  final Map<String, dynamic>? queryParams;
  final String errorMessage;

  NetworkHelper(
      {required this.url,
      required this.path,
      this.headers,
      this.queryParams,
      required this.errorMessage});

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
    return Uri.parse('$url$path').replace(queryParameters: queryParams);
  }

  Future<http.Response> makeHttpRequest(Uri uri) async {
    final stringHeaders = convertHeadersToString();
    return await http.post(uri, headers: stringHeaders);
  }

  Map<String, String>? convertHeadersToString() {
    return headers?.cast<String, String>();
  }

  dynamic processResponse(http.Response response) {
    if (isSuccessfulResponse(response)) {
      return parseResponseBody(response.body);
    }

    throw createHttpException(response);
  }

  bool isSuccessfulResponse(http.Response response) {
    return response.statusCode == 200;
  }

  dynamic parseResponseBody(String responseBody) {
    try {
      return jsonDecode(responseBody);
    } catch (e) {
      throw FormatException('Failed to parse JSON response: $e');
    }
  }

  Exception createHttpException(http.Response response) {
    return HttpException(
      '$errorMessage: HTTP ${response.statusCode}',
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
