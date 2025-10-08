import 'package:attendance_app/platform/services/selected_courses_service.dart';
import 'package:attendance_app/ux/shared/components/empty_state_widget.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/user_view_model.dart';
import 'package:attendance_app/ux/views/course/components/session_history.dart';
import 'package:attendance_app/ux/views/course/components/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage({super.key, required this.course});

  final Course course;

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  late UserViewModel userViewModel;

  @override
  void initState() {
    super.initState();
    userViewModel = context.read<UserViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.course.id != null && userViewModel.idNumber.isNotEmpty) {
        context.read<AttendanceViewModel>().loadAttendanceRecords(
            widget.course.id ?? 0, userViewModel.idNumber);
      }
    });
  }

  String? get courseStream =>
      SelectedCourseService().getStreamForCourse(widget.course.courseCode);

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      hasRefreshIndicator: true,
      title: AppStrings.courseDetails,
      showInformationBanner: true,
      informationBannerText: AppStrings.sampleEligibilityText,
      body: Column(
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.course.courseCode,
                                style: const TextStyle(
                                    color: AppColors.defaultColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.course.courseTitle ?? '',
                                style: const TextStyle(
                                    color: Colors.grey,
                                    // fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
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
                              courseStream ?? '',
                              style: const TextStyle(
                                color: AppColors.defaultColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Consumer<AttendanceViewModel>(
                        builder: (context, viewModel, _) {
                          if (viewModel.isLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (viewModel.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline,
                                      size: 48, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text(
                                    viewModel.errorMessage ??
                                        'An error occurred',
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (widget.course.id != null) {
                                        viewModel.loadAttendanceRecords(
                                          widget.course.id ?? 0,
                                          'ENG23A00028Y',
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (viewModel.attendanceRecords.isEmpty) {
                            return const EmptyStateWidget(
                                message: 'No attendance records available');
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SummaryCard(viewModel: viewModel),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
