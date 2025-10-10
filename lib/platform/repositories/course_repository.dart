import 'package:attendance_app/platform/api/api_response.dart';
import 'package:attendance_app/platform/api/course_api.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';

class CourseRepository {
  final CourseApi _courseApi;

  CourseRepository({CourseApi? courseApi})
      : _courseApi = courseApi ?? CourseApi();

  Future<ApiResponse<List<Course>>> fetchAllCourses() async {
    return await _courseApi.getAllCourses();
  }

  Future<ApiResponse<List<Course>>> fetchCoursesForLevelAndSemester(
      String level, int semester) async {
    return await _courseApi.getCoursesForLevelAndSemester(level, semester);
  }

  // Future<ApiResponse<Map<String, dynamic>>> registerCourses({
  //   required String studentId,
  //   required List<Map<String, dynamic>> courses,
  // }) async {
  //   return await _courseApi.registerCourses(
  //     studentId: studentId,
  //     courses: courses,
  //   );
  // }

  Future<ApiResponse<List<Course>>> fetchRegisteredCourses(
      String studentId) async {
    return await _courseApi.getRegisteredCourses(studentId);
  }
}
