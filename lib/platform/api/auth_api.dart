import 'package:attendance_app/platform/api/api_response.dart';
import 'package:attendance_app/platform/services/networking.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthApi {
  final _basePath = '/student/login';

  Future<ApiResponse<Map<String, dynamic>>> login(
      {required String idNumber, required String password}) async {
    try {
      final networkHelper = NetworkHelper(
        method: HttpMethod.post,
        url: AppConstants.apiBaseUrl,
        path: _basePath,
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
}
