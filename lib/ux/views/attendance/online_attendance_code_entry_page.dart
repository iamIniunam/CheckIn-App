import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/attendance/verification_page.dart';
import 'package:flutter/material.dart';

class OnlineAttendanceCodeEntryPage extends StatefulWidget {
  const OnlineAttendanceCodeEntryPage({super.key});

  @override
  State<OnlineAttendanceCodeEntryPage> createState() =>
      _OnlineAttendanceCodeEntryPageState();
}

class _OnlineAttendanceCodeEntryPageState
    extends State<OnlineAttendanceCodeEntryPage> {
  TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: AppStrings.enterClassCode,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const Text(
            AppStrings.inputTheAttendanceCodeProvided,
            style: TextStyle(
                color: AppColors.defaultColor,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          PrimaryTextFormField(
            autofocus: true,
            labelText: AppStrings.classCode,
            controller: codeController,
            hintText: AppStrings.classCodeHint,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.characters,
            onChanged: (p0) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            enabled: codeController.text.isNotEmpty,
            onTap: () {
              Navigation.navigateToScreen(
                context: context,
                screen: const VerificationPage(
                  attendanceType: AttendanceType.online,
                ),
              );
            },
            child: const Text(AppStrings.submit),
          ),
        ],
      ),
    );
  }
}
