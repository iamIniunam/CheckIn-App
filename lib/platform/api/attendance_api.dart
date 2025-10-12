import 'package:attendance_app/platform/api/api_response.dart';
import 'package:attendance_app/platform/api/network_strings.dart';
import 'package:attendance_app/platform/api/networking.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';

class AttendanceApi {
  final _courseAttendanceBasePath = '/student/getCourseAttendanceRecord';

  Future<ApiResponse<List<CourseAttendanceRecord>>> getCourseAttendanceRecord(
      int courseId, String studentId) async {
    try {
      final path = '$_courseAttendanceBasePath/$courseId/$studentId';

      final networkHelper = NetworkHelper(
        url: AppConstants.apiBaseUrl,
        method: HttpMethod.get,
        path: path,
        errorMessage: 'Failed to get attendance',
        timeout: const Duration(seconds: 10),
      );
      debugPrint(
          'Url: ${AppConstants.apiBaseUrl}$_courseAttendanceBasePath/$courseId/$studentId');

      final response = await networkHelper.getData();
      debugPrint('Attendance Record Response: $response');

      if (response != null) {
        if (response['data'] != null) {
          final List<dynamic> attendanceJson =
              response['data'] as List<dynamic>;
          final List<CourseAttendanceRecord> attendanceRecords = attendanceJson
              .map((json) =>
                  CourseAttendanceRecord.fromJson(json as Map<String, dynamic>))
              .toList();

          return ApiResponse.success(attendanceRecords);
        } else {
          return ApiResponse.error(
              response['message'] ?? 'Failed to get attendance record');
        }
      } else {
        return ApiResponse.error(NetworkStrings.noResponse);
      }
    } on NetworkException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      debugPrint('Unexpected error in getting course attendance record: $e');
      return ApiResponse.error(NetworkStrings.somethingWentWrong);
    }
  }
}
