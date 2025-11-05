import 'package:attendance_app/platform/data_source/api/auth/models/auth_request.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
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
import 'package:attendance_app/ux/views/attendance/face_verification_page.dart';
import 'package:attendance_app/ux/views/onboarding/components/auth_redirection_widget.dart';
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthViewModel authViewModel = AppDI.getIt<AuthViewModel>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedProgram;

  bool isPasswordObscured = true;

  void togglePasswordVisibility() {
    setState(() {
      isPasswordObscured = !isPasswordObscured;
    });
  }

  void handleSignUpResult() {
    final result = authViewModel.signUpResult.value;

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
        screen: const FaceVerificationPage(
          mode: FaceVerificationMode.signUp,
        ),
      );
    } else if (result.isError) {
      final errorMessage = result.message ??
          'Sign Up failed. Please check your details and try again.';
      AppDialogs.showErrorDialog(
        context: context,
        title: 'Sign Up Failed',
        message: errorMessage,
      );
    }
  }

  Future<void> handleSignUp() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }
    final request = SignUpRequest(
      idNumber: idNumberController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      program: selectedProgram ?? '',
      password: passwordController.text,
    );
    await authViewModel.signUp(signUpRequest: request);
    if (!mounted) return;
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
          body: ValueListenableBuilder(
            valueListenable: authViewModel.signUpResult,
            builder: (context, result, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                handleSignUpResult();
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
                          key: _formKey,
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your student ID number';
                                  }
                                  return null;
                                },
                              ),
                              PrimaryTextFormField(
                                controller: firstNameController,
                                labelText: 'First Name',
                                hintText: 'e.g John',
                                bottomPadding: 0,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                  return null;
                                },
                              ),
                              PrimaryTextFormField(
                                controller: lastNameController,
                                labelText: 'Last Name',
                                hintText: 'e.g Doe',
                                bottomPadding: 0,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your last name';
                                  }
                                  return null;
                                },
                              ),
                              CustomSearchTextFormField(
                                labelText: 'Programs',
                                hintText: 'e.g BEng. Computer Engineering',
                                suggestions: AppConstants.programs
                                    .map((e) => SearchFieldListItem<dynamic>(e,
                                        child: Text(e)))
                                    .toList(),
                                onSuggestionTap: (suggestion) {
                                  final program = suggestion.searchKey;
                                  setState(() {
                                    selectedProgram = program;
                                  });
                                },
                                validator: (value) {
                                  if (selectedProgram == null ||
                                      (selectedProgram ?? '').isEmpty) {
                                    return 'Please select a program';
                                  }
                                  return null;
                                },
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
                                onTap: handleSignUp,
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
