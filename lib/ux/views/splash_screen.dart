import 'dart:async';

import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models.dart/auth_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/sign_up_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController logoController;
  late Animation<double> logoScale;
  late Animation<double> logoOpacity;
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;

  bool showFirstWord = false;
  bool showSecondWord = false;
  bool showThirdWord = false;

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  void initializeApp() {
    //Logo animation
    logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));

    logoScale = Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: logoController, curve: Curves.easeOut));
    logoOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: logoController, curve: Curves.easeIn));
    logoController.forward();

    //Fade animation for app name
    fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
    fadeAnimation =
        CurvedAnimation(parent: fadeController, curve: Curves.easeIn);
    Future.delayed(const Duration(milliseconds: 1800), () {
      fadeController.forward();
    });

    //Tagline reveal timing
    Future.delayed(const Duration(milliseconds: 3200), () {
      setState(() {
        showFirstWord = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 4000), () {
      setState(() {
        showSecondWord = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 4800), () {
      setState(() {
        showThirdWord = true;
      });
    });

    // Navigate to destination
    Timer(
      const Duration(milliseconds: 5400),
      () async {
        if (!mounted) return;
        await checkUserStatusAndNavigate();
      },
    );
  }

  Future<void> checkUserStatusAndNavigate() async {
    try {
      final isSignedUp = await AuthViewModel.isUserSignedUp();

      if (!mounted) return;

      if (isSignedUp) {
        Navigation.navigateToScreenAndClearOnePrevious(
            context: context, screen: const NavigationHostPage());
      } else {
        Navigation.navigateToScreenAndClearOnePrevious(
            context: context, screen: const SignUpPage());
      }
    } catch (e) {
      if (!mounted) return;
      Navigation.navigateToScreenAndClearOnePrevious(
          context: context, screen: const SignUpPage());
    }
  }

  @override
  void dispose() {
    logoController.dispose();
    fadeController.dispose();
    super.dispose();
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
            ScaleTransition(
              scale: logoScale,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AppImages.appLogoIos),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            // SizedBox(
            //   height: 120,
            //   width: 120,
            //   child: Image(image: AppImages.appLogo),
            // ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: fadeAnimation,
              child: const Text(
                AppStrings.appName,
                style: TextStyle(
                  color: AppColors.defaultColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                taglineText(text: 'Scan. ', opacity: showFirstWord ? 1 : 0),
                taglineText(text: 'Verify. ', opacity: showSecondWord ? 1 : 0),
                taglineText(text: 'Done.', opacity: showThirdWord ? 1 : 0),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget taglineText({required String text, required double opacity}) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 400),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.defaultColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
