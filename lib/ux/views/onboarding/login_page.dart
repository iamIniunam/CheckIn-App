import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/sign_up_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  final formKey = GlobalKey<FormState>();

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  Future<void> handleLogin() async {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    if (!mounted) return;
    final viewModel = context.read<AuthViewModel>();

    AppDialogs.showLoadingDialog(context);
    bool success = false;

    success = await viewModel.login(
      idNumber: idNumberController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (success && mounted) {
      //TODO: remember to change to navigation host page when you finalize saving of selected courses
      Navigation.navigateToScreen(
          context: context, screen: const NavigationHostPage());
    }
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
      child: AbsorbPointer(
        absorbing: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AppImages.backgroundImage,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    AppColors.black.withOpacity(0.7), BlendMode.darken),
              ),
            ),
            child:
                Consumer<AuthViewModel>(builder: (context, authViewModel, _) {
              return Center(
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
                      child: Form(
                        key: formKey,
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
                              obscureText: !isPasswordVisible,
                              suffixWidget: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.defaultColor,
                                ),
                                onPressed: togglePasswordVisibility,
                              ),
                              bottomPadding: 0,
                            ),
                            const SizedBox(height: 30),
                            PrimaryButton(
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                handleLogin();
                              },
                              child: const Text(AppStrings.login),
                            ),
                            const SizedBox(height: 16),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'Don’t have an account? ',
                                style: const TextStyle(
                                    color: AppColors.defaultColor,
                                    fontFamily: 'Nunito',
                                    fontSize: 13),
                                children: <TextSpan>[
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigation.navigateToScreen(
                                            context: context,
                                            screen: const SignUpPage());
                                      },
                                    text: AppStrings.signUp,
                                    style: const TextStyle(
                                      color: AppColors.defaultColor,
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
