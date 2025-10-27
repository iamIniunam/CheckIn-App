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
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController idNumberController;
  late final TextEditingController passwordController;
  late final GlobalKey<FormState> formKey;

  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    idNumberController = TextEditingController();
    passwordController = TextEditingController();
    formKey = GlobalKey<FormState>();
  }

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  Future<void> handleLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!validateForm()) return;

    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final viewModel = context.read<AuthViewModel>();

      // Show a loading dialog while the login request is in progress.
      var showedLoading = false;
      try {
        AppDialogs.showLoadingDialog(context);
        showedLoading = true;

        final success = await viewModel.login(
          idNumber: idNumberController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (!mounted) return;

        if (showedLoading) {
          try {
            dismissLoadingDialog();
          } catch (_) {}
        }

        if (success) {
          handleLoginSuccess();
        } else {
          handleLoginError(viewModel);
        }
      } finally {
        // Ensure we don't leave the loading dialog shown on error
        if (showedLoading) {
          try {
            dismissLoadingDialog();
          } catch (_) {}
        }
      }
    } catch (e) {
      if (!mounted) return;
      try {
        dismissLoadingDialog();
      } catch (_) {}
      showErrorDialog('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  bool validateForm() {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      return false;
    }
    return true;
  }

  void dismissLoadingDialog() {
    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (_) {}
  }

  void handleLoginSuccess() {
    Navigation.navigateToScreenAndClearOnePrevious(
      context: context,
      screen: const NavigationHostPage(),
    );
  }

  void handleLoginError(AuthViewModel viewModel) {
    final errorMessage = viewModel.errorMessage ??
        'Login failed. Please check your credentials and try again.';

    showErrorDialog(errorMessage);
  }

  void showErrorDialog(String message) {
    AppDialogs.showErrorDialog(
      context: context,
      message: message,
    );
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
            child: Consumer<AuthViewModel>(
              builder: (context, authViewModel, _) {
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
                                textCapitalization:
                                    TextCapitalization.characters,
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
                                onTap: handleLogin,
                                child: const Text(AppStrings.login),
                              ),
                              const SizedBox(height: 16),
                              const AuthRedirectionWidget(isLogin: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
