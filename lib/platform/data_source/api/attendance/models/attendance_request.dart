import 'package:attendance_app/platform/data_source/api/api_base_models.dart';

class GetCourseAttendanceRequest extends Serializable {
  final int? courseId;
  final String? studentId;
  final num? pageIndex;
  final num? pageSize;

  GetCourseAttendanceRequest({
    this.courseId,
    this.studentId,
    this.pageIndex,
    this.pageSize,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'studentId': studentId,
      'pageIndex': pageIndex,
      'pageSize': pageSize,
    };
  }
}

class MarkAttendanceRequest extends Serializable {
  final String? code;
  final String? studentId;
  final String? status;
  final String? location;
  final double? latitude;
  final double? longitude;

  MarkAttendanceRequest({
    this.code,
    this.studentId,
    this.status,
    this.location,
    this.latitude,
    this.longitude,
  });

  @override
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
    if ((code ?? '').trim().isEmpty) {
      return 'Code is required';
    }
    if ((studentId ?? '').trim().isEmpty) {
      return 'Student ID is required';
    }
    if ((status ?? '').trim().isEmpty) {
      return 'Status is required';
    }
    return null;
  }
}

class GetAttendanceHistoryRequest extends Serializable {
  final String studentId;
  final num? pageIndex;
  final num? pageSize;

  GetAttendanceHistoryRequest({
    required this.studentId,
    this.pageIndex = 1,
    this.pageSize = 10,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'page': pageIndex,
      'per_page': pageSize,
    };
  }
}
