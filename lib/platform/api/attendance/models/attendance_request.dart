class AttendanceRequest {
  final int courseId;
  final String studentId;

  AttendanceRequest({
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