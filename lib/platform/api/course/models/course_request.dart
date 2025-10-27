class GetCoursesForLevelAndSemesterRequest {
  final String levelId;
  final String semesterId;

  GetCoursesForLevelAndSemesterRequest({
    required this.levelId,
    required this.semesterId,
  });

  Map<String, dynamic> toJson() {
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

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'studentId': studentId,
    };
  }
}

class GetRegisteredCoursesRequest {
  final String studentId;

  GetRegisteredCoursesRequest({
    required this.studentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
    };
  }
}
