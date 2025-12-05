import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_verification_view_model.dart';
import 'package:flutter/material.dart';

class OnlineCodeEntryContent extends StatefulWidget {
  const OnlineCodeEntryContent({super.key, required this.viewModel});

  final AttendanceVerificationViewModel viewModel;

  @override
  State<OnlineCodeEntryContent> createState() => _OnlineCodeEntryContentState();
}

class _OnlineCodeEntryContentState extends State<OnlineCodeEntryContent> {
  Future<void> handleOnlineCodeSubmission() async {
    final entered = widget.viewModel.enteredOnlineCode;
    if (entered == null || entered.trim().isEmpty) {
      AppDialogs.showErrorDialog(
          context: context, message: 'Please enter the attendance code');
      return;
    }

    final validationResult = widget.viewModel.validateAndSetOnlineCode(entered);

    if (!validationResult.isValid) {
      AppDialogs.showErrorDialog(
        context: context,
        message: validationResult.errorMessage ?? 'Invalid attendance code',
      );
      return;
    }

    final success = await widget.viewModel.submitAttendance();

    if (!mounted) return;

    if (success) {
      widget.viewModel.moveToNextStep();

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      widget.viewModel.moveToNextStep();
    } else {
      final message = widget
              .viewModel.attendanceSubmissionResult.value.message ??
          'Unable to submit attendance. Please check your code and try again.';
      AppDialogs.showErrorDialog(
        context: context,
        message: message,
        action: () {
          if (message.contains(
              'You are not registered for the course linked to this attendance code.')) {
            Navigation.navigateToHomePage(context: context);
          }
        },
      );
    }
  }

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
          onChanged: (value) => widget.viewModel.onOnlineCodeEntered(value),
          onSubmitted: (value) => handleOnlineCodeSubmission(),
        ),
      ),
    );
  }
}
