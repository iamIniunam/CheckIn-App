import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/network_strings.dart';
import 'package:attendance_app/platform/extensions/map_extensions.dart';

class ApiResponse<T> {
  T? response;
  ApiResponseStatus? status;
  int? statusCode;
  String? message;

  ApiResponse({
    this.response,
    this.status,
    this.statusCode,
    this.message,
  });

  bool get isSuccess => status == ApiResponseStatus.Success;
  bool get hasData => response != null;
  bool get isError => status == ApiResponseStatus.Error;
  bool get isNoInternet => status == ApiResponseStatus.NoInternet;

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      response: data,
      status: ApiResponseStatus.Success,
      statusCode: 200,
      message: message,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      status: ApiResponseStatus.Error,
      statusCode: statusCode ?? 400,
      message: message,
    );
  }

  factory ApiResponse.noInternet() {
    return ApiResponse(
      status: ApiResponseStatus.NoInternet,
      message: NetworkStrings.internetError,
    );
  }
}

abstract class Serializable {
  Map<String, dynamic> toMap();
}

extension SerializableToJsonExtension on Serializable {
  String toJson({bool pretty = false, String indent = '  '}) {
    return toMap().toJson(pretty: pretty, indent: indent);
  }
}
