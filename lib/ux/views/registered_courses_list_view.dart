import 'package:attendance_app/ux/shared/components/dashboard_metric_grid_view.dart';
import 'package:attendance_app/ux/shared/view_models/course_search_view_model.dart';
import 'package:attendance_app/ux/views/course/components/course_enrollment_card.dart';
import 'package:flutter/material.dart';

class RegisteredCourseListView extends StatelessWidget {
  const RegisteredCourseListView({
    super.key,
    required this.courses,
    required this.viewModel,
  });

  final List courses;
  final CourseSearchViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DashboardMetricGridView(
      padding: const EdgeInsets.only(left: 16, top: 12, right: 16),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      physics: const AlwaysScrollableScrollPhysics(),
      children: courses.map((course) {
        final selectedCourse = viewModel.getChosenSchoolForCourse(course);
        return CourseEnrollmentCard(
          semesterCourse: course,
          selectedCourse: selectedCourse,
          onTap: (school) {
            viewModel.updateChosenSchool(course, school);
          },
        );
      }).toList(),
    );
  }
}
