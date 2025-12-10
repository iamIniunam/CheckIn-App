import 'package:attendance_app/platform/data_source/api/course/models/course_response.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/shared/components/page_state_indicator.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/course/components/session_history.dart';
import 'package:attendance_app/ux/views/course/components/attendance_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage({super.key, required this.course});

  final Course course;

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  final AuthViewModel _authViewModel = AppDI.getIt<AuthViewModel>();
  final AttendanceViewModel _attendanceViewModel =
      AppDI.getIt<AttendanceViewModel>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentId = _authViewModel.appUser?.studentProfile?.idNumber ?? '';

      if (studentId.isNotEmpty && widget.course.id != null) {
        _attendanceViewModel.fetchCourseAttendanceRecords(
          widget.course.id ?? 0,
          studentId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CourseDetailsBody(course: widget.course);
  }
}

class CourseDetailsBody extends StatelessWidget {
  const CourseDetailsBody({super.key, required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    final courseViewModel = context.read<CourseViewModel>();
    final attendanceViewModel = context.read<AttendanceViewModel>();
    final semester = course.semester;

    String? semesterSuffix() {
      switch (semester) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        default:
          return '';
      }
    }

    final courseSchool = courseViewModel.registeredCourses
        .firstWhere(
          (c) => c.courseCode == course.courseCode,
          orElse: () => Course(courseCode: '', courseTitle: ''),
        )
        .school;

    return AppPage(
      title: course.courseCode,
      hasBottomPadding: false,
      body: ValueListenableBuilder(
        valueListenable: attendanceViewModel.courseAttendanceResult,
        builder: (context, result, _) {
          final records =
              attendanceViewModel.getCourseAttendanceRecords(course.id ?? 0);

          if (course.id == null) {
            return const PageErrorIndicator(
              text: 'Invalid course ID',
              useTopPadding: true,
            );
          }

          return RefreshIndicator(
            displacement: 20,
            onRefresh: () async {
              await attendanceViewModel.refreshCourseAttendance();
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.courseTitle ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.defaultColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${course.level ?? ''} level • ${course.semester}${semesterSuffix()} • ${course.creditHours ?? ''} credit hours',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryTeal.withOpacity(0.7),
                          ),
                        ),
                        child: Text(
                          courseSchool ?? '',
                          style: const TextStyle(
                            color: AppColors.defaultColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AttendanceSummaryCard(
                    courseId: course.id ?? 0, viewModel: attendanceViewModel),
                const SizedBox(height: 12),
                if (result.isLoading)
                  const PageLoadingIndicator(useTopPadding: true)
                else if (result.isError)
                  PageErrorIndicator(
                    text: result.message ?? 'Error loading attendance records',
                    useTopPadding: true,
                  )
                else if (records.isEmpty)
                  const PageErrorIndicator(
                    text: 'No attendance records found',
                    useTopPadding: true,
                  )
                else ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            AppStrings.history,
                            style: TextStyle(
                              color: AppColors.defaultColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              ...records.reversed
                                  .toList()
                                  .map((record) =>
                                      SessionHistory(record: record))
                                  .toList(),
                              const SizedBox(height: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
