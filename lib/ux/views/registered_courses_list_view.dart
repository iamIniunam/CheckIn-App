import 'package:attendance_app/platform/data_source/api/course/models/course_response.dart';
import 'package:attendance_app/ux/shared/components/dashboard_metric_grid_view.dart';
import 'package:attendance_app/ux/views/course/components/course_enrollment_card.dart';
import 'package:flutter/material.dart';

class RegisteredCourseListView extends StatelessWidget {
  const RegisteredCourseListView({
    super.key,
    required this.courses,
    required this.selectedCourseIds,
    required this.onCourseToggle,
    required this.isCourseSelected,
  });

  final List<Course> courses;
  final Set<int> selectedCourseIds;
  final Function(int) onCourseToggle;
  final bool Function(int) isCourseSelected;

  @override
  Widget build(BuildContext context) {
    return DashboardMetricGridView(
      padding: const EdgeInsets.only(left: 16, top: 12, right: 16),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      physics: const AlwaysScrollableScrollPhysics(),
      children: courses.map((course) {
        final isSelected =
            course.id != null && isCourseSelected(course.id ?? 0);
        return CourseEnrollmentCard(
          semesterCourse: course,
          isSelected: isSelected,
          onTap: () {
            if (course.id != null) {
              onCourseToggle(course.id ?? 0);
            }
          },
        );
      }).toList(),
    );
  }
}
