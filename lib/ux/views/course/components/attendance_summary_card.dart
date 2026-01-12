import 'package:attendance_app/platform/data_source/api/attendance/models/attedance_response.dart';
import 'package:attendance_app/ux/shared/components/shimmer_widget.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_view_model.dart';
import 'package:flutter/material.dart';

class AttendanceSummaryCard extends StatelessWidget {
  const AttendanceSummaryCard({
    super.key,
    required this.courseId,
    required this.viewModel,
  });

  final int courseId;
  final AttendanceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: viewModel.attendanceSummaryResult,
      builder: (context, result, _) {
        if (result.isLoading) {
          return loadingCard();
        }

        if (result.isError) {
          return errorCard();
        }

        final summary = result.data;
        if (summary == null) {
          return const SizedBox.shrink();
        }

        return dataCard(summary);
      },
    );
  }

  Widget dataCard(AttendanceSummary summary) {
    return summaryContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                '${summary.attendancePercentage}%',
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
            value: summary.totalClasses.toString(),
            label: 'Total',
            color: AppColors.totalClassesColor,
          ),
          StatColumn(
            icon: Icons.check_circle_rounded,
            value: summary.attendedClasses.toString(),
            label: 'Present',
            color: AppColors.presentColor,
          ),
          StatColumn(
            icon: Icons.cancel_rounded,
            value: summary.missedClasses.toString(),
            label: 'Absent',
            color: AppColors.absentColor,
          ),
        ],
      ),
    );
  }

  Widget loadingCard() {
    return summaryContainer(
      child: Shimmer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                ShimmerBox(
                  width: 100,
                  height: 48,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 8),
                ShimmerBox(
                  width: 120,
                  height: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            const SizedBox(width: 8),
            buildShimmerStatColumn(),
            buildShimmerStatColumn(),
            buildShimmerStatColumn(),
          ],
        ),
      ),
    );
  }

  Container summaryContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.defaultColor),
      ),
      child: child,
    );
  }

  Widget buildShimmerStatColumn() {
    return Column(
      children: [
        ShimmerBox(
          width: 28,
          height: 28,
          borderRadius: BorderRadius.circular(14),
        ),
        const SizedBox(height: 4),
        ShimmerBox(
          width: 30,
          height: 24,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        ShimmerBox(
          width: 40,
          height: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget errorCard() {
    return summaryContainer(
      child: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.defaultColor,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unable to load attendance summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.defaultColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pull down to refresh and try again',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
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
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}
