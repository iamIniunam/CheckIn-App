import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models.dart/face_verification_view_model.dart';
import 'package:attendance_app/ux/views/attendance/components/error_message.dart';
import 'package:flutter/material.dart';

class LocationCheckContent extends StatelessWidget {
  const LocationCheckContent({super.key, required this.viewModel});

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
              Icons.location_searching_rounded,
              size: 80,
              color: AppColors.defaultColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Verifying Location',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.defaultColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.locationStatus ?? 'Checking if you\'re on campus...',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.defaultColor),
            ),
            if (viewModel.errorMessage != null)
              ErrorMessage(message: viewModel.errorMessage ?? ''),
          ],
        ),
      ),
    );
  }
}
