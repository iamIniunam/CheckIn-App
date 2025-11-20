import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/platform/services/local_auth_service.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/attendance/components/attendance_mode.dart';
import 'package:attendance_app/ux/views/attendance/verification_page.dart';
import 'package:flutter/material.dart';

class SelectAttendanceModePage extends StatelessWidget {
  const SelectAttendanceModePage({super.key});

  Future<void> authenticateAndNavigate(
      BuildContext context, AttendanceType type) async {
    final LocalAuthService authService = AppDI.getIt<LocalAuthService>();

    final success = await authService.authenticate();
    if (!success) return;

    if (!context.mounted) return;
    Navigation.navigateToScreen(
      context: context,
      screen: VerificationPage(attendanceType: type),
    );
  }

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
            AttendanceMode(
                mode: 'In-person',
                onTap: () {
                  authenticateAndNavigate(context, AttendanceType.inPerson);
                }),
            const SizedBox(height: 20),
            AttendanceMode(
              mode: 'Online',
              onTap: () {
                authenticateAndNavigate(context, AttendanceType.online);
              },
            ),
          ],
        ),
      ),
    );
  }
}
