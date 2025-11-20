import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class BackAndNextButtonRow extends StatelessWidget {
  const BackAndNextButtonRow({
    super.key,
    this.enableNextButton = true,
    this.enableBackButton = true,
    required this.onTapNextButton,
    this.firstText,
    this.secondText,
    this.onTapFirstButton,
    this.firstIcon,
    this.secondIcon,
    this.buttonColor,
    this.nextWidget,
    this.hasBottomPadding = false,
  });

  final bool enableNextButton;
  final bool enableBackButton;
  final VoidCallback onTapNextButton;
  final String? firstText;
  final String? secondText;
  final VoidCallback? onTapFirstButton;
  final Widget? firstIcon;
  final Widget? secondIcon;
  final Color? buttonColor;
  final Widget? nextWidget;
  final bool hasBottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 16, left: 16, right: 16, bottom: hasBottomPadding ? 16 : 0),
      color: AppColors.white,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: PrimaryOutlinedButton(
              enabled: enableBackButton,
              onTap: onTapFirstButton ??
                  () {
                    Navigator.pop(context);
                  },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: firstIcon != null,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: firstIcon,
                    ),
                  ),
                  Text(
                    firstText ?? 'Back',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(
              backgroundColor: buttonColor ?? AppColors.defaultColor,
              enabled: enableNextButton,
              onTap: onTapNextButton,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: secondIcon != null,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: secondIcon,
                    ),
                  ),
                  nextWidget != null
                      ? nextWidget ?? const SizedBox()
                      : Text(
                          secondText ?? 'Next',
                          textAlign: TextAlign.center,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
