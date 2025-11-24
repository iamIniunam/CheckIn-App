import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/views/attendance/components/padded_column.dart';
import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard(
      {super.key,
      required this.icon,
      required this.title,
      required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppMaterial(
      color: AppColors.primaryTeal,
      borderRadius: BorderRadius.circular(15),
      inkwellBorderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: PaddedColumn(
        padding: const EdgeInsets.all(24),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.defaultColor, size: 80),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.defaultColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
