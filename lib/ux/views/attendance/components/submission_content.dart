import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/face_verification_view_model.dart';
import 'package:attendance_app/ux/views/attendance/components/error_message.dart';
import 'package:attendance_app/ux/views/attendance/components/location_verified_badge.dart';
import 'package:flutter/material.dart';

class SubmissionContent extends StatelessWidget {
  const SubmissionContent({super.key, required this.viewModel});

  final FaceVerificationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.upload_rounded,
              size: 80,
              color: AppColors.defaultColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Submitting Attendance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.defaultColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please wait while we record your attendance...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.defaultColor),
            ),
            if (viewModel.locationState.distanceFromCampus != null)
              LocationVerifiedBadge(
                  distance: viewModel.locationState.distanceFromCampus ?? 0),
            if (viewModel.verificationState.errorMessage != null)
              ErrorMessage(message: viewModel.verificationState.errorMessage ?? ''),
          ],
        ),
      ),
    );
  }
}
