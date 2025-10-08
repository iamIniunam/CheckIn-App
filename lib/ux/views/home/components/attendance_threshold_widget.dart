import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/course/components/course_detail_item.dart';
import 'package:flutter/material.dart';

class AttendanceThresholdWidget extends StatelessWidget {
  const AttendanceThresholdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.only(left: 16, top: 10, right: 16),
        decoration: BoxDecoration(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.defaultColor),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CourseDetailItem(
                title: AppStrings.attendanceThreshold, value: '18/20'),
            SizedBox(width: 10),
            CourseDetailItem(title: AppStrings.midSemester, value: '6/10'),
            SizedBox(width: 10),
            CourseDetailItem(title: AppStrings.endOfSemester, value: '6/20'),
          ],
        ),
      ),
    );
  }
}
