import 'package:attendance_app/platform/api/api_response.dart';
import 'package:attendance_app/platform/api/auth/auth_api.dart';
import 'package:attendance_app/platform/api/auth/models/auth_request.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';

class AuthRepository {
  final AuthApi _authApi;

  AuthRepository({AuthApi? authApi}) : _authApi = authApi ?? AuthApi();

  Future<ApiResponse<Student>> signUp(SignUpRequest request) async {
    try {
      // Validate request before sending
      final validationError = request.validate();
      if (validationError != null) {
        return ApiResponse.error(validationError);
      }

      final response = await _authApi.signUp(request);

      if (response.success) {
        // Try to parse student data from response
        try {
          final data = response.data ?? {};
          final student = Student.fromJson(data);

          return ApiResponse.success(
            student,
            message: response.message ?? 'Sign up successful',
          );
        } catch (e) {
          // If parsing fails but signup was successful, return a basic student object
          final student = Student(
            idNumber: request.idNumber,
            firstName: request.firstName,
            lastName: request.lastName,
            program: request.program,
          );

          return ApiResponse.success(
            student,
            message: response.message ?? 'Sign up successful',
          );
        }
      } else {
        return ApiResponse.error(
          response.message ?? 'Sign up failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Failed to process sign up: ${e.toString()}');
    }
  }

  Future<ApiResponse<Student>> login(LoginRequest request) async {
    try {
      // Validate request before sending
      final validationError = request.validate();
      if (validationError != null) {
        return ApiResponse.error(validationError);
      }

      final response = await _authApi.login(request);

      if (response.success) {
        try {
          final data = response.data ?? {};
          final student = Student.fromJson(data);

          return ApiResponse.success(
            student,
            message: response.message ?? 'Login successful',
          );
        } catch (e) {
          return ApiResponse.error(
              'Failed to parse login data: ${e.toString()}');
        }
      } else {
        return ApiResponse.error(
          response.message ?? 'Login failed. Please check your credentials.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Failed to process login: ${e.toString()}');
    }
  }
}
