class GetCoursesForLevelAndSemesterRequest {
  final String levelId;
  final String semesterId;

  GetCoursesForLevelAndSemesterRequest({
    required this.levelId,
    required this.semesterId,
  });

  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId,
      'semesterId': semesterId,
    };
  }
}

class RegisterCourseRequest {
  final int courseId;
  final String studentId;

  RegisterCourseRequest({
    required this.courseId,
    required this.studentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'course_id': courseId,
      'idnumber': studentId,
    };
  }

  String? validate() {
    if (courseId <= 0) {
      return 'Invalid course ID';
    }
    if (studentId.trim().isEmpty) {
      return 'Student ID is required';
    }
    return null;
  }
}

class GetRegisteredCoursesRequest {
  final String studentId;

  GetRegisteredCoursesRequest({
    required this.studentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
    };
  }

  String? validate() {
    if (studentId.trim().isEmpty) {
      return 'Student ID is required';
    }
    return null;
  }
}