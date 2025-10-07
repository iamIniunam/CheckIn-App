import 'dart:ui';
import 'package:attendance_app/ux/shared/components/global_functions.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class Student {
  final String idNumber;
  final String firstName;
  final String lastName;
  final String program;
  final String passowrd;
  // final String level;
  // final String semester;

  Student({
    required this.idNumber,
    required this.firstName,
    required this.lastName,
    required this.program,
    required this.passowrd,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      idNumber: json['idnumber'] ?? json['id_number'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      program: json['program'],
      passowrd: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idnumber': idNumber,
      'firstName': firstName,
      'lastName': lastName,
      'program': program,
      'password': passowrd,
    };
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

class Session {
  final int weekNumber;
  final String date;
  final String status;

  String get session => 'Week $weekNumber';

  Color get getStatusColor => statusColor(status);

  Session({
    required this.weekNumber,
    required this.date,
    required this.status,
  });
}
