import 'package:attendance_app/platform/utils/permission_utils.dart';
import 'package:attendance_app/ux/shared/components/blurred_loading_overlay.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/view_models/face_verification_view_model.dart';
import 'package:attendance_app/ux/views/attendance/alert_dialogs/cancel_dialog.dart';
import 'package:attendance_app/ux/views/attendance/components/attendance_type_indicator.dart';
import 'package:attendance_app/ux/views/attendance/components/face_verification_buttons.dart';
import 'package:attendance_app/ux/views/attendance/components/step_content.dart';
import 'package:attendance_app/ux/views/attendance/components/step_indicator_widget.dart';
import 'package:attendance_app/ux/views/onboarding/confirm_courses_page.dart';
import 'package:attendance_app/ux/views/attendance/verification_success_page.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:provider/provider.dart';

class FaceVerificationPage extends StatefulWidget {
  const FaceVerificationPage(
      {super.key, this.onExit, required this.mode, this.attendanceType});

  final void Function()? onExit;
  final FaceVerificationMode mode;
  final AttendanceType? attendanceType;

  @override
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  CameraController? cameraController;
  bool isCameraInitialized = false;
  late List<CameraDescription> cameras;
  late FaceVerificationViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = FaceVerificationViewModel();

    if (widget.attendanceType != null) {
      viewModel
          .setAttendanceType(widget.attendanceType ?? AttendanceType.inPerson);
    }

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
    switch (widget.mode) {
      case FaceVerificationMode.signUp:
        await handleSignUpVerification();
        break;
      case FaceVerificationMode.attendanceInPerson:
        await handleAttendanceVerification(AttendanceType.inPerson);
        break;
      case FaceVerificationMode.attendanceOnline:
        await handleAttendanceVerification(AttendanceType.online);
        break;
    }
  }

  Future<void> handleSignUpVerification() async {
    bool success = await viewModel.verifyFace();
    if (success && mounted) {
      Navigation.navigateToScreenAndClearOnePrevious(
        context: context,
        screen: const ConfirmCoursesPage(),
      );
    }
  }

  Future<void> handleAttendanceVerification(
      AttendanceType attendanceType) async {
    if (viewModel.verificationState.attendanceType == null) {
      viewModel.setAttendanceType(attendanceType);
    }

    bool success =
        await viewModel.startVerificationFlow(attendanceType: attendanceType);

    if (!success && mounted) {
      return;
    }

    if (viewModel.verificationState.currentStep == VerificationStep.completed &&
        mounted) {
      Navigation.navigateToScreenAndClearOnePrevious(
        context: context,
        screen: const VerificationSuccessPage(),
      );
    }
  }

  Future<void> handleOutOfRange(
      LocationVerificationStatus locationStatus) async {
    if (locationStatus == LocationVerificationStatus.outOfRange) {
      Navigation.navigateToHomePage(context: context);
    }
  }

  void handleExit() {
    if (widget.mode == FaceVerificationMode.signUp) {
      SignUpCancelDialog.show(
        context: context,
        cameraController: cameraController,
      );
    } else {
      AttendanceCancelDialog.show(
        context: context,
        cameraController: cameraController,
      );
    }
  }

  bool shouldShowStepIndicator() {
    return widget.mode == FaceVerificationMode.attendanceInPerson ||
        widget.mode == FaceVerificationMode.attendanceOnline;
  }

  bool isAttendanceMode() {
    return widget.mode == FaceVerificationMode.attendanceInPerson ||
        widget.mode == FaceVerificationMode.attendanceOnline;
  }

  @override
  void dispose() {
    cameraController?.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: PopScope(
        canPop: false,
        onPopInvoked: (result) => handleExit(),
        child: Scaffold(
          body: Consumer<FaceVerificationViewModel>(
            builder: (context, faceVericationViewModel, _) {
              final locationStatus =
                  faceVericationViewModel.locationState.verificationStatus;

              return Stack(
                children: [
                  // Main content
                  StepContent(
                    viewModel: faceVericationViewModel,
                    cameraController: cameraController,
                    isCameraInitialized: isCameraInitialized,
                  ),

                  // Step indicator for attendance mode
                  if (shouldShowStepIndicator())
                    StepIndicatorWidget(viewModel: faceVericationViewModel),

                  // Attendance type indicator
                  if (isAttendanceMode() &&
                      faceVericationViewModel
                              .verificationState.attendanceType !=
                          null)
                    AttendanceTypeIndicator(
                      attendanceType: faceVericationViewModel
                              .verificationState.attendanceType ??
                          AttendanceType.inPerson,
                      viewModel: faceVericationViewModel,
                    ),

                  // Exit button
                  ExitButton(
                    mode: widget.mode,
                    viewModel: faceVericationViewModel,
                    onExit: widget.onExit ?? handleExit,
                  ),

                  // Verification button
                  VerificationButton(
                    mode: widget.mode,
                    viewModel: faceVericationViewModel,
                    onVerify:
                        locationStatus == LocationVerificationStatus.outOfRange
                            ? () {
                                handleOutOfRange(locationStatus ??
                                    LocationVerificationStatus
                                        .successInRange); //TODO: check this logis again
                              }
                            : handleVerification,
                  ),

                  // Loading overlay
                  Visibility(
                    visible: faceVericationViewModel.isFaceVerifying,
                    child: BlurredLoadingOverlay(
                        showLoader: faceVericationViewModel
                            .verificationState.isLoading),
                    // child: AppDialogs.showLoadingDialog(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
