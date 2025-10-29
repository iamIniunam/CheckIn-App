import 'package:attendance_app/platform/api/attendance/models/attendance_request.dart';
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
    AppColors.lightGrey,
    AppColors.softRose,
    AppColors.mintMist,
    AppColors.babyBlue,
    AppColors.paleAmber,
    AppColors.lavenderHaze,
    AppColors.aquaWhisper,
    AppColors.lilacBloom,
    AppColors.blushPearl,
  ];

  static Color getColorByIndex(int index) {
    return courseColors[index % courseColors.length];
  }

  /// Assign a stable, unique color index to each course in [courses].
  ///
  /// This returns a new list of `Course` objects where each course has an
  /// `index` chosen deterministically from the course `id` (or `courseCode`
  /// fallback) and collisions are resolved by linear probing so colors are
  /// not duplicated until the palette is exhausted. If there are more
  /// courses than available colors, colors will necessarily repeat but this
  /// algorithm still tries to maximize uniqueness.
  static List<Course> assignUniqueColors(List<Course> courses) {
    final int paletteLen = courseColors.length;
    final used = List<bool>.filled(paletteLen, false);
    final result = <Course>[];

    for (final c in courses) {
      // Use numeric id when available, otherwise hash the courseCode to an int
      final baseKey =
          (c.id != null && (c.id ?? 0) > 0) ? c.id! : c.courseCode.hashCode;
      int idx = baseKey.abs() % paletteLen;
      final start = idx;

      // Linear probe to find an unused color index
      while (used[idx]) {
        idx = (idx + 1) % paletteLen;
        if (idx == start) break; // all used; will reuse
      }

      used[idx] = true;

      result.add(Course(
        id: c.id,
        courseCode: c.courseCode,
        courseTitle: c.courseTitle,
        creditHours: c.creditHours,
        level: c.level,
        semester: c.semester,
        school: c.school,
        status: c.status,
        showStatus: c.showStatus,
        index: idx,
      ));
    }

    return result;
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'course_id': courseId,
      'mode': mode,
      'date': date.toIso8601String(),
    };
  }
}

class AttendanceRecord {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'class_id': classId,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}

class CourseAttendanceRecord {
  final AttendanceClass attendanceClass;
  final AttendanceRecord? attendanceRecord;

  CourseAttendanceRecord(
      {required this.attendanceClass, this.attendanceRecord});

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

  Map<String, dynamic> toJson() {
    return {
      'class': attendanceClass.toJson(),
      'attendance_record': attendanceRecord?.toJson(),
    };
  }
}
