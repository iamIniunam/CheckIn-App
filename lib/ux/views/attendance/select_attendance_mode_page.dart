import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/platform/services/local_auth_service.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';
import 'package:attendance_app/ux/views/attendance/components/attendance_mode.dart';
import 'package:attendance_app/ux/views/attendance/components/padded_column.dart';
import 'package:attendance_app/ux/views/attendance/verification_page.dart';
import 'package:flutter/material.dart';

class SelectAttendanceModePage extends StatefulWidget {
  const SelectAttendanceModePage({super.key});

  @override
  State<SelectAttendanceModePage> createState() =>
      _SelectAttendanceModePageState();
}

class _SelectAttendanceModePageState extends State<SelectAttendanceModePage> {
  bool _isAuthenticating = false;

  Future<void> authenticateAndNavigate(
      BuildContext context, AttendanceType type) async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    AppDialogs.showLoadingDialog(context, loadingText: 'Authenticating...');

    try {
      final authService = AppDI.getIt<LocalAuthService>();
      final success = await authService.authenticate();

      Navigation.navigatorKey.currentState?.pop();

      if (!mounted) return;

      if (success) {
        Navigation.navigateToScreen(
          context: context,
          screen: VerificationPage(attendanceType: type),
        );
      } else {
        AppDialogs.showErrorDialog(
          context: context,
          message: 'Authentication failed. Please try again.',
        );
      }
    } catch (e) {
      Navigation.navigatorKey.currentState?.pop();

      if (!mounted) return;

      AppDialogs.showErrorDialog(
        context: context,
        message: 'Authentication error. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PaddedColumn(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AttendanceMode(
          mode: 'In-person',
          onTap: _isAuthenticating
              ? null
              : () {
                  authenticateAndNavigate(
                    context,
                    AttendanceType.inPerson,
                  );
                },
        ),
        const SizedBox(height: 20),
        AttendanceMode(
          mode: 'Online',
          onTap: _isAuthenticating
              ? null
              : () {
                  authenticateAndNavigate(
                    context,
                    AttendanceType.online,
                  );
                },
        ),
      ],
    );
  }
}
