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
  bool _isSubmitting = false;

  Future<void> handleOnlineCodeSubmission() async {
    final entered = widget.viewModel.enteredOnlineCode;
    if (entered == null || entered.trim().isEmpty) {
      AppDialogs.showErrorDialog(
          context: context, message: 'Please enter the attendance code');
      return;
    }

    final validationResult = widget.viewModel.validateAndSetOnlineCode(entered);

    if (!validationResult.isValid) {
      if (!mounted) return;
      AppDialogs.showErrorDialog(
        context: context,
        message: validationResult.errorMessage ?? 'Invalid attendance code',
      );
      return;
    }
    setState(() => _isSubmitting = true);

    final success = await widget.viewModel.submitAttendance();

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      // Advance through submission and completion steps
      widget.viewModel.moveToNextStep();
      widget.viewModel.moveToNextStep();
      return;
    }

    final message =
        '${widget.viewModel.attendanceSubmissionResult.value.message}. Please check your code and try again.';

    // Skip dialog for terminal errors (shown on completion)
    if (widget.viewModel.isTerminalSubmissionMessage(message)) {
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              maxLength: 6,
              enabled: !_isSubmitting,
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
              style:
                  const TextStyle(color: AppColors.defaultColor, fontSize: 32),
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.visiblePassword,
              onChanged: (value) => widget.viewModel.onOnlineCodeEntered(value),
              onSubmitted: (value) => handleOnlineCodeSubmission(),
            ),
            if (_isSubmitting)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.defaultColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
