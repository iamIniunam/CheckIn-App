import 'package:attendance_app/ux/shared/components/back_and_next_button_row.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:flutter/material.dart';

class LogoutConfirmationBottomSheet extends StatelessWidget {
  const LogoutConfirmationBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          AppImages.svgErrorDialogIcon,
          const SizedBox(height: 16),
          const Text(
            'Logout',
            style: TextStyle(
              color: AppColors.defaultColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              color: AppColors.defaultColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          BackAndNextButtonRow(
            firstText: 'Cancel',
            secondText: 'Yes, log out',
            buttonColor: AppColors.red500,
            onTapNextButton: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }
}
