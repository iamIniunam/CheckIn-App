import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/components/dashboard_metric_grid_view.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/page_state_indicator.dart';
import 'package:attendance_app/ux/shared/components/shimmer_widget.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/shared/components/section_header.dart';
import 'package:attendance_app/ux/views/home/components/single_course_card.dart';
import 'package:attendance_app/ux/views/course/course_enrollment_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SemesterCoursesDashboardMetricView extends StatelessWidget {
  const SemesterCoursesDashboardMetricView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseViewModel>(
      builder: (context, courseViewModel, _) {
        return ValueListenableBuilder(
          valueListenable: courseViewModel.registeredCoursesResult,
          builder: (context, result, _) {
            if (result.state == UIState.loading) {
              return loadingState(context);
            }
            if (result.state == UIState.error) {
              return Column(
                children: [
                  const SectionHeader(
                      period: AppStrings.semesterCourses, hasAction: false),
                  PageErrorIndicator(
                    text: result.message ?? 'Error loading courses',
                    useTopPadding: true,
                  ),
                ],
              );
            }

            final courses = result.data ?? [];

            if (courses.isEmpty) {
              return const EnrolledCoursesEmptyState();
            }
            return Column(
              children: [
                const SectionHeader(
                    period: AppStrings.semesterCourses, hasAction: false),
                DashboardMetricGridView(
                  padding: const EdgeInsets.only(
                      left: 16, top: 10, right: 16, bottom: 16),
                  crossAxisCount: 3,
                  children: courses
                      .map((course) => SingleCourseCard(course: course))
                      .toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget loadingState(BuildContext context) {
    const int crossAxisCount = 3;
    const double outerLeft = 16.0;
    const double outerRight = 16.0;
    const double crossAxisSpacing = 7.0;
    const double estimatedCardHeight = 80.0;

    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth -
        outerLeft -
        outerRight -
        (crossAxisCount - 1) * crossAxisSpacing;
    final cardWidth = availableWidth / crossAxisCount;
    final aspectRatio = cardWidth / estimatedCardHeight;

    final shimmerBoxes = List.generate(9, (index) {
      return ShimmerBox(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        borderRadius: BorderRadius.circular(12),
        aspectRatio: aspectRatio,
      );
    });

    return Column(
      children: [
        const SectionHeader(
            period: AppStrings.semesterCourses, hasAction: false),
        Shimmer(
          child: DashboardMetricGridView(
            padding:
                const EdgeInsets.only(left: 16, top: 10, right: 16, bottom: 0),
            crossAxisCount: crossAxisCount,
            children: shimmerBoxes,
          ),
        ),
      ],
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
                    'Tap here to enroll your courses for this semester.',
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
