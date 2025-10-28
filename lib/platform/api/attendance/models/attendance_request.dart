class GetCourseAttendanceRequest {
  final int courseId;
  final String studentId;

  GetCourseAttendanceRequest({
    required this.courseId,
    required this.studentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'studentId': studentId,
    };
  }
}

class MarkAttendanceRequest {
  final String code;
  final String studentId;
  final String status;
  final String? location;

  MarkAttendanceRequest({
    required this.code,
    required this.studentId,
    required this.status,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'studentId': studentId,
      'status': status,
      'location': location,
    };
  }
}

enum AttendanceStatus {
  authorized,
  unauthorized;

  String get value => name;
}
