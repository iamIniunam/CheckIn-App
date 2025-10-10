import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/components/dashboard_metric_grid_view.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/course/course_details_page.dart';
import 'package:attendance_app/ux/shared/components/section_header.dart';
import 'package:attendance_app/ux/views/course/full_course_list_page.dart';
import 'package:attendance_app/ux/views/onboarding/course_enrollment_page.dart';
import 'package:flutter/material.dart';

class SemesterCoursesDashboardMetricView extends StatelessWidget {
  const SemesterCoursesDashboardMetricView({super.key});

  List<Course> get courseInfo => CourseViewModel().registeredCourses;

  @override
  Widget build(BuildContext context) {
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
                  // courseStreams: selectedStreams,
                ),
              );
            }
          },
        ),
        DashboardMetricGridView(
          padding:
              const EdgeInsets.only(left: 16, top: 10, right: 16, bottom: 16),
          crossAxisCount: 3,
          // Make tiles slightly wider than tall to reduce vertical space
          childAspectRatio: 1.3,
          children: courseInfo.length > 9
              ? courseInfo
                  .take(9)
                  .map((course) =>
                      singleCourse(context: context, course: course))
                  .toList()
              : courseInfo
                  .map((course) =>
                      singleCourse(context: context, course: course))
                  .toList(),
        ),
      ],
    );
  }
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
        screen: CourseDetailsPage(course: course),
      );
    },
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            course.creditHours.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.defaultColor,
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            course.courseCode,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.defaultColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

class SelectedCoursesEmptyState extends StatelessWidget {
  const SelectedCoursesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(
          period: AppStrings.semesterCourses,
          hasAction: false,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppMaterial(
            onTap: () {
              Navigation.navigateToScreen(
                  context: context,
                  screen: const CourseEnrollmentPage(isEdit: true));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.grey.withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No courses enrolled',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Complete your course enrollment to see your courses here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
