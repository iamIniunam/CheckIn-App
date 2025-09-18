import 'dart:ui';
import 'package:attendance_app/ux/shared/components/global_functions.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class Course {
  final String courseCode;
  final String? courseTitle;
  final int? creditHours;
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
    required this.courseCode,
    this.courseTitle,
    this.creditHours,
    this.status,
    this.showStatus = false,
    int? index,
  }) : color = Course.getColorByIndex(index ?? 0);
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
