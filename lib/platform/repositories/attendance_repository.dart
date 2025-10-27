import 'package:attendance_app/platform/api/api_response.dart';
import 'package:attendance_app/platform/api/attendance/attendance_api.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';

class AttendanceRepository {
  final AttendanceApi _attendanceApi;

  AttendanceRepository({AttendanceApi? attendanceApi})
      : _attendanceApi = attendanceApi ?? AttendanceApi();

  Future<ApiResponse<List<CourseAttendanceRecord>>> fetchCourseAttendanceRecord(
      int courseId, String studentId) async {
    return await _attendanceApi.getCourseAttendanceRecord(courseId, studentId);
  }
}
