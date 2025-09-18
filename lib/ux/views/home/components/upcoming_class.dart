import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/attendance/scan_page.dart';
import 'package:flutter/material.dart';

class UpcomingClass extends StatelessWidget {
  const UpcomingClass({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.defaultColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.currentClass,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const Text(
              AppStrings.sampleCurrentClass,
              style: TextStyle(
                  color: AppColors.defaultColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                AppStrings.sampleCurrentClassTime,
                style: TextStyle(
                  color: AppColors.defaultColor,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              onTap: () {
                Navigation.navigateToScreen(
                    context: context, screen: const ScanPage());
              },
              backgroundColor: AppColors.defaultColor,
              foregroundColor: AppColors.white,
              child: const Text(AppStrings.markAttendance),
            ),
          ],
        ),
      ),
    );
  }
}
