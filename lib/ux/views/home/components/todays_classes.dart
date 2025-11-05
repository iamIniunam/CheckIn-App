import 'package:attendance_app/platform/data_source/api/course/models/course_response.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/course/components/course_card.dart';
import 'package:attendance_app/ux/shared/components/section_header.dart';
import 'package:flutter/material.dart';

class TodaysClasses extends StatelessWidget {
  TodaysClasses({super.key});

  final List<Course> courses = [
    Course(
        courseCode: 'CS101', courseTitle: 'Introduction to Computer Science'),
    Course(courseCode: 'MATH201', courseTitle: 'Engineering Mathematics 1'),
    Course(courseCode: 'ENG233', courseTitle: 'Engineering Ethics'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(period: AppStrings.todaysClasses, hasAction: false,),
        ...courses
            .map(
              (todaysCourses) => CourseCard(course: todaysCourses),
            )
            .toList(),
      ],
    );
  }
}
