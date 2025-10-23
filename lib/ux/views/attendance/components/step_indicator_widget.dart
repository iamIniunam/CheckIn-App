import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_verification_view_model.dart';
import 'package:flutter/material.dart';

class StepIndicatorWidget extends StatelessWidget {
  const StepIndicatorWidget({super.key, required this.viewModel});

  final AttendanceVerificationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Show QR scan step when attendance type is in-person or not set yet
            if (viewModel.verificationState.attendanceType == null ||
                viewModel.verificationState.attendanceType ==
                    AttendanceType.inPerson) ...[
              StepIndicatorItem(
                label: 'QR Scan',
                icon: Icons.qr_code_2_rounded,
                isActive: viewModel.verificationState.currentStep.index >=
                    VerificationStep.qrCodeScan.index,
                isLoading: viewModel.verificationState.currentStep ==
                        VerificationStep.qrCodeScan &&
                    viewModel.verificationState.isLoading,
              ),
              StepConnector(
                isActive: viewModel.verificationState.currentStep.index >
                    VerificationStep.qrCodeScan.index,
              ),
            ],

            if (viewModel.verificationState.attendanceType ==
                AttendanceType.online) ...[
              StepIndicatorItem(
                label: 'Online Code',
                icon: Icons.keyboard_alt_rounded,
                isActive: viewModel.verificationState.currentStep.index >=
                    VerificationStep.onlineCodeEntry.index,
                isLoading: viewModel.verificationState.currentStep ==
                        VerificationStep.onlineCodeEntry &&
                    viewModel.verificationState.isLoading,
              ),
              StepConnector(
                isActive: viewModel.verificationState.currentStep.index >
                    VerificationStep.onlineCodeEntry.index,
              ),
            ],

            // Show Location step only for in-person attendance
            if (viewModel.verificationState.attendanceType ==
                AttendanceType.inPerson) ...[
              StepIndicatorItem(
                label: 'Location',
                icon: Icons.location_on,
                isActive: viewModel.verificationState.currentStep.index >=
                    VerificationStep.locationCheck.index,
                isLoading: viewModel.verificationState.currentStep ==
                        VerificationStep.locationCheck &&
                    viewModel.verificationState.isLoading,
              ),
              StepConnector(
                isActive: viewModel.verificationState.currentStep.index >
                    VerificationStep.locationCheck.index,
              ),
            ],

            StepIndicatorItem(
              label: 'Submit',
              icon: Icons.check_circle,
              isActive: viewModel.verificationState.currentStep.index >=
                  VerificationStep.attendanceSubmission.index,
              isLoading: viewModel.verificationState.currentStep ==
                      VerificationStep.attendanceSubmission &&
                  viewModel.verificationState.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class StepIndicatorItem extends StatelessWidget {
  const StepIndicatorItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isLoading,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.defaultColor : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  icon,
                  size: 16,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.defaultColor : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class StepConnector extends StatelessWidget {
  const StepConnector({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 2,
      color: isActive ? AppColors.defaultColor : Colors.grey.shade300,
    );
  }
}
