import 'package:attendance_app/platform/data_source/api/api_base_models.dart';
import 'package:attendance_app/ux/shared/components/global_functions.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:flutter/material.dart';

class AttendanceClass extends Serializable {
  final int? id;
  final String? name;
  final int? courseId;
  final String? mode;
  final DateTime? date;

  AttendanceClass({
    this.id,
    this.name,
    this.courseId,
    this.mode,
    this.date,
  });

  factory AttendanceClass.fromJson(Map<String, dynamic> json) {
    return AttendanceClass(
      id: json['id'] as int,
      name: json['name'] as String,
      courseId: json['course_id'] as int,
      mode: (json['mode'] as String?) ?? 'Unknown',
      date: DateTime.parse(json['date'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'course_id': courseId,
      'mode': mode,
      'date': date?.toIso8601String(),
    };
  }
}

class AttendanceRecord extends Serializable {
  final int? id;
  final String? studentId;
  final int? classId;
  final DateTime? date;
  final String? status;

  AttendanceRecord({
    this.id,
    this.studentId,
    this.classId,
    this.date,
    this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as int,
      studentId: json['student_id'] as String,
      classId: json['class_id'] as int,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'class_id': classId,
      'date': date?.toIso8601String(),
      'status': status,
    };
  }
}

class CourseAttendanceRecord extends Serializable {
  final AttendanceClass attendanceClass;
  final AttendanceRecord? attendanceRecord;

  CourseAttendanceRecord({
    required this.attendanceClass,
    this.attendanceRecord,
  });

  bool get isPresent =>
      attendanceRecord != null &&
      (attendanceRecord?.status ?? '') == AttendanceStatus.authorized.value;

  String get status => isPresent ? 'Present' : 'Absent';
  Color get getStatusColor => statusColor(status);

  factory CourseAttendanceRecord.fromJson(Map<String, dynamic> json) {
    try {
      return CourseAttendanceRecord(
        attendanceClass:
            AttendanceClass.fromJson(json['class'] as Map<String, dynamic>),
        attendanceRecord: json['attendance_record'] != null
            ? AttendanceRecord.fromJson(
                json['attendance_record'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      debugPrint('Error parsing CourseAttendanceRecord: $e');
      debugPrint('JSON: $json');
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'class': attendanceClass.toMap(),
      'attendance_record': attendanceRecord?.toMap(),
    };
  }
}

class MarkAttendanceResponse extends Serializable {
  final bool success;
  final String? message;

  MarkAttendanceResponse({
    required this.success,
    this.message,
  });

  factory MarkAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return MarkAttendanceResponse(
      success: json['error'] == false || json['message'] == 'Success',
      message: json['message'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
    };
  }
}

class AttendanceMarkResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const AttendanceMarkResult({
    required this.success,
    this.message,
    this.errorMessage,
  });

  factory AttendanceMarkResult.success([String? message]) {
    return AttendanceMarkResult(
      success: true,
      message: message ?? 'Attendance marked successfully',
    );
  }

  factory AttendanceMarkResult.failure(String errorMessage) {
    return AttendanceMarkResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

class AttendanceHistory extends Serializable {
  final int? classId;
  final String? className;
  final DateTime? classDate;
  final String? mode;
  final int? courseId;
  final String? code;
  final String? name;

  final int? attendanceId;
  final String? status;
  final String? location;
  final DateTime? attendanceDate;
  final String? attendanceStatus;

  Color get getStatusColor => statusColor(attendanceStatus ?? '');

  AttendanceHistory({
    this.classId,
    this.className,
    this.classDate,
    this.mode,
    this.courseId,
    this.code,
    this.name,
    this.attendanceId,
    this.status,
    this.location,
    this.attendanceDate,
    this.attendanceStatus,
  });

  factory AttendanceHistory.fromJson(Map<String, dynamic> json) {
    return AttendanceHistory(
      classId: json['class_id'],
      className: json['class_name'],
      classDate: DateTime.parse(json['class_date']),
      mode: json['mode'],
      courseId: json['course_id'],
      code: json['code'],
      name: json['name'],
      attendanceId: json['attendance_id'],
      status: json['status'],
      location: json['location'],
      attendanceDate: json['attendance_date'] != null
          ? DateTime.parse(json['attendance_date'])
          : null,
      attendanceStatus: json['attendance'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'class_id': classId,
      'class_name': className,
      'class_date': classDate?.toIso8601String(),
      'mode': mode,
      'course_id': courseId,
      'code': code,
      'name': name,
      'attendance_id': attendanceId,
      'status': status,
      'location': location,
      'attendance_date': attendanceDate?.toIso8601String(),
      'attendance': attendanceStatus,
    };
  }
}

class AttendanceSummary {
  final int totalClasses;
  final int attendedClasses;
  final int missedClasses;
  final int attendancePercentage;

  AttendanceSummary({
    required this.totalClasses,
    required this.attendedClasses,
    required this.missedClasses,
    required this.attendancePercentage,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalClasses: json['totalClasses'] ?? 0,
      attendedClasses: json['attendedClasses'] ?? 0,
      missedClasses: json['missedClasses'] ?? 0,
      attendancePercentage: json['attendancePercentage'] ?? 0,
    );
  }
}
