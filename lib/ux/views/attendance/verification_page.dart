import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_verification_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/views/attendance/alert_dialogs/cancel_dialog.dart';
import 'package:attendance_app/ux/views/attendance/components/attendance_type_indicator.dart';
import 'package:attendance_app/ux/views/attendance/components/verification_page_buttons.dart';
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
    final type = viewModel.attendanceType;
    return type == AttendanceType.inPerson || type == AttendanceType.online;
  }

  bool isAttendanceMode() {
    final type = viewModel.attendanceType;
    return type == AttendanceType.inPerson || type == AttendanceType.online;
  }

  Future<void> handleOnlineCodeSubmission() async {
    final entered = viewModel.enteredOnlineCode;
    if (entered == null || entered.trim().isEmpty) {
      if (!mounted) return;
      AppDialogs.showErrorDialog(
          context: context, message: 'Please enter the attendance code');
      return;
    }

    final validationResult = viewModel.validateAndSetOnlineCode(entered);

    if (!validationResult.isValid) {
      if (!mounted) return;
      AppDialogs.showErrorDialog(
        context: context,
        message: validationResult.errorMessage ?? 'Invalid attendance code',
      );
      return;
    }

    viewModel.moveToNextStep();

    final success = await viewModel.submitAttendance();

    if (success) {
      viewModel.moveToNextStep();
    } else {
      final message = viewModel.attendanceSubmissionResult.value.message ??
          'Unable to submit attendance. Please check your code and try again.';
      if (!mounted) return;
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
              final verificationStep = verificationViewModel.currentStep;

              return Stack(
                children: [
                  // Main content
                  StepContent(viewModel: verificationViewModel),

                  if (shouldShowStepIndicator())
                    StepIndicatorWidget(viewModel: verificationViewModel),

                  if (isAttendanceMode())
                    AttendanceTypeIndicator(
                        attendanceType: verificationViewModel.attendanceType),

                  ExitButton(onExit: widget.onExit ?? handleExit),

                  VerificationButton(
                    viewModel: verificationViewModel,
                    onVerify: viewModel.attendanceSubmissionResult.value.isError
                        ? retrySubmissionCallback(widget.attendanceType)
                        : getOnVerify(verificationStep, locationStatus),
                  ),

                  if (verificationStep == VerificationStep.locationCheck &&
                      (locationStatus == LocationVerificationStatus.failed))
                    BackAndNextVerificationButton(
                      viewModel: verificationViewModel,
                      onTap: () {
                        viewModel.proceedWithAutomaticFlow();
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  VoidCallback getOnVerify(VerificationStep verificationStep,
      LocationVerificationStatus? locationStatus) {
    if (locationStatus == LocationVerificationStatus.outOfRange) {
      return () => handleOutOfRange(
          locationStatus ?? LocationVerificationStatus.outOfRange);
    }

    if (verificationStep == VerificationStep.onlineCodeEntry) {
      return () => handleOnlineCodeSubmission();
    }
    if (verificationStep == VerificationStep.completed) {
      return () => handleCompletion();
    }

    return () {};
  }

  VoidCallback retrySubmissionCallback(AttendanceType attendanceType) {
    if (attendanceType == AttendanceType.inPerson) {
      return () async {
        viewModel.proceedWithAutomaticFlow();
      };
    }
    return () async {
      handleOnlineCodeSubmission();
    };
  }
}
