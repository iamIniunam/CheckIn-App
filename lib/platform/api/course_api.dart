import 'package:attendance_app/platform/api/api_response.dart';
import 'package:attendance_app/platform/services/networking.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CourseApi {
  final _courseBasePath = '/courses/getAllCourses';
  final _coursesForLevelBasePath = '/courses/getCoursesForLevelAndSemester';
  // final _registereCoursesBasePath = '/student/getRegisteredCourses';
  final _registeredCoursesBasePath = '/student/getRegisteredCourses';

  Future<ApiResponse<List<Course>>> getAllCourses() async {
    try {
      final networkHelper = NetworkHelper(
        url: AppConstants.apiBaseUrl,
        path: _courseBasePath,
        method: HttpMethod.get,
        errorMessage: 'Failed to get courses',
      );

      final response = await networkHelper.getData();
      debugPrint('All Courses Response: $response');

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

  Future<ApiResponse<List<Course>>> getCoursesForLevelAndSemester(
      String level, int semester) async {
    try {
      final networkHelper = NetworkHelper(
        url: AppConstants.apiBaseUrl,
        method: HttpMethod.get,
        path: '$_coursesForLevelBasePath/$level/$semester',
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

  // Future<ApiResponse<Map<String, dynamic>>> registerCourses({
  //   required String studentId,
  //   required List<Map<String, dynamic>> courses,
  // }) async {
  //   try {
  //     final networkHelper = NetworkHelper(
  //       url: AppConstants.apiBaseUrl,
  //       method: HttpMethod.post,
  //       path: _registereCoursesBasePath,
  //       queryParams: {
  //         'studentId': studentId,
  //         'courses': courses,
  //       },
  //       errorMessage: 'Failed to register courses',
  //     );

  //     final response = await networkHelper.getData();
  //     debugPrint('Register Courses Response: $response');

  //     if (response != null) {
  //       if (response['data'] != null) {
  //         return ApiResponse.success(
  //           response['data'] ?? {},
  //           message: response['message'] ?? 'Courses registered successfully',
  //         );
  //       } else {
  //         return ApiResponse.error(
  //             response['message'] ?? 'Failed to register courses');
  //       }
  //     } else {
  //       return ApiResponse.error('Network error. Please try again');
  //     }
  //   } on http.ClientException {
  //     return ApiResponse.error('Network error. Please check your connection.');
  //   } on FormatException {
  //     return ApiResponse.error('Invalid response from server');
  //   } catch (e) {
  //     return ApiResponse.error('An unexpected error occured: ${e.toString()}');
  //   }
  // }

  Future<ApiResponse<List<Course>>> getRegisteredCourses(
      String studentId) async {
    try {
      final networkHelper = NetworkHelper(
        url: AppConstants.apiBaseUrl,
        method: HttpMethod.get,
        path: '$_registeredCoursesBasePath/$studentId',
        errorMessage: 'Failed to get registered courses',
      );

      final response = await networkHelper.getData();
      debugPrint('Registered Courses Response: $response');

      if (response != null) {
        if (response['data'] != null) {
          final List<dynamic> coursesJson = response['data'] as List<dynamic>;
          final List<Course> courses = coursesJson
              .map((json) => Course.fromJson(json as Map<String, dynamic>))
              .toList();

          return ApiResponse.success(courses);
        } else {
          return ApiResponse.error(
              response['message'] ?? 'Failed to get registered courses');
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
}
