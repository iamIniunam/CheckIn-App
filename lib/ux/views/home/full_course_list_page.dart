import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:flutter/material.dart';

class FullCourseListPage extends StatefulWidget {
  final List<Course> courses;

  const FullCourseListPage({super.key, required this.courses});

  @override
  State<FullCourseListPage> createState() => _FullCourseListPageState();
}

class _FullCourseListPageState extends State<FullCourseListPage> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      hideAppBar: false,
      title: AppStrings.allCourses,
      body: ListView.builder(
        itemCount: widget.courses.length,
        itemBuilder: (context, index) {
          final course = widget.courses[index];
          final isExpanded = expandedIndex == index;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  course.courseCode,
                  style: const TextStyle(
                    color: AppColors.defaultColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.defaultColor),
                onTap: () {
                  setState(() {
                    expandedIndex = isExpanded ? null : index;
                  });
                },
              ),
              if (isExpanded)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      courseDetails(detail: course.courseTitle ?? ''),
                      courseDetails(
                          detail: '${course.creditHours} Credit Hour(s)'),
                      courseDetails(detail: course.lecturer ?? 'TBD'),
                    ],
                  ),
                ),
              const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }

  Widget courseDetails({required String detail}) {
    return Text(
      detail,
      style: const TextStyle(
          color: AppColors.defaultColor,
          fontSize: 14,
          fontWeight: FontWeight.w500),
    );
  }
}
