import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/message_providers.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/face_verification_view_model.dart';
import 'package:flutter/material.dart';

class AttendanceTypeIndicator extends StatelessWidget {
  const AttendanceTypeIndicator(
      {super.key, required this.attendanceType, required this.viewModel});

  final AttendanceType attendanceType;
  final FaceVerificationViewModel viewModel;

  static final VerificationMessageProvider messageProvider =
      DefaultVerificationMessageProvider();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 33,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryTeal,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.defaultColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              attendanceType == AttendanceType.inPerson
                  ? Icons.location_on
                  : Icons.wifi,
              size: 16,
              color: AppColors.defaultColor,
            ),
            const SizedBox(width: 4),
            Text(
              messageProvider.getAttendanceTypeDisplayName(attendanceType),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.defaultColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
