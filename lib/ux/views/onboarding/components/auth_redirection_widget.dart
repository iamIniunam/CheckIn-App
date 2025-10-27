import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/onboarding/login_page.dart';
import 'package:attendance_app/ux/views/onboarding/sign_up_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AuthRedirectionWidget extends StatelessWidget {
  const AuthRedirectionWidget({super.key, required this.isLogin});

  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: isLogin ? 'Don’t have an account? ' : 'Already have an account? ',
        style: const TextStyle(
            color: AppColors.defaultColor, fontFamily: 'Nunito', fontSize: 13),
        children: <TextSpan>[
          TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                isLogin
                    ? Navigation.navigateToScreenAndClearOnePrevious(
                        context: context,
                        screen: const SignUpPage(),
                      )
                    : Navigation.navigateToScreenAndClearOnePrevious(
                        context: context,
                        screen: const LoginPage(),
                      );
              },
            text: isLogin ? AppStrings.signUp : AppStrings.login,
            style: const TextStyle(
              color: AppColors.defaultColor,
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
