import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';

Color statusColor(String status) {
  final normalized = status.toLowerCase();
  if (normalized == AppStrings.present.toLowerCase()) {
    return AppColors.statusGreen;
  } else if (normalized == AppStrings.absent.toLowerCase()) {
    return AppColors.statusRed;
  } else if (normalized == AppStrings.late.toLowerCase()) {
    return AppColors.statusOrange;
  } else {
    return Colors.grey.shade500;
  }
}
