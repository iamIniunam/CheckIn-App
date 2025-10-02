import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:flutter/material.dart';

class CompletionContent extends StatelessWidget {
  const CompletionContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 45),
        // padding: const EdgeInsets.all(32),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Container(
            //   width: 80,
            //   height: 80,
            //   decoration: BoxDecoration(
            //     color: Colors.green.shade100,
            //     shape: BoxShape.circle,
            //   ),
            //   child: Icon(
            //     Icons.check_rounded,
            //     size: 50,
            //     color: Colors.green.shade600,
            //   ),
            // ),
            // const SizedBox(height: 24),
            // Text(
            //   'Verification Complete!',
            //   style: TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.green.shade600,
            //   ),
            // ),
            // const SizedBox(height: 16),
            // const Text(
            //   'Your attendance has been successfully recorded.',
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: Colors.grey,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
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
                  color: AppColors.defaultColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
