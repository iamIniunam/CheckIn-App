import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class OnlineCodeEntryContent extends StatelessWidget {
  const OnlineCodeEntryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: const TextField(
          autofocus: true,
          decoration: InputDecoration(
              border: InputBorder.none, hintText: 'Enter Attendance Code'),
          style: TextStyle(color: AppColors.defaultColor, fontSize: 32),
          textInputAction: TextInputAction.done,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
