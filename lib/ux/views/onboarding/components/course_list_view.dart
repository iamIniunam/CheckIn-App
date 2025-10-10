import 'package:attendance_app/ux/shared/view_models/course_search_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/components/course_enrollment_card.dart';
import 'package:flutter/material.dart';

class CourseListView extends StatelessWidget {
  const CourseListView({
    super.key,
    required this.courses,
    required this.viewModel,
  });

  final List courses;
  final CourseSearchViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final selectedSchool = viewModel.getChosenSchoolForCourse(course);

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CourseEnrollmentCard(
            semesterCourse: course,
            selectedSchool: selectedSchool,
            onTapSchool: (school) {
              viewModel.updateChosenSchool(course, school);
            },
          ),
        );
      },
    );
  }
}
