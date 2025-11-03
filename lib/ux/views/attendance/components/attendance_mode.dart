import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class AttendanceMode extends StatelessWidget {
  const AttendanceMode({super.key, required this.mode, required this.onTap});

  final String mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppMaterial(
        color: AppColors.primaryTeal,
        borderRadius: BorderRadius.circular(30),
        inkwellBorderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.defaultColor)),
          child: Text(
            mode,
            style: const TextStyle(
              color: AppColors.defaultColor,
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
