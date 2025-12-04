import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/shared/components/empty_state_widget.dart';
import 'package:attendance_app/ux/shared/components/page_state_indicator.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/views/attendance_history/components/period.dart';
import 'package:attendance_app/ux/views/course/components/attendance_history_card.dart';
import 'package:flutter/material.dart';
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
      loadAttendanceHistory();
    });
  }

  Future<void> loadAttendanceHistory() async {
    final studentId = _authViewModel.appUser?.studentProfile?.idNumber;
    if (studentId != null) {
      await attendanceViewModel.loadAttendanceHistory(studentId);
    }
  }

  Future<void> refreshAttendanceHistory() async {
    final studentId = _authViewModel.appUser?.studentProfile?.idNumber;
    if (studentId != null) {
      Future.microtask(
          () => attendanceViewModel.reloadAttendanceHistory(studentId));
      Future.value();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshAttendanceHistory,
      child: ValueListenableBuilder(
        valueListenable: attendanceViewModel.attendanceHistoryResult,
        builder: (context, result, _) {
          if (result.state == UIState.loading) {
            return const PageLoadingIndicator();
          }

          if (result.state == UIState.error) {
            return PageErrorIndicator(
              text: result.message ?? 'Error loading attendance history',
            );
          }

          final groupedRecords = attendanceViewModel.groupedByDate;

          if (groupedRecords.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.calendar_today_rounded,
              message: 'No attendance history found',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: groupedRecords.keys.length,
            itemBuilder: (context, index) {
              final period = groupedRecords.keys.elementAt(index);
              final records = groupedRecords[period] ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Period(period: period),
                  ...records
                      .map(
                        (record) => AttendanceHistoryCard(history: record),
                      )
                      .toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
