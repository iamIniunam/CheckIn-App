import 'package:attendance_app/platform/providers/course_provider.dart';
import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/components/dashboard_metric_grid_view.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/course_details_page.dart';
import 'package:attendance_app/ux/views/home/components/section_header.dart';
import 'package:attendance_app/ux/views/home/full_course_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SemesterCoursesDashboardMetricView extends StatelessWidget {
  const SemesterCoursesDashboardMetricView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedSemesterCourses =
        context.watch<CourseProvider>().selectedCourses;

    final courseInfo = selectedSemesterCourses
        .asMap()
        .entries
        .map((entry) => Course(
              courseCode: entry.value.courseCode,
              courseTitle: entry.value.courseTitle,
              creditHours: entry.value.creditHours,
              status: entry.value.status,
              showStatus: entry.value.showStatus,
              lecturer: entry.value.lecturer,
              index: entry.key,
            ))
        .toList();

    return Column(
      children: [
        SectionHeader(
          period: AppStrings.semesterCourses,
          hasAction: courseInfo.length > 9,
          onTap: () {
            if (courseInfo.length > 9) {
              Navigation.navigateToScreen(
                context: context,
                screen: FullCourseListPage(
                  courses: courseInfo,
                ),
              );
            }
          },
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 16, top: 10, right: 16, bottom: 16),
          child: DashboardMetricGridView(
            children: [
              ...courseInfo
                  .map((course) =>
                      singleCourse(context: context, course: course))
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget singleCourse({required BuildContext context, required Course course}) {
    return AppMaterial(
      color: course.color,
      borderRadius: BorderRadius.circular(15),
      inkwellBorderRadius: BorderRadius.circular(15),
      elevation: 1,
      onTap: () {
        Navigation.navigateToScreen(
            context: context,
            screen: CourseDetailsPage(
              courseCode: course.courseCode,
              lecturer: course.lecturer ?? '',
            ));
      },
      child: Ink(
        padding:
            const EdgeInsets.only(left: 12, top: 10, right: 12, bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(
              course.creditHours.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.defaultColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              course.courseCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.defaultColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
