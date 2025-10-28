import 'package:attendance_app/platform/utils/permission_utils.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_verification_view_model.dart';
import 'package:attendance_app/ux/views/attendance/alert_dialogs/cancel_dialog.dart';
import 'package:attendance_app/ux/views/attendance/components/attendance_type_indicator.dart';
import 'package:attendance_app/ux/views/attendance/components/face_verification_buttons.dart';
import 'package:attendance_app/ux/views/attendance/components/step_content.dart';
import 'package:attendance_app/ux/views/attendance/components/step_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:provider/provider.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage(
      {super.key, this.onExit, required this.attendanceType});

  final void Function()? onExit;
  final AttendanceType attendanceType;

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  CameraController? cameraController;
  bool isCameraInitialized = false;
  List<CameraDescription> cameras = [];
  late AttendanceVerificationViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = AttendanceVerificationViewModel();
    viewModel.setAttendanceType(widget.attendanceType);

    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final permissionGranted = await PermissionUtils.requestCameraPermission(
          showSettingsOption: true);

      if (!permissionGranted) {
        debugPrint("Camera permission not granted, stopping initialization.");
        return;
      }

      cameras = await availableCameras();
      cameraController = CameraController(
        cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        ),
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController?.initialize();

      if (mounted) {
        setState(() {
          isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Unexpected Camera Error: $e");
    }
  }

  Future<void> handleVerification() async {
    final attendanceType =
        viewModel.verificationState.attendanceType ?? widget.attendanceType;

    await handleAttendanceVerification(attendanceType);
  }

  Future<void> handleAttendanceVerification(
      AttendanceType attendanceType) async {
    if (viewModel.verificationState.attendanceType == null) {
      viewModel.setAttendanceType(attendanceType);
    }

    // await viewModel.startVerificationFlow(attendanceType: attendanceType);
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
    AttendanceCancelDialog.show(
      context: context,
      cameraController: cameraController,
    );
    // }
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

  @override
  void dispose() {
    // If dispose is async, use the following:
    // await cameraController?.dispose();
    // However, Flutter's dispose() cannot be async, so use then() for cleanup.
    cameraController?.dispose().then((_) {
      viewModel.dispose();
      super.dispose();
    });
    // If dispose() is not async, keep as is:
    // cameraController?.dispose();
    // viewModel.dispose();
    // super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: PopScope(
        canPop: false,
        onPopInvoked: (_) => handleExit(),
        child: AppPageScaffold(
          hideAppBar: true,
          body: Consumer<AttendanceVerificationViewModel>(
            builder: (context, verificationViewModel, _) {
              final locationStatus =
                  verificationViewModel.locationState.verificationStatus;

              final verificationStep =
                  verificationViewModel.verificationState.currentStep;

              return Stack(
                children: [
                  // Main content
                  StepContent(
                    viewModel: verificationViewModel,
                  ),

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
                            widget.attendanceType),

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
                            LocationVerificationStatus
                                .successInRange, //TODO: check this logic
                        verificationStep),
                  ),

                  // Loading overlay
                  // Visibility(
                  //   visible: verificationViewModel.isFaceVerifying,
                  //   child: BlurredLoadingOverlay(
                  //       showLoader:
                  //           verificationViewModel.verificationState.isLoading),
                  // ),
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
    // if (verificationStep == VerificationStep.onlineCodeEntry) {
    //   return () => handleCompletion();
    // }
    if (verificationStep == VerificationStep.completed) {
      return () => handleCompletion();
    }
    
    return handleVerification;
  }
}
