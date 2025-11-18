import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_verification_view_model.dart';
import 'package:flutter/material.dart';

class OnlineCodeEntryContent extends StatelessWidget {
  const OnlineCodeEntryContent({super.key, required this.viewModel});

  final AttendanceVerificationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextField(
        autofocus: true,
        decoration: const InputDecoration(
            border: InputBorder.none, hintText: 'Enter Attendance Code'),
        style: const TextStyle(color: AppColors.defaultColor, fontSize: 32),
        textInputAction: TextInputAction.done,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.characters,
        keyboardType: TextInputType.visiblePassword,
        onChanged: (value) => viewModel.onOnlineCodeEntered(value),
        onSubmitted: (value) => viewModel.onOnlineCodeEntered(value),
        maxLength: 6,
      ),
    );
  }
}
