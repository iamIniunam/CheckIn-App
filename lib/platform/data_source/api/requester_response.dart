import 'dart:async';
import 'dart:io';
import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/network_strings.dart';
import 'package:http/http.dart' as http;

class RequesterResponse {
  ApiResponseStatus? status;
  dynamic response;
  String? rawResponse;
  String? message;
  int? statusCode;
  int? responseSizeInBytes;
  double? responseTimeInSeconds;
  int? responseTimeInMilliSeconds;

  RequesterResponse(
      {this.status,
      this.response,
      this.rawResponse,
      this.statusCode,
      this.responseSizeInBytes,
      this.responseTimeInMilliSeconds,
      this.message,
      this.responseTimeInSeconds});

  static RequesterResponse formatErrorMessage(
    dynamic error,
    String defaultErrorMessage,
    http.Response? response,
  ) {
    String? message;
    Map<String, dynamic> data = {};
    ApiResponseStatus apiResult = ApiResponseStatus.Error;

    if (error is SocketException ||
        error is HttpException ||
        error is RedirectException ||
        error is WebSocketException) {
      apiResult = ApiResponseStatus.NoInternet;
      message = NetworkStrings.internetError;
    } else if (error is FormatException) {
      apiResult = ApiResponseStatus.Error;
      message = NetworkStrings.formatError;
    } else if (error is HandshakeException) {
      message = NetworkStrings.handShakeError;
    } else if (error is CertificateException) {
      message = NetworkStrings.certificateError;
    } else if (error is TlsException) {
      message = 'SSL error occurred ${error.message}';
    } else if (error is TimeoutException) {
      apiResult = ApiResponseStatus.NoInternet;
      message = NetworkStrings.connectionTimeOut;
    } else {
      message = message ?? defaultErrorMessage;
    }

    return RequesterResponse(
      status: apiResult,
      response: data,
      statusCode: response?.statusCode,
      message: message,
      responseSizeInBytes: response?.contentLength,
    );
  }
}
