import 'package:attendance_app/platform/api/api_response.dart';
import 'package:attendance_app/platform/api/network_strings.dart';
import 'package:attendance_app/platform/api/networking.dart';
import 'package:attendance_app/platform/api/auth/models/auth_request.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';

class AuthApi {
  final _signUpBasePath = '/student/sign-up';
  final _loginBasePath = '/student/login';

  Future<ApiResponse<Map<String, dynamic>>> signUp(
      SignUpRequest request) async {
    try {
      final networkHelper = NetworkHelper(
        method: HttpMethod.post,
        url: AppConstants.apiBaseUrl,
        path: _signUpBasePath,
        body: request.toJson(),
        errorMessage: 'Failed to sign up',
        timeout: const Duration(seconds: 10),
      );

      final response = await networkHelper.getData();
      debugPrint('Sign Up Response: $response');

      if (response != null) {
        // Check for success in response
        final message = response['message'] ?? '';
        final hasData = response['data'] != null;

        if (hasData || message.toLowerCase().contains('success')) {
          return ApiResponse.success(
            response['data'] ?? {},
            message: message,
          );
        } else {
          return ApiResponse.error(
            message.isNotEmpty ? message : 'Sign up failed. Please try again.',
          );
        }
      } else {
        return ApiResponse.error(NetworkStrings.noResponse);
      }
    } on NetworkException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      debugPrint('Unexpected error in sign up: $e');
      return ApiResponse.error(NetworkStrings.somethingWentWrong);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> login(LoginRequest request) async {
    try {
      final networkHelper = NetworkHelper(
        method: HttpMethod.post,
        url: AppConstants.apiBaseUrl,
        path: _loginBasePath,
        queryParams: request.toJson(),
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
