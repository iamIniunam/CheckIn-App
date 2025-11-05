import 'dart:ui';

import 'package:attendance_app/platform/data_source/api/api_base_models.dart';
import 'package:attendance_app/ux/shared/components/global_functions.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';

class Course extends Serializable {
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

  static List<Course> assignUniqueColors(List<Course> courses) {
    final int paletteLen = courseColors.length;
    final used = List<bool>.filled(paletteLen, false);
    final result = <Course>[];

    for (final c in courses) {
      final baseKey =
          (c.id != null && (c.id ?? 0) > 0) ? c.id! : c.courseCode.hashCode;
      int idx = baseKey.abs() % paletteLen;
      final start = idx;

      while (used[idx]) {
        idx = (idx + 1) % paletteLen;
        if (idx == start) break;
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
    required this.courseTitle,
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
      id: json['id'] as int?,
      courseCode: json['code'] as String,
      courseTitle: json['name'] as String?,
      creditHours: json['credit_hours'] as int?,
      level: json['level']?.toString(),
      semester: json['semester'] as int?,
      school: json['school'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': courseTitle,
      'code': courseCode,
      'credit_hours': creditHours,
      'level': level,
      'semester': semester,
      'school': school,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          courseCode == other.courseCode;

  @override
  int get hashCode => id.hashCode ^ courseCode.hashCode;
}

class RegisterCourseResponse extends Serializable {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  RegisterCourseResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory RegisterCourseResponse.fromJson(Map<String, dynamic> json) {
    final errorFlag = json['error'];
    final message = json['message'] as String?;
    final data = json['data'];

    bool success = false;
    if (data != null) {
      success = true;
    } else if (errorFlag != null && errorFlag == false) {
      success = true;
    } else if (message != null && message.toLowerCase().contains('success')) {
      success = true;
    }

    return RegisterCourseResponse(
      success: success,
      message: message,
      data: data is Map<String, dynamic> ? data : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}
