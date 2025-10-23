import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class OnlineCodeEntryContent extends StatelessWidget {
  OnlineCodeEntryContent({super.key});

  final TextEditingController codeController = TextEditingController();

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
        controller: codeController,
      ),
    );
  }
}
