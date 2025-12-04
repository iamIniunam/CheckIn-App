import 'package:attendance_app/ux/shared/components/empty_state_widget.dart';
import 'package:attendance_app/ux/shared/components/page_state_indicator.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/course/components/course_search_state_widgets.dart';
import 'package:attendance_app/ux/views/registered_courses_list_view.dart';
import 'package:flutter/material.dart';

class RegisteredCourseListContent extends StatelessWidget {
  const RegisteredCourseListContent({
    super.key,
    required this.viewModel,
    required this.selectedCourseIds,
    required this.onCourseToggle,
    required this.isCourseSelected,
  });

  final CourseViewModel viewModel;
  final Set<int> selectedCourseIds;
  final Function(int) onCourseToggle;
  final bool Function(int) isCourseSelected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: viewModel.registeredCoursesResult,
      builder: (context, result, _) {
        if (result.state == UIState.loading) {
          return const Expanded(child: PageLoadingIndicator());
        }

        if (result.state == UIState.error) {
          return Expanded(
            child: PageErrorIndicator(
              text: result.message ?? 'Error loading registered courses',
            ),
          );
        }

        final courses = viewModel.displayedCourses;

        if (courses.isEmpty) {
          final isSearching = viewModel.searchQuery.isNotEmpty;
          return Expanded(
            child: EmptyStateWidget(
              icon:
                  isSearching ? Icons.search_off_rounded : Icons.school_rounded,
              message: isSearching
                  ? 'No courses found'
                  : 'You have no enrolled courses',
            ),
          );
        }

        return Expanded(
          child: Column(
            children: [
              CoursesFoundHeader(courseCount: courses.length),
              Expanded(
                child: RegisteredCourseListView(
                  courses: courses,
                  selectedCourseIds: selectedCourseIds,
                  onCourseToggle: onCourseToggle,
                  isCourseSelected: isCourseSelected,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
