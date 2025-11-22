import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:flutter/material.dart';

class MarkAttendanceQuickAccess extends StatelessWidget {
  const MarkAttendanceQuickAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
              'Ready to check in?',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              'Tap the button below to mark your attendance for today’s class',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.defaultColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              onTap: () {
                Navigation.navigateToScreen(
                  context: context,
                  screen: const NavigationHostPage(index: 1),
                );
              },
              child: const Text(AppStrings.markAttendance),
            ),
          ],
        ),
      ),
    );
  }
}
