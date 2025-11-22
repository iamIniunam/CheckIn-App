import 'dart:convert';
import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/api_end_point.dart';
import 'package:attendance_app/platform/data_source/api/network_strings.dart';
import 'package:attendance_app/platform/data_source/api/requester_response.dart';
import 'package:attendance_app/platform/extensions/map_extensions.dart';
import 'package:attendance_app/platform/extensions/string_extensions.dart';
import 'package:attendance_app/platform/utils/general_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_app/platform/data_source/persistence/manager.dart';

class Requester {
  PreferenceManager manager;

  Requester({required this.manager});

  http.Response? _response;

  Future<Map<String, String>> getDefaultHeaders() async {
    var headers = <String, String>{};
    headers['Content-Type'] = 'application/json';
    headers['Accept'] = '*/*';
    return headers;
  }

  Future<RequesterResponse> makeAppRequest(
      {required ApiEndPoint apiEndPoint}) async {
    final stopwatch = Stopwatch()..start();
    var responseInBytes = 0;

    var headers = apiEndPoint.headers;
    var defaultHeaders = await getDefaultHeaders();
    headers.addAll(defaultHeaders);
    headers.addAll(apiEndPoint.headers);

    if (kDebugMode) {
      print(
          "${apiEndPoint.requestType.toString()} Request Initiated : ${apiEndPoint.address} \nParams: ${apiEndPoint.body} \nHeaders $headers");
    }

    ApiResponseStatus syncStatus;
    RequesterResponse? response;

    var timeOutDuration = const Duration(seconds: 60);

    try {
      switch (apiEndPoint.requestType) {
        case HttpVerb.GET:
          {
            _response = await http
                .get(apiEndPoint.address, headers: headers)
                .timeout(timeOutDuration);
            break;
          }
        case HttpVerb.POST:
          {
            _response = await http
                .post(apiEndPoint.address,
                    body: apiEndPoint.body.toJson(), headers: headers)
                .timeout(timeOutDuration);
            break;
          }
        case HttpVerb.PUT:
          {
            _response = await http
                .put(apiEndPoint.address,
                    body: apiEndPoint.body.toJson(), headers: headers)
                .timeout(timeOutDuration);
            break;
          }
        case HttpVerb.PATCH:
          {
            _response = await http
                .patch(apiEndPoint.address,
                    body: apiEndPoint.body.toJson(), headers: headers)
                .timeout(timeOutDuration);
            break;
          }

        case HttpVerb.DELETE:
          {
            _response = await http
                .delete(apiEndPoint.address, headers: headers)
                .timeout(timeOutDuration);
            break;
          }
        default:
      }

      responseInBytes = _response?.contentLength ?? 0;
      var code = _response?.statusCode ?? 0;
      if (code >= 200 && code <= 300) {
        syncStatus = ApiResponseStatus.Success;
      } else if (code >= 500) {
        syncStatus = ApiResponseStatus.Unknown;
      } else {
        syncStatus = ApiResponseStatus.Error;
      }

      if (kDebugMode) {
        print(
            "Response with code : ${_response?.statusCode} for ${apiEndPoint.requestType.toString()} >> ${apiEndPoint.address} with params ${apiEndPoint.body} : \nResponse >> ${_response?.body}");
      }

      var jsonResponse =
          json.decode(_response?.body.ifNullOrBlank(() => "{}") ?? '{}');

      response = RequesterResponse(
        status: syncStatus,
        statusCode: _response?.statusCode,
        response: jsonResponse,
        rawResponse: _response?.body,
        message: jsonResponse is Map ? jsonResponse['message'] : null,
        responseSizeInBytes: responseInBytes,
        responseTimeInSeconds: stopwatch.elapsed.inMilliseconds / 1000.0,
        responseTimeInMilliSeconds: stopwatch.elapsed.inMilliseconds,
      );
    } catch (e) {
      response = RequesterResponse.formatErrorMessage(
        e,
        NetworkStrings.somethingWentWrong,
        null,
      );
      Utils.printInDebugMode(e.toString());
    }

    stopwatch.stop();

    return response;
  }
}
