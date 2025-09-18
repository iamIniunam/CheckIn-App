import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:flutter/material.dart';

class VerificationSuccessPage extends StatefulWidget {
  const VerificationSuccessPage({super.key});

  @override
  State<VerificationSuccessPage> createState() =>
      _VerificationSuccessPageState();
}

class _VerificationSuccessPageState extends State<VerificationSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      hideAppBar: false,
      title: AppStrings.checkInComplete,
      showBackButton: false,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 150,
                      width: 150,
                      child: Image(image: AppImages.successLogo)),
                  const Text(
                    AppStrings.attendanceRecorded,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.defaultColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    AppStrings.thanksForShowingUpToday,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.defaultColor,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              onTap: () {
                Navigation.navigateToScreen(
                    context: context, screen: const NavigationHostPage());
                // //this exits the app in andriod
                // if (Platform.isAndroid) {
                //   SystemNavigator.pop();
                // }
                // //this exits the app in ios
                // else {
                //   exit(0);
                // }
              },
              child: const Text(AppStrings.done),
            ),
          ),
        ],
      ),
    );
  }
}
