import 'package:attendance_app/platform/api/api_response.dart';
import 'package:attendance_app/platform/api/api_service.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';

class CourseRepository {
  final ApiService _apiService;

  CourseRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<ApiResponse<List<Course>>> fetchCoursesForLevelAndSemester(
      String level, int semester) async {
    return await _apiService.getCoursesForLevelAndSemester(level, semester);
  }
}
