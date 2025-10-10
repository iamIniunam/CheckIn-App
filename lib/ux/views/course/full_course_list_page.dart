import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/course/components/full_course_list_course_detail.dart';
import 'package:flutter/material.dart';

class FullCourseListPage extends StatefulWidget {
  final List<Course> courses;
  final Map<String, String>? courseSchools;

  const FullCourseListPage(
      {super.key, required this.courses, this.courseSchools});

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
      body: widget.courses.isEmpty
          ? const FullCourseListEmptyState()
          : ListView.builder(
              itemCount: widget.courses.length,
              itemBuilder: (context, index) {
                final course = widget.courses[index];
                // final school = widget.courseSchools?[course.courseCode];
                final isExpanded = expandedIndex == index;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      visualDensity: VisualDensity.compact,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.courseCode,
                              style: const TextStyle(
                                color: AppColors.defaultColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (course.school != null) ...[
                            //TODO: check this
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTeal.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryTeal.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                course.school ?? '',
                                style: const TextStyle(
                                  color: AppColors.defaultColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                      trailing: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.defaultColor,
                      ),
                      onTap: () {
                        setState(() {
                          expandedIndex = isExpanded ? null : index;
                        });
                      },
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FullCourseListCourseDetail(
                              detail: course.courseTitle ?? '',
                            ),
                            FullCourseListCourseDetail(
                              detail: '${course.creditHours} Credit Hour(s)',
                            ),
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
}

class FullCourseListEmptyState extends StatelessWidget {
  const FullCourseListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: AppColors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No courses selected',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Complete your course selection first',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
