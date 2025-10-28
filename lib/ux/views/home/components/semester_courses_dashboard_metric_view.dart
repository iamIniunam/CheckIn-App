import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/components/dashboard_metric_grid_view.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/page_state_indicator.dart';
import 'package:attendance_app/ux/shared/components/shimmer_widget.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/shared/components/section_header.dart';
import 'package:attendance_app/ux/views/course/full_course_list_page.dart';
import 'package:attendance_app/ux/views/home/components/single_course_card.dart';
import 'package:attendance_app/ux/views/onboarding/course_enrollment_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SemesterCoursesDashboardMetricView extends StatelessWidget {
  const SemesterCoursesDashboardMetricView({super.key});

  static final List<ShimmerBox> shimmerBoxes = List.generate(
    9,
    (index) => ShimmerBox(
      height: 0,
      borderRadius: BorderRadius.circular(12),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseViewModel>(
      builder: (context, courseViewModel, _) {
        if (courseViewModel.isLoadingRegisteredCourses) {
          return Column(
            children: [
              const SectionHeader(
                  period: AppStrings.semesterCourses, hasAction: false),
              Shimmer(
                child: DashboardMetricGridView(
                  padding: const EdgeInsets.only(
                      left: 16, top: 10, right: 16, bottom: 0),
                  crossAxisCount: 3,
                  childAspectRatio: 1.3,
                  children: [...shimmerBoxes],
                ),
              ),
            ],
          );
        }

        if (courseViewModel.hasRegisteredCoursesError) {
          return Column(
            children: [
              const SectionHeader(
                period: AppStrings.semesterCourses,
                hasAction: false,
              ),
              PageErrorIndicator(
                text: courseViewModel.registeredCoursesError ??
                    'Error loading courses',
                useTopPadding: true,
              ),
            ],
          );
        }

        final courseInfo = courseViewModel.registeredCourses;

        if (courseInfo.isEmpty) {
          return const EnrolledCoursesEmptyState();
        }

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
            DashboardMetricGridView(
              padding: const EdgeInsets.only(
                  left: 16, top: 10, right: 16, bottom: 16),
              crossAxisCount: 3,
              // Make tiles slightly wider than tall to reduce vertical space
              childAspectRatio: 1.2,
              children: courseInfo.length > 9
                  ? courseInfo
                      .take(9)
                      .map((course) => SingleCourseCard(course: course))
                      .toList()
                  : courseInfo
                      .map((course) => SingleCourseCard(course: course))
                      .toList(),
            ),
          ],
        );
      },
    );
  }
}

class EnrolledCoursesEmptyState extends StatelessWidget {
  const EnrolledCoursesEmptyState({super.key});

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
            inkwellBorderRadius: BorderRadius.circular(15),
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
