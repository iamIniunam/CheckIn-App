import 'package:attendance_app/platform/data_source/api/api_base_models.dart';
import 'package:attendance_app/platform/data_source/api/attendance/models/attendance_request.dart';
import 'package:attendance_app/ux/shared/components/global_functions.dart';
import 'package:flutter/material.dart';

class AttendanceClass extends Serializable {
  final int id;
  final String name;
  final int courseId;
  final String mode;
  final DateTime date;

  AttendanceClass({
    required this.id,
    required this.name,
    required this.courseId,
    required this.mode,
    required this.date,
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
      'date': date.toIso8601String(),
    };
  }
}

class AttendanceRecord extends Serializable {
  final int id;
  final String studentId;
  final int classId;
  final DateTime date;
  final String? status;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.date,
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
      'date': date.toIso8601String(),
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