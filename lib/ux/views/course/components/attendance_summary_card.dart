import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_view_model.dart';
import 'package:flutter/material.dart';

class AttendanceSummaryCard extends StatelessWidget {
  const AttendanceSummaryCard({super.key, required this.viewModel});

  final AttendanceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.defaultColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                '${viewModel.attendancePercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.defaultColor,
                ),
              ),
              const Text(
                'Attendance Rate',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.defaultColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          StatColumn(
              icon: Icons.class_rounded,
              value: viewModel.totalClasses.toString(),
              label: 'Total'),
          StatColumn(
              icon: Icons.check_circle_rounded,
              value: viewModel.attendedClasses.toString(),
              label: 'Present'),
          StatColumn(
            icon: Icons.cancel_rounded,
            value: viewModel.missedClasses.toString(),
            label: 'Absent',
          ),
        ],
      ),
    );
  }
}

class StatColumn extends StatelessWidget {
  const StatColumn({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.defaultColor, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.defaultColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.defaultColor,
          ),
        ),
      ],
    );
  }
}
