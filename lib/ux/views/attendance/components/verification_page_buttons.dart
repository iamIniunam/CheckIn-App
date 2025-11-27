import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_verification_view_model.dart';
import 'package:flutter/material.dart';

class ExitButton extends StatelessWidget {
  const ExitButton({
    super.key,
    required this.attendanceType,
    required this.viewModel,
    required this.onExit,
  });

  final AttendanceType attendanceType;
  final AttendanceVerificationViewModel viewModel;
  final VoidCallback onExit;

  bool isAttendanceMode() {
    return attendanceType == AttendanceType.inPerson ||
        attendanceType == AttendanceType.online;
  }

  @override
  Widget build(BuildContext context) {
    if (isAttendanceMode() &&
        viewModel.verificationState.currentStep !=
            VerificationStep.qrCodeScan &&
        viewModel.verificationState.currentStep !=
            VerificationStep.onlineCodeEntry &&
        viewModel.verificationState.currentStep !=
            VerificationStep.locationCheck) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 30,
      right: 12,
      child: AppMaterial(
        inkwellBorderRadius: BorderRadius.circular(10),
        onTap: onExit,
        child: Container(
          width: 85,
          padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Exit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.defaultColor,
                ),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.close_rounded,
                size: 22,
                color: AppColors.defaultColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerificationButton extends StatelessWidget {
  const VerificationButton({
    super.key,
    required this.viewModel,
    required this.onVerify,
  });

  final AttendanceVerificationViewModel viewModel;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    if (!viewModel.shouldShowButton()) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 50.0,
      left: 30,
      right: 30,
      child: PrimaryButton(
        enabled: viewModel.shouldEnableButton(),
        onTap: onVerify,
        child: Text(viewModel.getButtonText()),
      ),
    );
  }
}
