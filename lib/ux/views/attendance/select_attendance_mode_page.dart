import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/attendance/components/attendance_mode.dart';
import 'package:attendance_app/ux/views/attendance/online_attendance_code_entry_page.dart';
import 'package:attendance_app/ux/views/attendance/scan_page.dart';
import 'package:flutter/material.dart';

class SelectAttendanceModePage extends StatelessWidget {
  const SelectAttendanceModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      hideAppBar: true,
      headerTitle: AppStrings.selectAttendanceType,
      headerSubtitle: AppStrings.areYouAttendingInPersonOrOnline,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AttendanceMode(mode: 'In-person', onTap: () {
                Navigation.navigateToScreen(
                    context: context, screen: const ScanPage());
              }),
            const SizedBox(height: 20),
            AttendanceMode(mode: 'Online', onTap: () {
                Navigation.navigateToScreen(
                    context: context,
                    screen: const OnlineAttendanceCodeEntryPage());
              }),
          ],
        ),
      ),
    );
  }
}
