import 'package:attendance_app/ux/shared/components/global_functions.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class Student {
  final String idNumber;
  final String firstName;
  final String lastName;
  final String program;
  final String? password;
  final String? level;
  final int? semester;

  Student(
      {required this.idNumber,
      required this.firstName,
      required this.lastName,
      required this.program,
      this.password,
      this.level,
      this.semester});

  factory Student.fromJson(Map<String, dynamic> json,
      {String? level, int? semester}) {
    return Student(
      idNumber: json['idnumber'] ?? json['id_number'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      program: json['program'] ?? '',
      password: json['password'] ?? '',
      level: level,
      semester: semester,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idnumber': idNumber,
      'first_name': firstName,
      'last_name': lastName,
      'program': program,
      'password': password,
      'level': level,
      'semester': semester,
    };
  }

  Student copyWith({
    String? idNumber,
    String? firstName,
    String? lastName,
    String? program,
    String? password,
    String? level,
    int? semester,
  }) {
    return Student(
      idNumber: idNumber ?? this.idNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      program: program ?? this.program,
      password: password ?? this.password,
      level: level ?? this.level,
      semester: semester ?? this.semester,
    );
  }
}

class Course {
  final int? id;
  final String courseCode;
  final String? courseTitle;
  final int? creditHours;
  final String? level;
  final int? semester;
  final String? school;
  final String? status;
  final bool showStatus;
  late final Color color;

  static const List<Color> courseColors = [
    AppColors.boxColor1,
    AppColors.boxColor2,
    AppColors.boxColor3,
    AppColors.boxColor4,
    AppColors.boxColor5,
    AppColors.boxColor6,
    AppColors.boxColor7,
    AppColors.boxColor8,
  ];

  static Color getColorByIndex(int index) {
    return courseColors[index % courseColors.length];
  }

  Color get getStatusColor => statusColor(status ?? '');

  Course({
    this.id,
    required this.courseCode,
    this.courseTitle,
    this.creditHours,
    this.level,
    this.semester,
    this.school,
    this.status,
    this.showStatus = false,
    int? index,
  }) : color = Course.getColorByIndex(index ?? 0);

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      courseCode: json['code'],
      courseTitle: json['name'],
      level: json['level'],
      semester: json['semester'],
      school: json['school'],
      creditHours: json['credit_hours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': courseTitle,
      'code': courseCode,
      'level': level,
      'semester': semester,
      'school': school,
      'credit_hours': creditHours,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class AttendanceClass {
  final int id;
  final String name;
  final int courseId;
  final DateTime date;

  AttendanceClass({
    required this.id,
    required this.name,
    required this.courseId,
    required this.date,
  });

  factory AttendanceClass.fromJson(Map<String, dynamic> json) {
    return AttendanceClass(
      id: json['id'] as int,
      name: json['name'] as String,
      courseId: json['course_id'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'course_id': courseId,
      'date': date.toIso8601String(),
    };
  }
}

class AttendanceRecord {
  final int id;
  final String studentId;
  final int classId;
  final DateTime date;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.date,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as int,
      studentId: json['student_id'] as String,
      classId: json['class_id'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'class_id': classId,
      'date': date.toIso8601String(),
    };
  }
}

class CourseAttendanceRecord {
  final AttendanceClass attendanceClass;
  final AttendanceRecord? attendanceRecord;

  CourseAttendanceRecord(
      {required this.attendanceClass, this.attendanceRecord});

  bool get isPresent => attendanceRecord != null;

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

  Map<String, dynamic> toJson() {
    return {
      'class': attendanceClass.toJson(),
      'attendance_record': attendanceRecord?.toJson(),
    };
  }
}
