import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/views/attendance/components/padded_column.dart';
import 'package:flutter/material.dart';

class CourseEnrollmentCard extends StatelessWidget {
  const CourseEnrollmentCard(
      {super.key,
      required this.semesterCourse,
      required this.selectedSchool,
      required this.onTapSchool});

  final Course semesterCourse;
  final String? selectedSchool;
  final ValueChanged<String> onTapSchool;

  @override
  Widget build(BuildContext context) {
    return AppMaterial(
      inkwellBorderRadius: BorderRadius.circular(10),
      onTap: () {
        // if (selectedSchool != null) {
        onTapSchool(selectedSchool ?? '');
        // }
      },
      child: Container(
        decoration: BoxDecoration(
          color: (selectedSchool != null)
              ? AppColors.primaryTeal
              : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: (selectedSchool != null)
                ? AppColors.defaultColor
                : AppColors.grey,
          ),
        ),
        child: PaddedColumn(
          padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
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
              // maxLines: 2,
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
