import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_verification_view_model.dart';
import 'package:flutter/material.dart';

class OnlineCodeEntryContent extends StatelessWidget {
  const OnlineCodeEntryContent({super.key, required this.viewModel});

  final AttendanceVerificationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: TextField(
          autofocus: true,
          maxLength: 6,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter Attendance Code',
            counterStyle: TextStyle(
              color: AppColors.defaultColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.defaultColor, fontSize: 32),
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.visiblePassword,
          onChanged: (value) => viewModel.onOnlineCodeEntered(value),
          onSubmitted: (value) => viewModel.onOnlineCodeEntered(value),
        ),
      ),
    );
  }
}
