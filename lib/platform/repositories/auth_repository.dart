import 'package:attendance_app/platform/api/api_response.dart';
import 'package:attendance_app/platform/api/api_service.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<ApiResponse<Student>> login({
    required String idNumber,
    required String password,
  }) async {
    try {
      final response =
          await _apiService.login(idNumber: idNumber, password: password);

      if (response.success && response.data != null) {
        final studentData = response.data?['student'] ?? response.data;
        final student = Student.fromJson(studentData);

        return ApiResponse.success(student, message: response.message);
      } else {
        return ApiResponse.error(
          response.message ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Failed to process login: ${e.toString()}');
    }
  }
}
