import 'package:attendance_app/platform/api/api_response.dart';
import 'package:attendance_app/platform/services/networking.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CourseApi {
  final _basePath = '/courses/getCoursesForLevelAndSemester';
  final _courseAttendancebasePath = '/student/getCourseAttendanceRecord';

  Future<ApiResponse<List<Course>>> getCoursesForLevelAndSemester(
      String level, int semester) async {
    try {
      final networkHelper = NetworkHelper(
        url: AppConstants.apiBaseUrl,
        method: HttpMethod.get,
        path: '$_basePath/$level/$semester',
        errorMessage: 'Failed to get courses',
      );

      final response = await networkHelper.getData();
      debugPrint('Courses Response: $response');

      if (response != null) {
        if (response['data'] != null) {
          final List<dynamic> coursesJson = response['data'] as List<dynamic>;
          final List<Course> courses = coursesJson
              .map((json) => Course.fromJson(json as Map<String, dynamic>))
              .toList();

          return ApiResponse.success(courses);
        } else {
          return ApiResponse.error(
              response['message'] ?? 'Failed to get courses');
        }
      } else {
        return ApiResponse.error('Network error. Please try again');
      }
    } on http.ClientException {
      return ApiResponse.error('Network error. Please check your connection.');
    } on FormatException {
      return ApiResponse.error('Invalid response from server');
    } catch (e) {
      return ApiResponse.error('An unexpected error occured: ${e.toString()}');
    }
  }

  Future<ApiResponse<List<CourseAttendanceRecord>>> getCourseAttendanceRecord(
      int courseId, String studentId) async {
    debugPrint('===== CourseApi.getCourseAttendanceRecord called =====');
    debugPrint('courseId: $courseId, studentId: $studentId');

    try {
      final path = '$_courseAttendancebasePath/$courseId/$studentId';
      final fullUrl = '${AppConstants.apiBaseUrl}$path';
      debugPrint('Full URL: $fullUrl');

      final networkHelper = NetworkHelper(
        url: AppConstants.apiBaseUrl,
        method: HttpMethod.get,
        path: path,
        errorMessage: 'Failed to get attendance',
      );
      debugPrint(
          'Url: ${AppConstants.apiBaseUrl}$_courseAttendancebasePath/$courseId/$studentId');

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
        return ApiResponse.error('Network error. Please try again');
      }
    } on http.ClientException {
      return ApiResponse.error('Network error. Please check your connection.');
    } on FormatException {
      return ApiResponse.error('Invalid response from server');
    } catch (e) {
      debugPrint('Exception in getCourseAttendanceRecord: $e');
      return ApiResponse.error('An unexpected error occured: ${e.toString()}');
    }
  }
}

// php artisan serve --host=ipaddress
