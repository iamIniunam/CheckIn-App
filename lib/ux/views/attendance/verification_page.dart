import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_verification_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/views/attendance/alert_dialogs/cancel_dialog.dart';
import 'package:attendance_app/ux/views/attendance/components/attendance_type_indicator.dart';
import 'package:attendance_app/ux/views/attendance/components/face_verification_buttons.dart';
import 'package:attendance_app/ux/views/attendance/components/step_content.dart';
import 'package:attendance_app/ux/views/attendance/components/step_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage(
      {super.key, this.onExit, required this.attendanceType});

  final void Function()? onExit;
  final AttendanceType attendanceType;

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  late AttendanceVerificationViewModel viewModel;

  @override
  void initState() {
    super.initState();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    viewModel = AttendanceVerificationViewModel(authViewModel: authViewModel);
    viewModel.setAttendanceType(widget.attendanceType);
  }

  Future<void> handleCompletion() async {
    Navigation.navigateToScreen(
        context: context, screen: const NavigationHostPage());
  }

  Future<void> handleOutOfRange(
      LocationVerificationStatus locationStatus) async {
    if (locationStatus == LocationVerificationStatus.outOfRange) {
      Navigation.navigateToScreen(
          context: context, screen: const NavigationHostPage());
    }
  }

  void handleExit() {
    AttendanceCancelDialog.show(context: context);
  }

  bool shouldShowStepIndicator() {
    final type =
        viewModel.verificationState.attendanceType ?? widget.attendanceType;
    return type == AttendanceType.inPerson || type == AttendanceType.online;
  }

  bool isAttendanceMode() {
    final type =
        viewModel.verificationState.attendanceType ?? widget.attendanceType;
    return type == AttendanceType.inPerson || type == AttendanceType.online;
  }

  Future<void> handleOnlineCodeSubmission() async {
    final entered = viewModel.enteredOnlineCode;
    if (entered == null || entered.trim().isEmpty) {
      AppDialogs.showErrorDialog(
          context: context, message: 'Please enter the attendance code');
      return;
    }

    if (entered.length < 6) {
      AppDialogs.showErrorDialog(
          context: context,
          message: 'The attendance code must be 6 characters long.');
      return;
    }

    final success = await viewModel.submitAttendance();

    if (!mounted) return;

    if (success) {
      viewModel.moveToNextStep();

      viewModel.updateState(viewModel.verificationState
          .copyWith(isLoading: true, clearError: true));

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      viewModel.updateState(viewModel.verificationState
          .copyWith(isLoading: false, clearError: true));
      viewModel.moveToNextStep();
    } else {
      final message = viewModel.verificationState.errorMessage ??
          'Unable to submit attendance. Please check your code and try again.';
      AppDialogs.showErrorDialog(
        context: context,
        message: message,
        action: () {
          if (message.contains(
              'You are not registered for the course linked to this attendance code.')) {
            Navigation.navigateToHomePage(context: context);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: PopScope(
        canPop: false,
        onPopInvoked: (_) => handleExit(),
        child: AppPage(
          hideAppBar: true,
          body: Consumer<AttendanceVerificationViewModel>(
            builder: (context, verificationViewModel, _) {
              final locationStatus = verificationViewModel.locationStatus;
              final verificationStep =
                  verificationViewModel.verificationState.currentStep;

              return Stack(
                children: [
                  // Main content
                  StepContent(viewModel: verificationViewModel),

                  // Step indicator for attendance mode
                  if (shouldShowStepIndicator())
                    StepIndicatorWidget(viewModel: verificationViewModel),

                  // Attendance type indicator - driven by view model's state
                  if (isAttendanceMode() &&
                      verificationViewModel.verificationState.attendanceType !=
                          null)
                    AttendanceTypeIndicator(
                      attendanceType: verificationViewModel
                              .verificationState.attendanceType ??
                          widget.attendanceType,
                    ),

                  // Exit button: prefer VM attendanceType, fallback to widget
                  ExitButton(
                    attendanceType: verificationViewModel
                            .verificationState.attendanceType ??
                        widget.attendanceType,
                    viewModel: verificationViewModel,
                    onExit: widget.onExit ?? handleExit,
                  ),

                  // Verification button
                  VerificationButton(
                    viewModel: verificationViewModel,
                    onVerify: getOnVerify(
                      locationStatus ??
                          LocationVerificationStatus.successInRange,
                      verificationStep,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  VoidCallback getOnVerify(LocationVerificationStatus locationStatus,
      VerificationStep verificationStep) {
    if (locationStatus == LocationVerificationStatus.outOfRange) {
      return () => handleOutOfRange(locationStatus);
    }
    if (verificationStep == VerificationStep.onlineCodeEntry) {
      return () => handleOnlineCodeSubmission();
    }
    if (verificationStep == VerificationStep.completed) {
      return () => handleCompletion();
    }

    return () {};
  }
}
