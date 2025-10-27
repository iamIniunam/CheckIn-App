import 'package:attendance_app/platform/api/api_response.dart';
import 'package:attendance_app/platform/api/network_strings.dart';
import 'package:attendance_app/platform/api/networking.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';

class CourseApi {
  final _courseBasePath = '/courses/getAllCourses';
  final _coursesForLevelBasePath = '/courses/getCoursesForLevelAndSemester';
  final _registerCoursesBasePath = '/student/registerCourse';
  final _registeredCoursesBasePath = '/student/getRegisteredCourses';

  Future<ApiResponse<List<Course>>> getAllCourses() async {
    try {
      final networkHelper = NetworkHelper(
        url: AppConstants.apiBaseUrl,
        path: _courseBasePath,
        method: HttpMethod.get,
        errorMessage: 'Failed to get courses',
        timeout: const Duration(seconds: 10),
      );

      final response = await networkHelper.getData();
      // debugPrint('All Courses Response: $response');

      if (response != null) {
        final data = response['data'];
        if (data != null && data is List) {
          final List<dynamic> coursesJson = List<dynamic>.from(data);
          final List<Course> courses = coursesJson
              .map((json) => Course.fromJson(json as Map<String, dynamic>))
              .toList();

          return ApiResponse.success(courses);
        } else {
          return ApiResponse.error(
              response['message'] ?? 'Failed to get courses');
        }
      } else {
        return ApiResponse.error(NetworkStrings.noResponse);
      }
    } on NetworkException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      debugPrint('Unexpected error in getting all courses: $e');
      return ApiResponse.error(NetworkStrings.somethingWentWrong);
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
        timeout: const Duration(seconds: 10),
      );

      final response = await networkHelper.getData();
      // debugPrint('Courses Response: $response');

      if (response != null) {
        final data = response['data'];
        if (data != null && data is List) {
          final List<dynamic> coursesJson = List<dynamic>.from(data);
          final List<Course> courses = coursesJson
              .map((json) => Course.fromJson(json as Map<String, dynamic>))
              .toList();

          return ApiResponse.success(courses);
        } else {
          return ApiResponse.error(
              response['message'] ?? 'Failed to get courses');
        }
      } else {
        return ApiResponse.error(NetworkStrings.noResponse);
      }
    } on NetworkException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      debugPrint(
          'Unexpected error in getting courses for level and semester: $e');
      return ApiResponse.error(NetworkStrings.somethingWentWrong);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> registerCourse({
    required int courseId,
    required String studentId,
  }) async {
    try {
      final networkHelper = NetworkHelper(
        url: AppConstants.apiBaseUrl,
        method: HttpMethod.post,
        path: _registerCoursesBasePath,
        queryParams: {
          'course_id': courseId,
          'idnumber': studentId,
        },
        // body: {
        //   'course_id': courseId,
        //   'idnumber': studentId,
        // },
        errorMessage: 'Failed to register courses',
      );

      final response = await networkHelper.getData();
      // debugPrint('Register Course Response: $response');

      if (response != null) {
        final data = response['data'];

        if (data != null) {
          // Ensure we return a Map<String, dynamic> as the API expects.
          if (data is Map<String, dynamic>) {
            return ApiResponse.success(
              data,
              message: response['message'] ?? 'Course registered successfully',
            );
          }

          // If the API returned a primitive (e.g. int or string), wrap it.
          return ApiResponse.success(
            {'result': data},
            message: response['message'] ?? 'Course registered successfully',
          );
        }

        // Some backends return a success message without a 'data' key.
        // Treat a response with no data but an explicit success indication
        // (e.g. error == false or a success message) as a successful registration.
        final errorFlag = response['error'];
        final message = response['message'];

        if ((errorFlag != null && errorFlag == false) ||
            (message != null &&
                message.toString().toLowerCase().contains('success'))) {
          return ApiResponse.success(
            <String, dynamic>{},
            message: message ?? 'Course registered successfully',
          );
        }

        return ApiResponse.error(
            response['message'] ?? 'Failed to register course');
      } else {
        return ApiResponse.error(NetworkStrings.noResponse);
      }
    } on NetworkException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      debugPrint('Unexpected error in getting registered courses: $e');
      return ApiResponse.error(NetworkStrings.somethingWentWrong);
    }
  }

  Future<ApiResponse<List<Course>>> getRegisteredCourses(
      String studentId) async {
    try {
      final networkHelper = NetworkHelper(
        url: AppConstants.apiBaseUrl,
        method: HttpMethod.get,
        path: '$_registeredCoursesBasePath/$studentId',
        errorMessage: 'Failed to get registered courses',
        timeout: const Duration(seconds: 10),
      );

      final response = await networkHelper.getData();
      // debugPrint('Registered Courses Response: $response');

      if (response == null) {
        debugPrint('Registered Courses Error: No response received');
      }

      if (response != null) {
        final data = response['data'];
        if (data != null && data is List) {
          final List<dynamic> coursesJson = List<dynamic>.from(data);
          final List<Course> courses = coursesJson
              .map((json) => Course.fromJson(json as Map<String, dynamic>))
              .toList();

          return ApiResponse.success(courses);
        } else {
          return ApiResponse.error(
              response['message'] ?? 'Failed to get registered courses');
        }
      } else {
        return ApiResponse.error(NetworkStrings.noResponse);
      }
    } on NetworkException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      debugPrint('Unexpected error in getting registered courses: $e');
      return ApiResponse.error(NetworkStrings.somethingWentWrong);
    }
  }
}
