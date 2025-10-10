import 'package:attendance_app/ux/shared/components/empty_state_widget.dart';
import 'package:attendance_app/ux/shared/components/page_state_indicator.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/course_search_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/components/course_list_view.dart';
import 'package:attendance_app/ux/views/onboarding/components/course_search_bottom_widgets.dart';
import 'package:flutter/material.dart';

class CourseListContent extends StatelessWidget {
  const CourseListContent({
    super.key,
    required this.viewModel,
    required this.onConfirmPressed,
  });

  final CourseSearchViewModel viewModel;
  final VoidCallback onConfirmPressed;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoadingCourses) {
      return const Expanded(child: PageLoadingIndicator());
    }

    if (viewModel.hasLoadError) {
      return Expanded(
        child: PageErrorIndicator(
          text: viewModel.loadError ?? 'Error loading courses',
        ),
      );
    }

    final courses = viewModel.displayedCourses;

    if (courses.isEmpty) {
      return Expanded(
        child: EmptyStateWidget(
          icon: viewModel.isSearching
              ? Icons.search_off_rounded
              : Icons.school_rounded,
          message: viewModel.isSearching
              ? 'No courses found'
              : 'No courses available for \nlevel ${viewModel.selectedLevel}, semester ${viewModel.selectedSemester}',
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          if (viewModel.isSearching || viewModel.hasActiveFilter)
            CoursesFoundHeader(courseCount: courses.length),
          Expanded(
            child: CourseListView(
              courses: courses,
              viewModel: viewModel,
            ),
          ),
          ConfirmationSection(
            totalCreditHours: viewModel.totalCreditHours,
            onConfirmPressed: onConfirmPressed,
          ),
        ],
      ),
    );
  }
}

class CoursesFoundHeader extends StatelessWidget {
  const CoursesFoundHeader({super.key, required this.courseCount});

  final int courseCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
      child: Row(
        children: [
          Text(
            '$courseCount course${courseCount == 1 ? '' : 's'} found',
            style: const TextStyle(
              color: AppColors.defaultColor,
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
