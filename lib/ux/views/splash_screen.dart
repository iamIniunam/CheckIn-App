import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/confirm_courses_page.dart';
import 'package:attendance_app/ux/views/onboarding/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    final authViewModel = context.read<AuthViewModel>();
    debugPrint('Starting app initialization...');

    final isLoggedIn = await authViewModel.getIsUserLoggedIn();

    debugPrint('Is logged in: $isLoggedIn');
    debugPrint('Current student: ${authViewModel.currentStudent?.idNumber}');
    debugPrint('Level: ${authViewModel.currentStudent?.level}');
    debugPrint('Semester: ${authViewModel.currentStudent?.semester}');

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (isLoggedIn == true) {
      // final hasRequiredData = authViewModel.currentStudent?.level != null &&
      //     (authViewModel.currentStudent?.level ?? '').isNotEmpty &&
      //     authViewModel.currentStudent?.semester != null &&
      //     (authViewModel.currentStudent?.semester ?? 0) > 0;

      // debugPrint('Has required data: $hasRequiredData');

      // if (hasRequiredData) {
      Navigation.navigateToScreen(
          context: context, screen: const ConfirmCoursesPage());
      return;
      // }
    }
    Navigation.navigateToScreen(context: context, screen: const SignUpPage());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: AppColors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                image: DecorationImage(image: AppImages.appLogoIos),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            // SizedBox(
            //   height: 120,
            //   width: 120,
            //   child: Image(image: AppImages.appLogo),
            // ),
            const SizedBox(height: 10),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.defaultColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                taglineText(text: 'Scan. '),
                taglineText(text: 'Verify. '),
                taglineText(text: 'Done.'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget taglineText({required String text}) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.defaultColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
