import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/components/app_dropdown_field.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/login_page.dart';
import 'package:flutter/gestures.dart';
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
  final passwordController = TextEditingController();
  final levelController = TextEditingController();
  final semesterController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  // Future<void> handleSignUp() async {
  //   final formState = formKey.currentState;
  //   if (formState == null || !formState.validate()) {
  //     return;
  //   }

  //   if (!mounted) return;
  //   final viewModel = context.read<AuthViewModel>();

  //   AppDialogs.showLoadingDialog(context);
  //   bool success = false;

  //   success = await viewModel.login(
  //     idNumber: idNumberController.text.trim(),
  //     password: passwordController.text.trim(),
  //     level: levelController.text.trim(),
  //     semester: int.tryParse(semesterController.text.trim()) ?? 0,
  //   );

  //   if (success && mounted) {
  //     Navigation.navigateToFaceVerification(context: context);
  //   }
  // }

  @override
  void dispose() {
    idNumberController.dispose();
    passwordController.dispose();
    levelController.dispose();
    semesterController.dispose();
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
                                labelText: AppStrings.studentIdNumber,
                                controller: idNumberController,
                                keyboardType: TextInputType.visiblePassword,
                                hintText: AppStrings.idNumberHintText,
                                textInputAction: TextInputAction.next,
                                textCapitalization:
                                    TextCapitalization.characters,
                                bottomPadding: 0,
                                // onChanged: (value) {
                                //   viewModel.updateIDNumber(value);
                                // },
                                // errorText: viewModel.idNumber.isNotEmpty &&
                                //         !viewModel.isIdNumberValid
                                //     ? 'Invalid ID number format'
                                //     : null,
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
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       child: PrimaryTextFormField(
                              //         labelText: AppStrings.level,
                              //         keyboardType: TextInputType.number,
                              //         controller: levelController,
                              //         hintText: AppStrings.levelHintText,
                              //         bottomPadding: 0,
                              //         textInputAction: TextInputAction.next,
                              //         // onChanged: (value) {
                              //         //   viewModel.updateLevel(value);
                              //         // },
                              //         // errorText: viewModel.level.isNotEmpty &&
                              //         //         !viewModel.isLevelValid
                              //         //     ? 'Between 100 - 400'
                              //         //     : null,
                              //       ),
                              //     ),
                              //     const SizedBox(width: 10),
                              //     Expanded(
                              //       child: PrimaryTextFormField(
                              //         labelText: AppStrings.semester,
                              //         keyboardType: TextInputType.number,
                              //         controller: semesterController,
                              //         bottomPadding: 0,
                              //         hintText: AppStrings.semesterHintText,
                              //         textInputAction: TextInputAction.next,
                              //         // onChanged: (value) {
                              //         //   viewModel.updateSemester(
                              //         //       int.tryParse(value) ?? 0);
                              //         // },
                              //         // errorText: viewModel.semester.isNotEmpty &&
                              //         //         !viewModel.isSemesterValid
                              //         //     ? 'Enter 1 or 2'
                              //         //     : null,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              PrimaryTextFormField(
                                labelText: AppStrings.password,
                                hintText: AppStrings.enterAPassword,
                                controller: passwordController,
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
                                // onChanged: (value) {
                                //   viewModel.updatePassword(value);
                                // },
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
                              const PrimaryButton(
                                // enabled: viewModel.enableButton,
                                onTap:
                                    // authViewModel.isLoading
                                    //     ?
                                    null,
                                // : handleSignUp,
                                child: Text(AppStrings.signUp),
                              ),

                              const SizedBox(height: 16),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: 'Already have an account? ',
                                  style: const TextStyle(
                                    color: AppColors.defaultColor,
                                    fontFamily: 'Nunito',
                                    fontSize: 13,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigation.navigateToScreen(
                                              context: context,
                                              screen: const LoginPage());
                                        },
                                      text: AppStrings.login,
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
