import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/components/app_dropdown_field.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/views/attendance/face_veification_page.dart';
import 'package:attendance_app/ux/views/onboarding/components/auth_redirection_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final idNumberController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  Future<void> handleSignUp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!validateForm()) return;

    final viewModel = context.read<AuthViewModel>();

    if (viewModel.isLoading && mounted) {
      AppDialogs.showLoadingDialog(context);
    }

    final success = await viewModel.signUp(
      idNumber: idNumberController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      program: '', //viewModel.selectedProgram,
      password: passwordController.text,
    );

    if (!mounted) return;

    dismissLoadingDialog();

    if (success) {
      Navigation.navigateToScreen(
        context: context,
        screen: const FaceVerificationPage(
          mode: FaceVerificationMode.signUp,
        ),
      );
    } else {
      AppDialogs.showErrorDialog(
        context: context,
        title: 'Sign Up Failed',
        message: viewModel.errorMessage ?? 'An unknown error occurred',
      );
    }
  }

  void dismissLoadingDialog() {
    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (_) {}
  }

  bool validateForm() {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    idNumberController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
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
          body: Consumer<AuthViewModel>(
            builder: (context, authViewModel, _) {
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
                        AppStrings.signUp,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
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
                                controller: idNumberController,
                                labelText: AppStrings.studentIdNumber,
                                keyboardType: TextInputType.visiblePassword,
                                hintText: AppStrings.idNumberHintText,
                                textInputAction: TextInputAction.next,
                                textCapitalization:
                                    TextCapitalization.characters,
                                bottomPadding: 0,
                              ),
                              PrimaryTextFormField(
                                controller: firstNameController,
                                labelText: 'First Name',
                                hintText: 'e.g John',
                                bottomPadding: 0,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                              ),
                              PrimaryTextFormField(
                                controller: lastNameController,
                                labelText: 'Last Name',
                                hintText: 'e.g Doe',
                                bottomPadding: 0,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                              ),
                              CustomSearchTextFormField(
                                labelText: 'Programs',
                                hintText: 'e.g BEng. Computer Engineering',
                                suggestions: AppConstants.programs
                                    .map((e) => SearchFieldListItem<dynamic>(e,
                                        child: Text(e)))
                                    .toList(),
                                onSuggestionTap: (suggestion) {
                                  // final selectedProgram = suggestion.searchKey;
                                  // viewModel.updateProgram(selectedProgram);
                                },
                              ),
                              PrimaryTextFormField(
                                controller: passwordController,
                                labelText: AppStrings.password,
                                hintText: AppStrings.enterAPassword,
                                obscureText: !isPasswordVisible,
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                suffixWidget: IconButton(
                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppColors.defaultColor,
                                  ),
                                  onPressed: togglePasswordVisibility,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                bottomPadding: 0,
                              ),
                              const SizedBox(height: 30),
                              PrimaryButton(
                                // enabled: viewModel.enableButton,
                                onTap: () {
                                  Navigation.navigateToScreen(
                                    context: context,
                                    screen: const FaceVerificationPage(
                                      mode: FaceVerificationMode.signUp,
                                    ),
                                  );
                                },
                                child: const Text(AppStrings.signUp),
                              ),
                              const SizedBox(height: 16),
                              const AuthRedirectionWidget(isLogin: false),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
