import 'package:attendance_app/platform/data_source/api/course/models/course_response.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/attendance_history/components/period.dart';
import 'package:attendance_app/ux/views/course/components/course_card.dart';
import 'package:flutter/material.dart';

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  final List<String> periods = [
    AppStrings.today,
    AppStrings.yesterday,
    AppStrings.pastWeek,
  ];

  final List<List<Course>> courseHistory = [
    [
      Course(
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        status: AppStrings.present,
        showStatus: true,
      ),
      Course(
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        status: AppStrings.present,
        showStatus: true,
      ),
      Course(
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        status: AppStrings.absent,
        showStatus: true,
      ),
    ],
    [
      Course(
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        status: AppStrings.absent,
        showStatus: true,
      ),
      Course(
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        status: AppStrings.absent,
        showStatus: true,
      ),
      Course(
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        status: AppStrings.present,
        showStatus: true,
      ),
    ],
    [
      Course(
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        status: AppStrings.absent,
        showStatus: true,
      ),
      Course(
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        status: AppStrings.absent,
        showStatus: true,
      ),
      Course(
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        status: AppStrings.present,
        showStatus: true,
      ),
      Course(
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        status: AppStrings.absent,
        showStatus: true,
      ),
    ]
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: periods.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Period(period: periods[index]),
            ...courseHistory[index]
                .map((course) => CourseCard(course: course))
                .toList(),
          ],
        );
      },
    );
  }
}
