import 'package:attendance_app/platform/extensions/string_extensions.dart';
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
                        fontWeight: FontWeight.w700,
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
                  color: AppColors.defaultColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.grey, thickness: 1, height: 0),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                action?.call();
              },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
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
  final String message;
  final String title;
  final Function? action;

  const AppAlertDialogWidget({
    super.key,
    required this.message,
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        contentPadding: const EdgeInsets.only(top: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImages.svgErrorDialogIcon,
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.defaultColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.defaultColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.grey, thickness: 1, height: 0),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                action?.call();
              },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
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

class AppWarningAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? firstOption;
  final Function? onFirstOptionTap;
  final String? secondOption;
  final Function? onSecondOptionTap;
  final Color? textColor;

  const AppWarningAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.firstOption,
    this.onFirstOptionTap,
    this.secondOption,
    this.onSecondOptionTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        contentPadding: const EdgeInsets.only(top: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImages.svgExclamationCircle,
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.defaultColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.defaultColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.grey, thickness: 1, height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onFirstOptionTap?.call();
                    },
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        firstOption ?? 'No',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.defaultColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 51,
                  width: 1,
                  color: AppColors.grey,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      // Navigator.pop(context);
                      onSecondOptionTap?.call();
                    },
                    borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        secondOption ?? 'Yes, cancel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor ?? AppColors.defaultColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
