import 'package:attendance_app/ux/shared/components/empty_state_widget.dart';
import 'package:attendance_app/ux/shared/components/page_state_indicator.dart';
import 'package:attendance_app/ux/shared/view_models/course_search_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/components/course_search_state_widgets.dart';
import 'package:attendance_app/ux/views/registered_courses_list_view.dart';
import 'package:flutter/material.dart';

class RegisteredCourseListContent extends StatelessWidget {
  const RegisteredCourseListContent({super.key, required this.viewModel});

  final CourseSearchViewModel viewModel;

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
            child: RegisteredCourseListView(
              courses: courses,
              viewModel: viewModel,
            ),
          ),
        ],
      ),
    );
  }
}
