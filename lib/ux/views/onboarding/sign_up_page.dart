import 'package:attendance_app/platform/data_source/api/auth/models/auth_request.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/components/app_dropdown_field.dart';
import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/components/back_and_next_button_row.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/views/attendance/components/padded_column.dart';
import 'package:attendance_app/ux/views/attendance/components/page_indicator.dart';
import 'package:attendance_app/ux/views/course/course_enrollment_page.dart';
import 'package:attendance_app/ux/views/onboarding/components/auth_redirection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthViewModel authViewModel = AppDI.getIt<AuthViewModel>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String? selectedProgram;

  bool isPasswordObscured = true;
  bool isConfirmPasswordObscured = true;

  void togglePasswordVisibility() {
    setState(() {
      isPasswordObscured = !isPasswordObscured;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      isConfirmPasswordObscured = !isConfirmPasswordObscured;
    });
  }

  int currentIndex = 0;

  void handleSignUpResult() {
    final result = authViewModel.signUpResult.value;
    if (result.isSuccess) {
      Navigation.navigateToScreenAndClearOnePrevious(
          context: context, screen: const CourseEnrollmentPage());
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
    if (idNumberController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        selectedProgram == null) {
      AppDialogs.showErrorDialog(
        context: context,
        message: 'Please fill in all fields.',
      );
      return;
    }
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      AppDialogs.showErrorDialog(
        context: context,
        message: 'Passwords do not match. Please try again.',
      );
      return;
    }
    AppDialogs.showLoadingDialog(context);
    final request = SignUpRequest(
      idNumber: idNumberController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      program: selectedProgram ?? '',
      password: passwordController.text.trim(),
    );
    await authViewModel.signUp(signUpRequest: request);
    if (!mounted) return;
    Navigation.back(context: context);
    handleSignUpResult();
  }

  @override
  void dispose() {
    idNumberController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      hideAppBar: true,
      useSafeArea: false,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.30,
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
                  const SizedBox(height: 12),
                  const Text(
                    AppStrings.signUp,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.defaultColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: PageIndicator(index: currentIndex, length: 3),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (currentIndex == 0) ...[
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
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                        if (currentIndex == 1) ...[
                          PrimaryTextFormField(
                            controller: idNumberController,
                            labelText: AppStrings.studentIdNumber,
                            keyboardType: TextInputType.visiblePassword,
                            hintText: AppStrings.idNumberHintText,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.characters,
                            bottomPadding: 0,
                          ),
                          AppDropdownField(
                            labelText: 'Programs',
                            hintText: 'e.g BEng. Computer Engineering',
                            items: AppConstants.programs,
                            valueHolder: selectedProgram,
                            onChanged: (value) {
                              setState(() {
                                selectedProgram = value;
                              });
                            },
                          ),
                        ],
                        if (currentIndex == 2) ...[
                          PrimaryTextFormField(
                            controller: passwordController,
                            labelText: AppStrings.password,
                            hintText: AppStrings.enterAPassword,
                            obscureText: isPasswordObscured,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.next,
                            suffixWidget: IconButton(
                              icon: Icon(
                                isPasswordObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.defaultColor,
                              ),
                              onPressed: togglePasswordVisibility,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'\s')), // ✅ Blocks all whitespace
                            ],
                            bottomPadding: 0,
                          ),
                          PrimaryTextFormField(
                            controller: confirmPasswordController,
                            labelText: AppStrings.confirmPassword,
                            hintText: AppStrings.reenterYourPassword,
                            obscureText: isConfirmPasswordObscured,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            suffixWidget: IconButton(
                              icon: Icon(
                                isConfirmPasswordObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.defaultColor,
                              ),
                              onPressed: toggleConfirmPasswordVisibility,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'\s')), // ✅ Blocks all whitespace
                            ],
                            bottomPadding: 0,
                          ),
                        ]
                      ],
                    ),
                  ),
                  Visibility(
                    visible: currentIndex < 1,
                    replacement: BackAndNextButtonRow(
                      hasBottomPadding: true,
                      secondText: currentIndex == 2 ? 'Sign Up' : 'Continue',
                      onTapFirstButton: () {
                        setState(() {
                          currentIndex--;
                        });
                      },
                      onTapNextButton: () {
                        if (currentIndex < 2) {
                          if (idNumberController.text.trim().isEmpty ||
                              (selectedProgram?.trim().isEmpty ?? true)) {
                            AppDialogs.showErrorDialog(
                              context: context,
                              message: 'Please fill in all fields.',
                            );
                            return;
                          }
                          setState(() {
                            currentIndex++;
                          });
                        } else {
                          handleSignUp();
                        }
                      },
                    ),
                    child: PaddedColumn(
                      padding: const EdgeInsets.only(
                          left: 16, top: 16, right: 16, bottom: 24),
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PrimaryButton(
                          onTap: () {
                            if (firstNameController.text.trim().isEmpty ||
                                lastNameController.text.trim().isEmpty) {
                              AppDialogs.showErrorDialog(
                                context: context,
                                message: 'Please fill in all fields.',
                              );
                              return;
                            }
                            setState(() {
                              currentIndex++;
                            });
                          },
                          child: const Text('Continue'),
                        ),
                        const SizedBox(height: 16),
                        const AuthRedirectionWidget(isLogin: false)
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
  }
}
