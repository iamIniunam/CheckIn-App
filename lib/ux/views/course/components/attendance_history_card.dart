import 'package:attendance_app/platform/data_source/api/attendance/models/attedance_response.dart';
import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/platform/extensions/date_time_extensions.dart';
import 'package:attendance_app/platform/extensions/string_extensions.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class AttendanceHistoryCard extends StatelessWidget {
  const AttendanceHistoryCard({super.key, required this.history});

  final AttendanceHistory history;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: AppMaterial(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Text(
                      history.classDate?.friendlyMonthShort().toUpperCase() ??
                          '',
                      style: const TextStyle(
                          color: AppColors.defaultColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      history.classDate?.day.toString() ?? '',
                      style: const TextStyle(
                        color: AppColors.defaultColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.code ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.defaultColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${history.className ?? ''} • ${history.mode ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.defaultColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    // Text(
                    //   history.name ?? '',
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: const TextStyle(
                    //     color: AppColors.defaultColor,
                    //     fontSize: 13,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    history.classDate?.friendlyTime() ?? '',
                    style: const TextStyle(
                      color: AppColors.defaultColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: AppColors.primaryTeal,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          history.attendanceStatus?.toSentenceCase() ?? '',
                          style: TextStyle(
                            color: history.getStatusColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
