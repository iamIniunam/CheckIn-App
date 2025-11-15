import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/onboarding/sign_up_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class SignUpCancelDialog {
  static Future<void> show(
      {required BuildContext context,
      CameraController? cameraController}) async {
    final result = await AppDialogs.showWarningDialog(
      context: context,
      title: AppStrings.cancelFaceRegistration,
      message: AppStrings.youreInTheMiddleOfRegistering,
      firstOption: AppStrings.stay,
      secondOption: AppStrings.yesCancel,
      onSecondOptionTap: () {
        Navigation.back(context: context, result: true);
      },
    );
    if (result == true) {
      await cameraController?.dispose();
      cameraController = null;

      if (context.mounted) {
        Navigation.navigateToScreenAndClearAllPrevious(
            context: context, screen: const SignUpPage());
      }
    }
  }
}

class AttendanceCancelDialog {
  static Future<void> show(
      {required BuildContext context,
      CameraController? cameraController}) async {
    final result = await AppDialogs.showWarningDialog(
      context: context,
      message: AppStrings.ifYouExitNowYourAttendanceWont,
      secondOption: AppStrings.yesCancel,
      firstOption: 'No',
      onSecondOptionTap: () {
        Navigation.back(context: context, result: true);
      },
    );
    if (result == true) {
      await cameraController?.dispose();
      cameraController = null;
      if (context.mounted) {
        Navigation.navigateToScreenAndClearAllPrevious(
            context: context, screen: const NavigationHostPage());
      }
    }
  }
}

class LocationCancelDialog {
  static Future<void> show({
    required BuildContext context,
    CameraController? cameraController,
  }) async {
    final result = await AppDialogs.showWarningDialog(
      context: context,
      title: AppStrings.cancelLocationVerification,
      message: AppStrings.ifYouExitNowYourAttendanceWont,
      secondOption: AppStrings.yesCancel,
      firstOption: 'No',
      onSecondOptionTap: () {
        Navigation.back(context: context, result: true);
      },
    );
    if (result == true) {
      await cameraController?.dispose();
      cameraController = null;
      if (context.mounted) {
        Navigation.navigateToScreenAndClearAllPrevious(
            context: context, screen: const NavigationHostPage());
      }
    }
  }
}
