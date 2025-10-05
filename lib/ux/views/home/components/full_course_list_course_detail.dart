import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class FullCourseListCourseDetail extends StatelessWidget {
  const FullCourseListCourseDetail({super.key, required this.detail});

  final String detail;

  @override
  Widget build(BuildContext context) {
    return Text(
      detail,
      style: const TextStyle(
        color: AppColors.defaultColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
