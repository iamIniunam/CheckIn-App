import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/global_functions.dart';
import 'package:attendance_app/ux/shared/resources/app_buttons.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_form_fields.dart';
import 'package:attendance_app/ux/shared/resources/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/attendance/face_verification_page.dart';
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
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
                      screen: const FaceVerificationPage(
                          mode: FaceVerificationMode.attendance),
                    );
                  },
                  child: const Text(AppStrings.submit),
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16),
          //   child: PrimaryButton(
          //     enabled: codeController.text.isNotEmpty,
          //     onTap: () {},
          //     child: const Text('Submit'),
          //   ),
          // ),
        ],
      ),
    );
  }
}
