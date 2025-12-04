import 'package:attendance_app/platform/data_source/api/attendance/models/attedance_response.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/components/empty_state_widget.dart';
import 'package:attendance_app/ux/shared/components/page_state_indicator.dart';
import 'package:attendance_app/ux/shared/components/small_circular_progress_indicator.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/views/attendance_history/components/period.dart';
import 'package:attendance_app/ux/views/course/components/attendance_history_card.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  final AuthViewModel _authViewModel = AppDI.getIt<AuthViewModel>();
  late final AttendanceViewModel attendanceViewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    attendanceViewModel = context.read<AttendanceViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializePagination();
    });
  }

  void initializePagination() {
    final studentId = _authViewModel.appUser?.studentProfile?.idNumber;
    if (studentId != null) {
      attendanceViewModel.initializeAttendanceHistoryPagination(studentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // DEBUG: Show pagination status
        // if (true) buildDebugInfo(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              attendanceViewModel.refreshAttendanceHistory();
              return Future.value();
            },
            child: PagedListView<int, AttendanceHistory>(
              pagingController:
                  attendanceViewModel.attendanceHistoryPagingController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              builderDelegate: PagedChildBuilderDelegate<AttendanceHistory>(
                itemBuilder: (context, item, index) {
                  final allItems = attendanceViewModel
                          .attendanceHistoryPagingController.itemList ??
                      [];
                  final groupedRecords =
                      attendanceViewModel.groupHistoryByDate(allItems);

                  String? itemPeriod;
                  for (final entry in groupedRecords.entries) {
                    if (entry.value.contains(item)) {
                      itemPeriod = entry.key;
                      break;
                    }
                  }

                  if (itemPeriod == null) {
                    return AttendanceHistoryCard(history: item);
                  }

                  final periodItems = groupedRecords[itemPeriod] ?? [];
                  final isFirstInPeriod = periodItems.first == item;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFirstInPeriod) Period(period: itemPeriod),
                      AttendanceHistoryCard(history: item),
                      // DEBUG: Show item index
                      // if (true)
                      //   Padding(
                      //     padding: const EdgeInsets.symmetric(horizontal: 16),
                      //     child: Text(
                      //       'Item #${index + 1}',
                      //       style: TextStyle(
                      //         fontSize: 10,
                      //         color: Colors.grey[400],
                      //       ),
                      //     ),
                      //   ),
                    ],
                  );
                },
                firstPageErrorIndicatorBuilder: (context) => PageErrorIndicator(
                  text: attendanceViewModel
                          .attendanceHistoryPagingController.error
                          ?.toString() ??
                      'Error loading attendance history',
                ),
                newPageErrorIndicatorBuilder: (context) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      PageErrorIndicator(
                        text: attendanceViewModel
                                .attendanceHistoryPagingController.error
                                ?.toString() ??
                            'Error loading more items',
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 100),
                        child: PrimaryButton(
                          onTap: () {
                            attendanceViewModel
                                .attendanceHistoryPagingController
                                .retryLastFailedRequest();
                          },
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  ),
                ),
                firstPageProgressIndicatorBuilder: (context) =>
                    const PageLoadingIndicator(),
                newPageProgressIndicatorBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SmallCircularProgressIndicator(),
                ),
                noItemsFoundIndicatorBuilder: (context) =>
                    const EmptyStateWidget(
                  icon: Icons.calendar_today_rounded,
                  message: 'No attendance history found',
                ),
                noMoreItemsIndicatorBuilder: (context) =>
                    const SizedBox(height: 16),
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: Column(
                //     children: [
                //       const Divider(),
                //       Text(
                //         'End of list',
                //         style: TextStyle(
                //           color: Colors.grey[600],
                //           fontSize: 12,
                //         ),
                //       ),
                //       const SizedBox(height: 16),
                //     ],
                //   ),
                // ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDebugInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.yellow[100],
      child: ListenableBuilder(
        listenable: attendanceViewModel.attendanceHistoryPagingController,
        builder: (context, _) {
          final controller =
              attendanceViewModel.attendanceHistoryPagingController;
          final itemCount = controller.itemList?.length ?? 0;
          final nextPageKey = controller.nextPageKey;
          final hasError = controller.error != null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔍 PAGINATION DEBUG INFO',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text('Items loaded: $itemCount',
                  style: const TextStyle(fontSize: 10)),
              Text('Next page key: ${nextPageKey ?? "null (last page)"}',
                  style: const TextStyle(fontSize: 10)),
              Text('Has error: $hasError',
                  style: const TextStyle(fontSize: 10)),
              if (hasError)
                Text('Error: ${controller.error}',
                    style: const TextStyle(fontSize: 10, color: Colors.red)),
            ],
          );
        },
      ),
    );
  }
}
