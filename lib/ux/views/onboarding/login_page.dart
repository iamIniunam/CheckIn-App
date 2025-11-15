import 'package:attendance_app/platform/data_source/api/auth/models/auth_request.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/components/auth_redirection_widget.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthViewModel authViewModel = AppDI.getIt<AuthViewModel>();

  TextEditingController idNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isPasswordObscured = true;

  void togglePasswordVisibility() {
    setState(() {
      isPasswordObscured = !isPasswordObscured;
    });
  }

  void handleLoginResult() {
    final result = authViewModel.loginResult.value;

    if (result.isLoading) {
      AppDialogs.showLoadingDialog(context);
      return;
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (result.isSuccess) {
      Navigation.navigateToScreenAndClearOnePrevious(
        context: context,
        screen: const NavigationHostPage(),
      );
    } else if (result.isError) {
      final errorMessage = result.message ??
          'Login failed. Please check your credentials and try again.';
      AppDialogs.showErrorDialog(
        context: context,
        message: errorMessage,
      );
    }
  }

  Future<void> handleLogin() async {
    if (idNumberController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      AppDialogs.showErrorDialog(
        context: context,
        message: 'Please enter both ID number and password.',
      );
      return;
    }
    final request = LoginRequest(
      idNumber: idNumberController.text.trim(),
      password: passwordController.text.trim(),
    );

    await authViewModel.login(loginRequest: request);
    if (!mounted) return;
  }

  @override
  void dispose() {
    idNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: ValueListenableBuilder(
          valueListenable: authViewModel.loginResult,
          builder: (context, result, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              handleLoginResult();
            });

            return DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AppImages.backgroundImage,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      AppColors.black.withOpacity(0.7), BlendMode.darken),
                ),
              ),
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  children: [
                    const Text(
                      AppStrings.login,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 24, top: 30, right: 24, bottom: 30),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          PrimaryTextFormField(
                            labelText: AppStrings.studentIdNumber,
                            controller: idNumberController,
                            keyboardType: TextInputType.visiblePassword,
                            hintText: AppStrings.sampleIdNumber,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.characters,
                            bottomPadding: 0,
                          ),
                          PrimaryTextFormField(
                            labelText: AppStrings.password,
                            hintText: AppStrings.enterYourPassword,
                            controller: passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            obscureText: isPasswordObscured,
                            suffixWidget: IconButton(
                              icon: Icon(
                                isPasswordObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.defaultColor,
                              ),
                              onPressed: togglePasswordVisibility,
                            ),
                            bottomPadding: 0,
                          ),
                          const SizedBox(height: 30),
                          PrimaryButton(
                            onTap: handleLogin,
                            child: const Text(AppStrings.login),
                          ),
                          const SizedBox(height: 16),
                          const AuthRedirectionWidget(isLogin: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
