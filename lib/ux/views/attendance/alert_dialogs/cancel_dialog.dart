import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/components/app_dialogs.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/onboarding/sign_up_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class SignUpCancelDialog {
  static Future<void> show({
    required BuildContext context,
    CameraController? cameraController,
  }) async {
    final result = await showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AppAlertDialog(
          title: AppStrings.cancelFaceRegistration,
          desc: AppStrings.youreInTheMiddleOfRegistering,
          firstOption: AppStrings.stay,
          secondOption: AppStrings.yesCancel,
          onFirstOptionTap: () {
            Navigation.back(context: context, result: false);
          },
          onSecondOptionTap: () {
            Navigation.back(context: context, result: true);
          },
        );
      },
    );
    if (result == true) {
      await cameraController?.dispose();
      cameraController = null;

      if (context.mounted) {
        Navigation.navigateToScreen(
            context: context, screen: const SignUpPage());
      }
    }
  }
}

class AttendanceCancelDialog {
  static Future<void> show({
    required BuildContext context,
    CameraController? cameraController,
  }) async {
    final result = await showAdaptiveDialog(
        context: context,
        builder: (context) {
          return AppAlertDialog(
            title: AppStrings.cancelFaceVerification,
            desc: AppStrings.ifYouExitNowYourAttendanceWont,
            secondOption: AppStrings.yesCancel,
            firstOption: 'No',
            onFirstOptionTap: () {
              Navigation.back(context: context, result: false);
            },
            onSecondOptionTap: () {
              Navigation.back(context: context, result: true);
            },
          );
        });
    if (result == true) {
      await cameraController?.dispose();
      cameraController = null;
      if (context.mounted) {
        Navigation.navigateToScreen(
            context: context, screen: const NavigationHostPage());
      }
    }
  }
}
