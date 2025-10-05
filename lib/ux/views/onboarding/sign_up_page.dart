import 'package:attendance_app/ux/shared/components/app_dropdown_field.dart';
import 'package:attendance_app/ux/shared/components/global_functions.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late AuthViewModel viewModel;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    viewModel = context.read<AuthViewModel>();
  }

  bool isPasswordVisible = false;
  bool showSpinner = false;

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  Future<void> handleSignUp() async {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      showSpinner = false;
    });

    try {
      final success = await viewModel.saveDetailsToCache();

      if (mounted) {
        setState(() {
          showSpinner = false;
        });

        if (success) {
          Navigation.navigateToFaceVerification(context: context);
        } else {
          showAlert(
            context: context,
            title: AppStrings.signUpFailed,
            desc: 'Failed to save user details. Please try again.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
        showAlert(
          context: context,
          title: AppStrings.signUpFailed,
          desc: e.toString(),
        );
      }
    }
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
          body: ModalProgressHUD(
            inAsyncCall: showSpinner,
            child: DecoratedBox(
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
                          left: 24, top: 30, right: 24, bottom: 40),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Consumer<AuthViewModel>(
                        builder: (context, vm, _) {
                          return Form(
                            key: formKey,
                            child: Column(
                              children: [
                                PrimaryTextFormField(
                                  labelText: AppStrings.studentIdNumber,
                                  keyboardType: TextInputType.visiblePassword,
                                  hintText: AppStrings.idNumberHintText,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  bottomPadding: 0,
                                  onChanged: (value) {
                                    vm.updateIDNumber(value);
                                  },
                                  errorText: vm.idNumber.isNotEmpty &&
                                          !vm.isIdNumberValid
                                      ? 'Invalid ID number format'
                                      : null,
                                ),
                                CustomSearchTextFormField(
                                  labelText: 'Programs',
                                  hintText: 'e.g BEng. Computer Engineering',
                                  suggestions: AppConstants.programs
                                      .map((e) => SearchFieldListItem<dynamic>(
                                          e,
                                          child: Text(e)))
                                      .toList(),
                                  onSuggestionTap: (suggestion) {
                                    final selectedProgram =
                                        suggestion.searchKey;
                                    vm.updateProgram(selectedProgram);
                                  },
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: PrimaryTextFormField(
                                        labelText: AppStrings.level,
                                        keyboardType: TextInputType.number,
                                        hintText: AppStrings.levelHintText,
                                        bottomPadding: 0,
                                        textInputAction: TextInputAction.next,
                                        onChanged: (value) {
                                          viewModel.updateLevel(value);
                                        },
                                        errorText: vm.level.isNotEmpty &&
                                                !vm.isLevelValid
                                            ? 'Between 100 - 400'
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: PrimaryTextFormField(
                                        labelText: AppStrings.semester,
                                        keyboardType: TextInputType.number,
                                        bottomPadding: 0,
                                        hintText: AppStrings.semesterHintText,
                                        textInputAction: TextInputAction.next,
                                        onChanged: (value) {
                                          viewModel.updateSemester(value);
                                        },
                                        errorText: vm.semester.isNotEmpty &&
                                                !vm.isSemesterValid
                                            ? 'Enter 1 or 2'
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                PrimaryTextFormField(
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
                                  onChanged: (value) {
                                    viewModel.updatePassword(value);
                                  },
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
                                const SizedBox(height: 20),
                                PrimaryButton(
                                  enabled: vm.enableButton,
                                  onTap: handleSignUp,
                                  child: const Text(AppStrings.signUp),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
