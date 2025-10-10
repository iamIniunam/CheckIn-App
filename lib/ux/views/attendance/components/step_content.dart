import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_verification_view_model.dart';
import 'package:attendance_app/ux/views/attendance/components/completion_content.dart';
import 'package:attendance_app/ux/views/attendance/components/face_verification_content.dart';
import 'package:attendance_app/ux/views/attendance/components/location_content.dart';
import 'package:attendance_app/ux/views/attendance/components/submission_content.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class StepContent extends StatelessWidget {
  const StepContent({
    super.key,
    required this.viewModel,
    required this.cameraController,
    required this.isCameraInitialized,
  });

  final AttendanceVerificationViewModel viewModel;
  final CameraController? cameraController;
  final bool isCameraInitialized;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.93;
    final previewSize = cameraController?.value.previewSize;

    switch (viewModel.verificationState.currentStep) {
      case VerificationStep.faceVerification:
        return FaceVerificationContent(
          size: size,
          previewSize: previewSize,
          cameraController: cameraController,
          isCameraInitialized: isCameraInitialized,
        );

      case VerificationStep.locationCheck:
        return LocationCheckContent(viewModel: viewModel);

      case VerificationStep.attendanceSubmission:
        return SubmissionContent(viewModel: viewModel);

      case VerificationStep.completed:
        return const CompletionContent();
    }
  }
}
