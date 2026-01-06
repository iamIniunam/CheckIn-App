import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/api_base_models.dart';
import 'package:attendance_app/platform/data_source/api/api_end_point.dart';
import 'package:attendance_app/platform/data_source/api/attendance/models/attedance_response.dart';
import 'package:attendance_app/platform/data_source/api/attendance/models/attendance_request.dart';

class AttendanceApi extends ApiCore {
  AttendanceApi({required super.requester});

  final _courseAttendanceBasePath = '/student/getCourseAttendanceRecord';
  final _markAttendanceBasePath = '/student/markAttendance';
  final _getAttendanceHistoryBasePath = '/student/getAttendanceHistory';

  Future<ApiResponse<List<CourseAttendanceRecord>>> getCourseAttendanceRecord(
    GetCourseAttendanceRequest request,
  ) async {
    final response = await requester.makeAppRequest(
      apiEndPoint: ApiEndPoint.createApiEndpoint(
        path:
            '$_courseAttendanceBasePath/${request.courseId}/${request.studentId}',
        requestType: HttpVerb.GET,
        body: {},
      ),
    );

    if (response.status == ApiResponseStatus.Success) {
      try {
        final data = response.response['data'];
        if (data != null && data is List) {
          final records = (data)
              .map((json) =>
                  CourseAttendanceRecord.fromJson(json as Map<String, dynamic>))
              .toList();

          return ApiResponse(
            response: records,
            status: response.status,
            statusCode: response.statusCode,
            message: response.message,
          );
        }
      } catch (e) {
        return ApiResponse(
          status: ApiResponseStatus.Error,
          message: 'Failed to parse attendance records',
        );
      }
    }

    return ApiResponse(
      status: response.status,
      statusCode: response.statusCode,
      message: response.message ?? 'Failed to get attendance record',
    );
  }

  Future<ApiResponse<MarkAttendanceResponse>> markAttendance(
    MarkAttendanceRequest request,
  ) async {
    final response = await requester.makeAppRequest(
      apiEndPoint: ApiEndPoint.createApiEndpoint(
        path: _markAttendanceBasePath,
        requestType: HttpVerb.POST,
        body: request.toMap(),
      ),
    );

    if (response.response != null && response.response is Map) {
      final hasError = response.response['error'] == true;
      final errorMessage = response.response['message'] as String?;

      if (hasError) {
        return ApiResponse(
          status: ApiResponseStatus.Error,
          statusCode: response.statusCode,
          message: errorMessage ?? 'Failed to mark attendance',
        );
      }
    }

    if (response.status == ApiResponseStatus.Success) {
      try {
        final markResponse = MarkAttendanceResponse.fromJson(response.response);

        return ApiResponse(
          response: markResponse,
          status: response.status,
          statusCode: response.statusCode,
          message: response.message ?? 'Attendance marked successfully',
        );
      } catch (e) {
        return ApiResponse(
          status: ApiResponseStatus.Error,
          message: 'Failed to parse mark attendance response',
        );
      }
    }

    return ApiResponse(
      status: response.status,
      statusCode: response.statusCode,
      message: response.message ?? 'Failed to mark attendance',
    );
  }

  Future<ApiResponse<ListDataResponse<AttendanceHistory>>> getAttendanceHistory(
      GetAttendanceHistoryRequest request) async {
    final response = await requester.makeAppRequest(
      apiEndPoint: ApiEndPoint.createApiEndpoint(
        path: _getAttendanceHistoryBasePath,
        requestType: HttpVerb.GET,
        body: request.toMap(),
      ),
    );

    final data = ListDataResponse<AttendanceHistory>.fromJson(
      response.response,
      (json) => AttendanceHistory.fromJson(json),
    );

    return ApiResponse(
      response: data,
      status: response.status,
      statusCode: response.statusCode,
      message: response.message ?? 'Failed to get attendance history',
    );
  }
}
