import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_verification_view_model.dart';
import 'package:attendance_app/ux/views/attendance/components/completion_content.dart';
import 'package:attendance_app/ux/views/attendance/components/location_content.dart';
import 'package:attendance_app/ux/views/attendance/components/online_code_entry_content.dart';
import 'package:attendance_app/ux/views/attendance/components/scan_view.dart';
import 'package:attendance_app/ux/views/attendance/components/submission_content.dart';
import 'package:flutter/material.dart';

class StepContent extends StatelessWidget {
  const StepContent({super.key, required this.viewModel});

  final AttendanceVerificationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    switch (viewModel.verificationState.currentStep) {
      case VerificationStep.qrCodeScan:
        return const ScanView();

      case VerificationStep.onlineCodeEntry:
        return OnlineCodeEntryContent(viewModel: viewModel);

      case VerificationStep.locationCheck:
        return LocationCheckContent(viewModel: viewModel);

      case VerificationStep.attendanceSubmission:
        return SubmissionContent(viewModel: viewModel);

      case VerificationStep.completed:
        return CompletionContent(viewModel: viewModel);
    }
  }
}
