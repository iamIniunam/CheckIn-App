import 'package:attendance_app/platform/extensions/string_extensions.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:flutter/material.dart';

class AppLoadingDialogWidget extends StatelessWidget {
  const AppLoadingDialogWidget({super.key, this.loadingText});

  final String? loadingText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(7)),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                color: AppColors.defaultColor,
              ),
            ),
            Visibility(
              visible: !loadingText.isNullOrBlank,
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  loadingText ?? '',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppSuccessDialogWidget extends StatelessWidget {
  const AppSuccessDialogWidget(
      {super.key,
      required this.message,
      this.title,
      required this.action,
      required this.hasTitle});

  final String message;
  final String? title;
  final Function? action;
  final bool hasTitle;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: AlertDialog(
        contentPadding: const EdgeInsets.only(top: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppImages.svgSuccessDialogIcon,
            const SizedBox(height: 16),
            Visibility(
              visible: hasTitle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      title ?? '',
                      style: const TextStyle(
                        color: AppColors.defaultColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(
              color: AppColors.grey,
              thickness: 1,
              height: 0,
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                action?.call();
              },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Okay',
                      style: TextStyle(
                        color: AppColors.defaultColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppAlertDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? firstOption;
  final VoidCallback? onFirstOptionTap;
  final String? secondOption;
  final VoidCallback? onSecondOptionTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final bool singleButton;

  const AppAlertDialogWidget({
    super.key,
    required this.title,
    required this.message,
    this.firstOption,
    this.secondOption,
    this.onFirstOptionTap,
    this.onSecondOptionTap,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.singleButton = false,
  });

  const AppAlertDialogWidget.singleButton({
    super.key,
    required this.title,
    required this.message,
    String? buttonText,
    VoidCallback? onButtonTap,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  })  : firstOption = buttonText,
        onFirstOptionTap = onButtonTap,
        secondOption = null,
        onSecondOptionTap = null,
        singleButton = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Material(
        elevation: 0,
        color: AppColors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.defaultColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.defaultColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            if (singleButton || secondOption == null) ...[
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  backgroundColor: backgroundColor ?? AppColors.defaultColor,
                  onTap: onFirstOptionTap ??
                      () {
                        Navigation.back(context: context, result: true);
                      },
                  child: Text(firstOption ?? 'Okay'),
                ),
              )
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: PrimaryOutlinedButton(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      onTap: onFirstOptionTap ??
                          () {
                            Navigation.back(context: context, result: false);
                          },
                      child: Text(firstOption ?? 'No'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: PrimaryButton(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      backgroundColor: backgroundColor ?? AppColors.red500,
                      onTap: onSecondOptionTap,
                      child: Text(secondOption ?? ''),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
