import 'package:attendance_app/platform/api/api_response.dart';
import 'package:attendance_app/platform/api/network_strings.dart';
import 'package:attendance_app/platform/api/networking.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';

class AuthApi {
  final _basePath = '/student/login';

  Future<ApiResponse<Map<String, dynamic>>> login(
      {required String idNumber, required String password}) async {
    try {
      final networkHelper = NetworkHelper(
        method: HttpMethod.post,
        url: AppConstants.apiBaseUrl,
        path: _basePath,
        queryParams: {
          'idnumber': idNumber,
          'password': password,
        },
        errorMessage: 'Failed to login',
        timeout: const Duration(seconds: 10),
      );

      final response = await networkHelper.getData();
      debugPrint('Login Response: $response');

      if (response != null) {
        if (response['data'] != null) {
          return ApiResponse.success(response['data']);
        } else {
          return ApiResponse.error(
              response['message'] ?? 'Login failed. Please try again.');
        }
      } else {
        return ApiResponse.error(NetworkStrings.noResponse);
      }
    } on NetworkException catch (e) {
      // NetworkException already has user-friendly messages from NetworkStrings
      return ApiResponse.error(e.message);
    } catch (e) {
      debugPrint('Unexpected error in login: $e');
      return ApiResponse.error(NetworkStrings.somethingWentWrong);
    }
  }
}
