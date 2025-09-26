import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/components/app_dialog_widgets.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:flutter/material.dart';

class AppDialogs {
  AppDialogs._();

  static Future showLoadingDialog(BuildContext context, {String? loadingText}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppLoadingDialogWidget(loadingText: loadingText),
    );
  }

  static showConfirmationDialog(
      {required BuildContext context,
      required String message,
      String title = AppStrings.confirm,
      required VoidCallback? afterConfirmation,
      String confirmText = AppStrings.confirm,
      bool barrierDismissible = true}) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => PopScope(
        canPop: barrierDismissible,
        child: AlertDialog(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.defaultColor,
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(onTap: afterConfirmation, child: Text(confirmText)),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  AppStrings.cancel,
                  style: TextStyle(
                      fontSize: 16,
                      color: AppColors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  static Future showSuccessDialog(
      {required BuildContext context,
      required String message,
      VoidCallback? action,
      bool barrierDismissible = true}) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AppSuccessDialogWidget(
        message: message,
        action: action,
        hasTitle: false,
      ),
    );
  }

  static void showErrorDialog(
      {required BuildContext context,
      required String message,
      String? title,
      VoidCallback? action}) {
    showAlertDialog(context,
        title: title ?? AppStrings.alert, message: message, action: action);
  }

  static Future showAlertDialog(
    BuildContext context, {
    required String message,
    String title = AppStrings.alert,
    VoidCallback? action,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppAlertDialogWidget.singleButton(
        title: title,
        message: message,
        onButtonTap: action,
      ),
    );
  }

  static Future showWarningDialog(
    BuildContext context, {
    required String message,
    String title = AppStrings.alert,
    VoidCallback? action,
    String? firstOption,
    String? secondOption,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppAlertDialogWidget(
        title: title,
        message: message,
        onSecondOptionTap: action,
        firstOption: firstOption,
        secondOption: secondOption,
      ),
    );
  }
}
