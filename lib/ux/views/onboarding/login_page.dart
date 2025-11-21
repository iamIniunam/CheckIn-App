import 'package:attendance_app/platform/data_source/api/auth/models/auth_request.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
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
    if (result.isSuccess) {
      Navigation.navigateToHomePage(context: context);
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
    AppDialogs.showLoadingDialog(context);
    final request = LoginRequest(
      idNumber: idNumberController.text.trim(),
      password: passwordController.text.trim(),
    );

    await authViewModel.login(loginRequest: request);
    if (!mounted) return;
    Navigation.back(context: context);
    handleLoginResult();
  }

  @override
  void dispose() {
    idNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      hideAppBar: true,
      useSafeArea: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.33,
            alignment: Alignment.center,
            color: AppColors.defaultColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AppImages.appLogo,
                  fit: BoxFit.cover,
                  height: 120,
                  width: 120,
                ),
                const Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.white,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          AppStrings.login,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.defaultColor,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        PrimaryTextFormField(
                          controller: idNumberController,
                          labelText: AppStrings.studentIdNumber,
                          keyboardType: TextInputType.visiblePassword,
                          hintText: AppStrings.idNumberHintText,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.characters,
                          bottomPadding: 0,
                        ),
                        PrimaryTextFormField(
                          controller: passwordController,
                          labelText: AppStrings.password,
                          hintText: AppStrings.enterAPassword,
                          obscureText: isPasswordObscured,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: PrimaryButton(
                      onTap: handleLogin,
                      child: const Text(AppStrings.login),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 24),
                    child: AuthRedirectionWidget(isLogin: true),
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
