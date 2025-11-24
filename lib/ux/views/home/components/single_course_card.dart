import 'package:attendance_app/platform/data_source/api/course/models/course_response.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/views/attendance/components/padded_column.dart';
import 'package:attendance_app/ux/views/course/course_details_page.dart';
import 'package:flutter/material.dart';

class SingleCourseCard extends StatelessWidget {
  const SingleCourseCard({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return AppMaterial(
      color: course.color,
      borderRadius: BorderRadius.circular(15),
      inkwellBorderRadius: BorderRadius.circular(15),
      elevation: 1,
      onTap: () {
        Navigation.navigateToScreen(
          context: context,
          screen: CourseDetailsPage(course: course),
        );
      },
      child: PaddedColumn(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            course.creditHours.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.defaultColor,
              fontSize: 25,
              fontWeight: FontWeight.w300,
            ),
          ),
          Text(
            course.courseCode,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.defaultColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
