import 'package:attendance_app/platform/data_source/api/api_base_models.dart';

class GetAllCoursesRequest extends Serializable {
  final num? pageIndex;
  final num? pageSize;
  final String? searchQuery;
  final int? level;
  final int? semester;
  final String? school;

  GetAllCoursesRequest({
    this.pageIndex,
    this.pageSize,
    this.searchQuery,
    this.level,
    this.semester,
    this.school,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'pageIndex': pageIndex,
      'pageSize': pageSize,
      if (searchQuery != null) 'searchQuery': searchQuery,
      if (level != null) 'level': level,
      if (semester != null) 'semester': semester,
      if (school != null) 'school': school,
    };
  }
}

class GetCoursesForLevelAndSemesterRequest extends Serializable {
  final String? levelId;
  final String? semesterId;

  GetCoursesForLevelAndSemesterRequest({
    this.levelId,
    this.semesterId,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId,
      'semesterId': semesterId,
    };
  }
}

class RegisterCourseRequest extends Serializable {
  final int? courseId;
  final String? studentId;

  RegisterCourseRequest({
    this.courseId,
    this.studentId,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'course_id': courseId,
      'idnumber': studentId,
    };
  }

  String? validate() {
    if ((courseId ?? 0) <= 0) {
      return 'Invalid course ID';
    }
    if ((studentId ?? '').trim().isEmpty) {
      return 'Student ID is required';
    }
    return null;
  }
}

class GetRegisteredCoursesRequest extends Serializable {
  final String? studentId;

  GetRegisteredCoursesRequest({this.studentId});

  @override
  Map<String, dynamic> toMap() {
    return {'studentId': studentId};
  }

  String? validate() {
    if ((studentId ?? '').trim().isEmpty) {
      return 'Student ID is required';
    }
    return null;
  }
}

class DropCourseRequest extends Serializable {
  final String? studentId;
  final int? courseId;

  DropCourseRequest({
    this.studentId,
    this.courseId,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'course_id': courseId,
      'student_id': studentId,
    };
  }

  String? validate() {
    if ((courseId ?? 0) <= 0) {
      return 'Invalid course ID';
    }
    if ((studentId ?? '').trim().isEmpty) {
      return 'Student ID is required';
    }
    return null;
  }
}
