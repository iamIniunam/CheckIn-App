import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';

bool isSchoolEmail(String email) {
  if (email.contains('@ait.edu.gh')) {
    return true;
  } else {
    return false;
  }
}

void showAlert(
    {required BuildContext context,
    required String title,
    required String desc,
    String? buttonText}) {
  Alert(
    style: AlertStyle(
      alertBorder: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      isCloseButton: false,
      overlayColor: AppColors.black.withOpacity(0.5),
      titleStyle: const TextStyle(
          color: AppColors.defaultColor,
          fontSize: 18,
          fontWeight: FontWeight.w700),
      descStyle: const TextStyle(color: AppColors.grey, fontSize: 16),
      alertPadding: const EdgeInsets.all(65),
    ),
    context: context,
    title: title,
    desc: desc,
    buttons: [
      DialogButton(
        onPressed: () {
          Navigator.pop(context);
        },
        color: AppColors.defaultColor,
        radius: BorderRadius.circular(20),
        child: Text(
          buttonText ?? 'Try again',
          style: const TextStyle(color: AppColors.white, fontSize: 20),
        ),
      ),
    ],
  ).show();
}

Color statusColor(String status) {
  switch (status) {
    case AppStrings.present:
      return AppColors.statusGreen;
    case AppStrings.absent:
      return AppColors.statusRed;
    case AppStrings.late:
      return AppColors.statusOrange;
    default:
      return Colors.grey.shade500;
  }
}
