import 'package:attendance_app/platform/api/api_response.dart';
import 'package:attendance_app/platform/services/networking.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<ApiResponse<Map<String, dynamic>>> login(
      {required String idNumber, required String password}) async {
    try {
      final networkHelper = NetworkHelper(
        method: HttpMethod.post,
        url: AppConstants.apiBaseUrl,
        path: '/student/login',
        // headers: {
        //   'Content-Type': 'application/json',
        //   'Accept': 'application/json',
        // },
        queryParams: {
          'idnumber': idNumber,
          'password': password,
        },
        errorMessage: 'Failed to login',
      );

      final response = await networkHelper.getData();
      debugPrint('Response: $response');

      if (response != null) {
        if (response['data'] != null) {
          return ApiResponse.success(response['data']);
        } else {
          return ApiResponse.error(response['message'] ?? 'Login failed');
        }
      } else {
        return ApiResponse.error('Network error. Please try again.');
      }
    } on http.ClientException {
      return ApiResponse.error('Network error. Please check your connection.');
    } on FormatException {
      return ApiResponse.error('Invalid reponse from server');
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
        path: '/courses/getCoursesForLevelAndSemester/$level/$semester',
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
}
