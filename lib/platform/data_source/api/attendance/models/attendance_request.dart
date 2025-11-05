class GetCourseAttendanceRequest {
  final int courseId;
  final String studentId;

  GetCourseAttendanceRequest({
    required this.courseId,
    required this.studentId,
  });

  Map<String, dynamic> toMap() {
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
  final double? latitude;
  final double? longitude;

  MarkAttendanceRequest({
    required this.code,
    required this.studentId,
    required this.status,
    this.location,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'student_id': studentId,
      'status': status,
      if (location != null) 'location': location,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  String? validate() {
    if (code.trim().isEmpty) {
      return 'Code is required';
    }
    if (studentId.trim().isEmpty) {
      return 'Student ID is required';
    }
    if (status.trim().isEmpty) {
      return 'Status is required';
    }
    return null;
  }
}

enum AttendanceStatus {
  authorized,
  unauthorized;

  String get value => name;
}
