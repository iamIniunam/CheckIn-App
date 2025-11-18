import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';

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
