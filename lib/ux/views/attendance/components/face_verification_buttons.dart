import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_verification_view_model.dart';
import 'package:flutter/material.dart';

class ExitButton extends StatelessWidget {
  const ExitButton({
    super.key,
    required this.mode,
    required this.viewModel,
    required this.onExit,
  });

  final FaceVerificationMode mode;
  final AttendanceVerificationViewModel viewModel;
  final VoidCallback onExit;

  bool isAttendanceMode() {
    return mode == FaceVerificationMode.attendanceInPerson ||
        mode == FaceVerificationMode.attendanceOnline;
  }

  @override
  Widget build(BuildContext context) {
    if (isAttendanceMode() &&
        viewModel.verificationState.currentStep !=
            VerificationStep.faceVerification) {
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
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.close_sharp,
                size: 25,
                color: AppColors.black,
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
    required this.mode,
    required this.viewModel,
    required this.onVerify,
  });

  final FaceVerificationMode mode;
  final AttendanceVerificationViewModel viewModel;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    if (!viewModel.shouldShowButton(mode)) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 50.0,
      left: 30,
      right: 30,
      child: PrimaryButton(
        enabled: viewModel.shouldEnableButton(),
        onTap: onVerify,
        child: Text(viewModel.getButtonText(mode)),
      ),
    );
  }
}
