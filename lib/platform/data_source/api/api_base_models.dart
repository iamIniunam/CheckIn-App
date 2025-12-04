import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/network_strings.dart';
import 'package:attendance_app/platform/extensions/map_extensions.dart';
import 'package:attendance_app/platform/extensions/string_extensions.dart';

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

class DataResponse<T extends Serializable> extends Serializable {
  T? data;
  String? message;
  bool error;
  String status;
  String? responseCode;

  DataResponse({
    this.data,
    this.message,
    this.error = false,
    this.responseCode,
    required this.status,
  });

  factory DataResponse.fromJson(
    Map<String, dynamic>? json,
    Function(Map<String, dynamic>?) create,
  ) {
    dynamic retrieveMessage(Map<String, dynamic>? json) {
      return json?["message"] ?? json?["Message"];
    }

    dynamic retrieveError(Map<String, dynamic>? json) {
      return (json?["error"]);
    }

    dynamic retrieveStatus(Map<String, dynamic>? json) {
      return (json?["status"]);
    }

    dynamic retrieveResponseCode(Map<String, dynamic>? json) {
      return (json?['responseCode']);
    }

    return DataResponse(
        data: json?['data'] != null ? create(json?['data']) : null,
        message: retrieveMessage(json),
        error: retrieveError(json) ?? false,
        status: (retrieveStatus(json)).toString(),
        responseCode: retrieveResponseCode(json).toString());
  }

  factory DataResponse.fromJString(
      Map<String, dynamic>? json, Function(String?) create) {
    return DataResponse(
      data: create(json?['data']),
      error: json?['error'] ?? false,
      message: json?['message'],
      status: json?['status'] ?? json?['code'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'data': data?.toMap(),
      'message': message,
      'error': error,
      'status': status,
    };
  }
}

class ListDataResponse<T extends Serializable> extends Serializable {
  List<T>? data;
  bool error;
  String? message;
  String? status;

  String? pageNumber;
  String? pageSize;
  String? totalNumberOfPages;
  String? totalNumberOfRecords;
  bool? hasMore;

  ListDataResponse(
      {this.data,
      this.message,
      this.error = false,
      this.status,
      this.pageNumber,
      this.pageSize,
      this.totalNumberOfPages,
      this.totalNumberOfRecords,
      this.hasMore});

  factory ListDataResponse.fromJson(
    Map<String, dynamic>? jsonn,
    Function(Map<String, dynamic>) create,
  ) {
    dynamic json = jsonn?['data'] ?? jsonn;

    dynamic retrieveData(dynamic json) {
      if (json is List) {
        return json;
      }
      var result = json?['data'] ?? json?['results'] ?? json?['items'];
      if (result is List) {
        return result;
      } else if (result is Map) {
        var innerResult = json?['data'] ?? json?['results'] ?? json?['items'];
        return innerResult;
      }
      return result;
    }

    dynamic retrieveMessage(dynamic json) {
      if (json is! Map) {
        return null;
      }
      return json["message"] ?? json["Message"];
    }

    dynamic retrieveStatus(dynamic json) {
      if (json is! Map) {
        return null;
      }
      return (json["status"]);
    }

    dynamic retrieveError(dynamic json) {
      if (json is! Map) {
        return null;
      }
      return (json["error"]);
    }

    Map<String, dynamic>? paginationData;
    if (json is Map && json.containsKey('pagination')) {
      paginationData = json['pagination'] as Map<String, dynamic>?;
    }

    dynamic retrievePageNumber(dynamic json) {
      if (json is! Map) {
        return null;
      }
      // Check pagination object first
      if (paginationData != null) {
        return paginationData['current_page'] ?? paginationData['currentPage'];
      }
      // Fall back to flat structure
      return (json["pageNumber"]) ??
          json['page'] ??
          json['pageIndex'] ??
          json['current_page'];
    }

    dynamic retrievePageSize(dynamic json) {
      if (json is! Map) {
        return null;
      }
      // Check pagination object first
      if (paginationData != null) {
        return paginationData['per_page'] ?? paginationData['perPage'];
      }
      // Fall back to flat structure
      return (json["pageSize"]) ?? json['per_page'];
    }

    dynamic retrieveTotalNumberOfPages(dynamic json) {
      if (json is! Map) {
        return null;
      }
      // Check pagination object first
      if (paginationData != null) {
        return paginationData['last_page'] ??
            paginationData['lastPage'] ??
            paginationData['totalPages'];
      }
      // Fall back to flat structure
      return (json["totalNumberOfPages"]) ??
          json['totalPages'] ??
          json['last_page'];
    }

    dynamic retrieveTotalNumberOfRecords(dynamic json) {
      if (json is! Map) {
        return null;
      }
      // Check pagination object first
      if (paginationData != null) {
        return paginationData['total'] ??
            paginationData['totalCount'] ??
            paginationData['totalRecords'];
      }
      // Fall back to flat structure
      return (json["totalNumberOfRecords"]) ??
          json['totalRecords'] ??
          json['totalCount'] ??
          json['total'];
    }

    // NEW: Retrieve has_more flag
    dynamic retrieveHasMore(dynamic json) {
      if (json is! Map) {
        return null;
      }
      // Check pagination object first
      if (paginationData != null) {
        return paginationData['has_more'] ?? paginationData['hasMore'];
      }
      // Fall back to flat structure
      return json['has_more'] ?? json['hasMore'];
    }

    var dataJson = retrieveData(json);
    var parsedData = List<T>.from((dataJson ?? []).map((x) => create(x)));

    return ListDataResponse(
      data: parsedData,
      message: retrieveMessage(json),
      error: retrieveError(json) ?? false,
      status: retrieveStatus.toString(),
      pageNumber: (retrievePageNumber(json)).toString(),
      pageSize: (retrievePageSize(json)).toString(),
      totalNumberOfPages: (retrieveTotalNumberOfPages(json)).toString(),
      totalNumberOfRecords: (retrieveTotalNumberOfRecords(json)).toString(),
      hasMore: retrieveHasMore(json) as bool?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'message': message,
      'error': error,
      'status': status,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalNumberOfPages': totalNumberOfPages,
      'totalNumberOfRecords': totalNumberOfRecords,
      'hasMore': hasMore,
    };
  }

  bool isLastPage() {
    if (data == null || data!.isEmpty) {
      return true;
    }

    if (hasMore != null) {
      return !(hasMore ?? false);
    }

    if (pageNumber != null && totalNumberOfPages != null) {
      final current = pageNumber?.toInt() ?? 0;
      final total = totalNumberOfPages?.toInt() ?? 0;

      if (current > 0 && total > 0) {
        return current >= total;
      }
    }

    if (data != null && pageSize != null) {
      final receivedCount = data!.length;
      final expectedCount = pageSize?.toInt() ?? 10;

      if (receivedCount < expectedCount) {
        return true;
      }
    }
    return false;
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
