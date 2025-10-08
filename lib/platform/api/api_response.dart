// ignore_for_file: constant_identifier_names

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(success: true, data: data, message: message);
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(success: true, message: message, statusCode: statusCode);
  }
}

// enum ApiResponseStatus { Success, NoInternet, Error, Timeout, Unknown }
