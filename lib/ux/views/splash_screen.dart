import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeApp();
    });
  }

  Future<void> initializeApp() async {
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.checkLoginStatus();

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (authViewModel.isLoggedIn && authViewModel.currentStudent != null) {
      Navigation.navigateToScreenAndClearAllPrevious(
          context: context, screen: const NavigationHostPage());
      return;
    }
    Navigation.navigateToScreenAndClearAllPrevious(
      context: context,
      screen: const SignUpPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return
        // Container(
        //   height: double.infinity,
        //   width: double.infinity,
        //   decoration: BoxDecoration(
        //     image: DecorationImage(image: AppImages.splashBackground, fit: BoxFit.cover),
        //   ),
        // );
        Material(
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
            const SizedBox(height: 10),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.defaultColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TagLineText(text: 'Scan. '),
                TagLineText(text: 'Verify. '),
                TagLineText(text: 'Done.'),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class TagLineText extends StatelessWidget {
  const TagLineText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
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
