import 'package:attendance_app/ux/shared/components/page_state_indicator.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
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
  late CourseViewModel courseViewModel;

  @override
  void initState() {
    super.initState();
    courseViewModel = context.read<CourseViewModel>();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final studentId = authViewModel.currentStudent?.idNumber ?? '';

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (widget.course.id != null && studentId.isNotEmpty) {
          context.read<AttendanceViewModel>().loadAttendanceRecords(
                widget.course.id ?? 0,
                studentId,
              );
        }
      },
    );
  }

  String? get courseSchool => courseViewModel.registeredCourses
      .firstWhere((c) => c.courseCode == widget.course.courseCode,
          orElse: () => Course(courseCode: '', courseTitle: ''))
      .school;

  @override
  Widget build(BuildContext context) {
    final semester = widget.course.semester ?? '';

    String? semesterText() {
      switch (semester) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        default:
          return '';
      }
    }

    return AppPageScaffold(
      title: widget.course.courseCode,
      // showInformationBanner: true,
      // informationBannerText: AppStrings.sampleEligibilityText,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AttendanceViewModel>().refresh();
        },
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.course.courseTitle ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: AppColors.defaultColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${widget.course.level ?? ''} level • ${widget.course.semester ?? ''}${semesterText()} • ${widget.course.creditHours ?? ''} credit hours',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      // fontSize: 16,
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
                        Column(
                          children: [
                            Consumer<AttendanceViewModel>(
                                builder: (context, viewModel, _) {
                              return AttendanceSummaryCard(
                                  viewModel:
                                      viewModel); //TODO: check why this shows the data of the last opened course and try to fix it
                            }),
                            Consumer<AttendanceViewModel>(
                              builder: (context, viewModel, _) {
                                if (viewModel.isLoading ||
                                    viewModel.isRefreshing) {
                                  return const PageLoadingIndicator(
                                    useTopPadding: true,
                                  );
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

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      AppStrings.history,
                                      style: TextStyle(
                                        color: AppColors.defaultColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ...viewModel.attendanceRecords
                                        .map((sessionData) =>
                                            SessionHistory(record: sessionData))
                                        .toList(),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
