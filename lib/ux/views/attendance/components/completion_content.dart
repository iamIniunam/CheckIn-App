import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_verification_view_model.dart';
import 'package:attendance_app/ux/views/attendance/components/location_verified_badge.dart';
import 'package:flutter/material.dart';

class CompletionContent extends StatelessWidget {
  const CompletionContent({super.key, required this.viewModel});

  final AttendanceVerificationViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 45),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ValueListenableBuilder<UIResult<bool>>(
          valueListenable: viewModel.attendanceSubmissionResult,
          builder: (context, result, _) {
            return result.isSuccess ? successContent() : failureContent();
          },
        ),
      ),
    );
  }

  Widget successContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: Image(image: AppImages.successLogo),
        ),
        const Text(
          AppStrings.attendanceRecorded,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.defaultColor,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          AppStrings.thanksForShowingUpToday,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.defaultColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (viewModel.requiresLocationCheck)
          ValueListenableBuilder<UIResult<AttendanceResult>>(
            valueListenable: viewModel.attendanceLocationResult,
            builder: (context, result, child) {
              if (result.isSuccess && result.data != null) {
                final data = result.data;
                return LocationVerifiedBadge(
                  distance: data?.distance ?? 0.0,
                  formattedDistance: data?.formattedDistance,
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  Widget failureContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: AppImages.svgErrorDialogIcon,
        ),
        ValueListenableBuilder<UIResult<bool>>(
          valueListenable: viewModel.attendanceSubmissionResult,
          builder: (context, result, child) {
            final message = result.message;
            if (message == null || message.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  const Text(
                    'Attendance Submission failed',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.defaultColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.defaultColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (viewModel.requiresLocationCheck)
          ValueListenableBuilder<UIResult<AttendanceResult>>(
            valueListenable: viewModel.attendanceLocationResult,
            builder: (context, result, child) {
              if (result.isSuccess && result.data != null) {
                final data = result.data;
                return LocationVerifiedBadge(
                  distance: data?.distance ?? 0.0,
                  formattedDistance: data?.formattedDistance,
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }
}
