import 'package:attendance_app/platform/data_source/api/course/models/course_response.dart';
import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/views/attendance/components/padded_column.dart';
import 'package:flutter/material.dart';

class CourseEnrollmentCard extends StatelessWidget {
  const CourseEnrollmentCard({
    super.key,
    required this.semesterCourse,
    this.isSelected = false,
    required this.onTap,
  });

  final Course semesterCourse;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppMaterial(
      inkwellBorderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: (isSelected) ? AppColors.primaryTeal : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: (isSelected) ? AppColors.defaultColor : AppColors.grey,
          ),
        ),
        child: PaddedColumn(
          padding: const EdgeInsets.all(8),
          children: [
            Text(
              '${semesterCourse.courseCode} (${(semesterCourse.creditHours).toString()})',
              style: const TextStyle(
                color: AppColors.defaultColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              semesterCourse.courseTitle ?? '',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.defaultColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            SingleSchool(school: semesterCourse.school ?? ''),
          ],
        ),
      ),
    );
  }
}

class SingleSchool extends StatelessWidget {
  const SingleSchool({super.key, required this.school});

  final String school;

  @override
  Widget build(BuildContext context) {
    return Text(
      school,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.defaultColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
