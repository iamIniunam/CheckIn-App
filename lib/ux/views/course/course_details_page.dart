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

class CourseDetailsPage extends StatelessWidget {
  const CourseDetailsPage({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final authViewModel = AppDI.getIt<AuthViewModel>();
    final studentId = authViewModel.appUser?.studentProfile?.idNumber ?? '';

    return ChangeNotifierProvider(
      create: (_) =>
          AttendanceViewModel()..loadAttendanceRecords(course.id!, studentId),
      child: _CourseDetailsBody(course: course),
    );
  }
}

class _CourseDetailsBody extends StatelessWidget {
  const _CourseDetailsBody({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    final courseViewModel = context.read<CourseViewModel>();
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

    return AppPageScaffold(
      title: course.courseCode,
      body: RefreshIndicator(
        displacement: 20,
        onRefresh: () async {
          Future.microtask(() => context.read<AttendanceViewModel>().refresh());
          return Future.value();
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            Consumer<AttendanceViewModel>(
              builder: (context, viewModel, _) {
                return AttendanceSummaryCard(viewModel: viewModel);
              },
            ),
            const SizedBox(height: 12),
            Consumer<AttendanceViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading || viewModel.isRefreshing) {
                  return const PageLoadingIndicator(useTopPadding: true);
                }

                if (viewModel.hasError) {
                  return PageErrorIndicator(
                    text: viewModel.errorMessage ??
                        'Error loading attendance records',
                    useTopPadding: true,
                  );
                }

                if (viewModel.attendanceRecords.isEmpty) {
                  return const PageErrorIndicator(
                    text: 'No attendance records found',
                    useTopPadding: true,
                  );
                }

                return Expanded(
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
                            ...viewModel.attendanceRecords
                                .map((record) => SessionHistory(record: record))
                                .toList(),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
