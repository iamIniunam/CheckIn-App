import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/attendance/models/attedance_response.dart';
import 'package:attendance_app/platform/data_source/api/attendance/models/attendance_request.dart';
import 'package:attendance_app/platform/data_source/api/course/models/course_response.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/shared/components/empty_state_widget.dart';
import 'package:attendance_app/ux/shared/components/page_state_indicator.dart';
import 'package:attendance_app/ux/shared/components/small_circular_progress_indicator.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/course/components/session_history.dart';
import 'package:attendance_app/ux/views/course/components/attendance_summary_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
  final CourseViewModel _courseViewModel = AppDI.getIt<CourseViewModel>();

  @override
  void initState() {
    super.initState();
    _attendanceViewModel.resetAttendanceSummary();
    _attendanceViewModel.resetCourseAttendancePaging();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAttendanceSummary();
    });

    _attendanceViewModel.courseAttendancePagingController
        .addPageRequestListener((pageKey) {
      _attendanceViewModel.currentPageForCourseAttendance = pageKey;
      loadNextPage();
    });
  }

  void loadAttendanceSummary() {
    final studentId = _authViewModel.appUser?.studentProfile?.idNumber;
    if (studentId != null && widget.course.id != null) {
      _attendanceViewModel.getAttendanceSummary(
        courseId: widget.course.id ?? 0,
        studentId: studentId,
      );
    }
  }

  Future<void> refresh() async {
    _attendanceViewModel.currentPageForCourseAttendance = 1;
    var response =
        await _attendanceViewModel.getPaginatedCourseAttendanceRecords(
            getCourseAttendanceRequest: getCourseAttendanceRequest());
    if (response.status == ApiResponseStatus.Success) {
      _attendanceViewModel.courseAttendancePagingController.itemList?.clear();
      _attendanceViewModel.courseAttendancePagingController.itemList = [];
      _attendanceViewModel.courseAttendancePagingController.appendPage(
          response.response?.data ?? [],
          _attendanceViewModel.currentPageForCourseAttendance + 1);
    }
  }

  Future<void> loadNextPage() async {
    var response =
        await _attendanceViewModel.getPaginatedCourseAttendanceRecords(
            getCourseAttendanceRequest: getCourseAttendanceRequest());
    if (response.status == ApiResponseStatus.Success) {
      if (response.response?.data?.isNotEmpty == true) {
        try {
          if (_attendanceViewModel.currentPageForCourseAttendance == 1) {
            _attendanceViewModel.courseAttendancePagingController.itemList
                ?.clear();
            _attendanceViewModel.courseAttendancePagingController.itemList = [];
          }
          _attendanceViewModel.courseAttendancePagingController.appendPage(
              response.response?.data ?? [],
              _attendanceViewModel.currentPageForCourseAttendance + 1);
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      } else {
        _attendanceViewModel.courseAttendancePagingController
            .appendLastPage([]);
      }

      if (response.response?.isLastPage() == true) {
        _attendanceViewModel.courseAttendancePagingController
            .appendLastPage([]);
      } else {
        _attendanceViewModel.courseAttendancePagingController.error =
            response.response?.message ?? AppStrings.somethingWentWrong;
      }
    }
  }

  GetCourseAttendanceRequest getCourseAttendanceRequest() {
    final studentId = _authViewModel.appUser?.studentProfile?.idNumber ?? '';

    return GetCourseAttendanceRequest(
      courseId: widget.course.id ?? 0,
      studentId: studentId,
      pageIndex: _attendanceViewModel.currentPageForCourseAttendance,
      pageSize: AppConstants.defaultPageSize,
    );
  }

  @override
  void dispose() {
    _attendanceViewModel.courseAttendancePagingController
        .removePageRequestListener((_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semester = widget.course.semester;
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

    final courseSchool = _courseViewModel.registeredCourses
        .firstWhere(
          (c) => c.courseCode == widget.course.courseCode,
          orElse: () => Course(courseCode: '', courseTitle: ''),
        )
        .school;

    return AppPage(
      title: widget.course.courseCode,
      hasBottomPadding: false,
      body: RefreshIndicator(
        displacement: 20,
        onRefresh: () async {
          loadAttendanceSummary();
          await refresh();
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
                          widget.course.courseTitle ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.defaultColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.course.level ?? ''} level • ${widget.course.semester}${semesterSuffix()} • ${widget.course.creditHours ?? ''} credit hours',
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
            AttendanceSummaryCard(
              courseId: widget.course.id ?? 0,
              viewModel: _attendanceViewModel,
            ),
            const SizedBox(height: 12),
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
                    child: PagedListView<int, CourseAttendanceRecord>(
                      pagingController:
                          _attendanceViewModel.courseAttendancePagingController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      builderDelegate:
                          PagedChildBuilderDelegate<CourseAttendanceRecord>(
                        itemBuilder: (context, item, index) =>
                            SessionHistory(record: item),
                        firstPageProgressIndicatorBuilder: (context) {
                          return const PageLoadingIndicator(
                              useTopPadding: true);
                        },
                        newPageProgressIndicatorBuilder: (context) {
                          return const Center(
                              child: SmallCircularProgressIndicator());
                        },
                        firstPageErrorIndicatorBuilder: (context) {
                          return const PageErrorIndicator();
                        },
                        newPageErrorIndicatorBuilder: (context) {
                          return const PageErrorIndicator();
                        },
                        noItemsFoundIndicatorBuilder: (context) {
                          return const EmptyStateWidget(
                            icon: Icons.calendar_today_rounded,
                            message:
                                'No attendance history found for this course',
                          );
                        },
                        noMoreItemsIndicatorBuilder: (context) {
                          return const SizedBox.shrink();
                        },
                      ),
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
