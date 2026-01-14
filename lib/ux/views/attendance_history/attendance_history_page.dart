import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/attendance/models/attedance_response.dart';
import 'package:attendance_app/platform/data_source/api/attendance/models/attendance_request.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/shared/components/empty_state_widget.dart';
import 'package:attendance_app/ux/shared/components/page_state_indicator.dart';
import 'package:attendance_app/ux/shared/components/small_circular_progress_indicator.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/views/course/components/attendance_history_card.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  final AuthViewModel _authViewModel = AppDI.getIt<AuthViewModel>();
  final AttendanceViewModel _attendanceViewModel =
      AppDI.getIt<AttendanceViewModel>();

  bool _isLoadingPage = false;

  @override
  void initState() {
    super.initState();
    _attendanceViewModel.attendanceHistoryPagingController
        .removePageRequestListener(_onPageRequest);
    _attendanceViewModel.attendanceHistoryPagingController
        .addPageRequestListener(_onPageRequest);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attendanceViewModel.currentPageForAttendanceHistory = 1;
      _attendanceViewModel.attendanceHistoryPagingController.refresh();
    });
  }

  void _onPageRequest(int pageKey) {
    if (_isLoadingPage) return;
    _isLoadingPage = true;

    _attendanceViewModel.currentPageForAttendanceHistory = pageKey;
    loadNextPage().then((_) {
      _isLoadingPage = false;
    }).catchError((error) {
      _isLoadingPage = false;
    });
  }

  Future<void> refresh() async {
    _attendanceViewModel.currentPageForAttendanceHistory = 1;
    final studentId = _authViewModel.appUser?.studentProfile?.idNumber;
    var response = await _attendanceViewModel.getPaginatedAttendanceHistory(
      getAttendanceHistoryRequest: GetAttendanceHistoryRequest(
        studentId: studentId ?? '',
        pageIndex: _attendanceViewModel.currentPageForAttendanceHistory,
        pageSize: AppConstants.defaultPageSize,
      ),
    );
    if (response.status == ApiResponseStatus.Success) {
      _attendanceViewModel.attendanceHistoryPagingController.itemList?.clear();
      _attendanceViewModel.attendanceHistoryPagingController.itemList = [];
      _attendanceViewModel.attendanceHistoryPagingController.appendPage(
          response.response?.data ?? [],
          _attendanceViewModel.currentPageForAttendanceHistory + 1);
    }
  }

  Future<void> loadNextPage() async {
    final studentId = _authViewModel.appUser?.studentProfile?.idNumber;
    var response = await _attendanceViewModel.getPaginatedAttendanceHistory(
      getAttendanceHistoryRequest: GetAttendanceHistoryRequest(
        studentId: studentId ?? '',
        pageIndex: _attendanceViewModel.currentPageForAttendanceHistory,
        pageSize: AppConstants.defaultPageSize,
      ),
    );
    // if (response.status == ApiResponseStatus.Success) {
    //   if (response.response?.data?.isNotEmpty == true) {
    //     try {
    //       if (_attendanceViewModel.currentPageForAttendanceHistory == 1) {
    //         _attendanceViewModel.attendanceHistoryPagingController.itemList
    //             ?.clear();
    //         _attendanceViewModel.attendanceHistoryPagingController.itemList =
    //             [];
    //       }
    //       _attendanceViewModel.attendanceHistoryPagingController.appendPage(
    //           response.response?.data ?? [],
    //           _attendanceViewModel.currentPageForAttendanceHistory + 1);
    //     } catch (e) {
    //       if (kDebugMode) {
    //         print(e);
    //       }
    //     }
    //   } else {
    //     _attendanceViewModel.attendanceHistoryPagingController
    //         .appendLastPage([]);
    //   }

    //   if (response.response?.isLastPage() == true) {
    //     _attendanceViewModel.attendanceHistoryPagingController
    //         .appendLastPage([]);
    //   } else {
    //     _attendanceViewModel.attendanceHistoryPagingController.error =
    //         response.response?.message ?? AppStrings.somethingWentWrong;
    //   }
    // }

    if (response.status == ApiResponseStatus.Success) {
      final data = response.response?.data ?? [];
      final isLastPage = response.response?.isLastPage() ?? true;

      if (isLastPage) {
        _attendanceViewModel.attendanceHistoryPagingController
            .appendLastPage(data);
      } else {
        _attendanceViewModel.attendanceHistoryPagingController.appendPage(
          data,
          _attendanceViewModel.currentPageForAttendanceHistory + 1,
        );
      }
    } else {
      _attendanceViewModel.attendanceHistoryPagingController.error =
          response.response?.message ?? AppStrings.somethingWentWrong;
    }
  }

  @override
  void dispose() {
    _attendanceViewModel.attendanceHistoryPagingController
        .removePageRequestListener(_onPageRequest);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              // await refresh();
              _attendanceViewModel.currentPageForAttendanceHistory = 1;
              _attendanceViewModel.attendanceHistoryPagingController.refresh();
            },
            child: PagedListView<int, AttendanceHistory>(
              pagingController:
                  _attendanceViewModel.attendanceHistoryPagingController,
              padding: const EdgeInsets.symmetric(vertical: 14),
              builderDelegate: PagedChildBuilderDelegate<AttendanceHistory>(
                itemBuilder: (context, item, index) =>
                    AttendanceHistoryCard(history: item),
                firstPageProgressIndicatorBuilder: (context) {
                  return const PageLoadingIndicator();
                },
                newPageProgressIndicatorBuilder: (context) {
                  return const Center(child: SmallCircularProgressIndicator());
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
                    message: 'No attendance history found',
                  );
                },
                noMoreItemsIndicatorBuilder: (context) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
