import 'package:attendance_app/ux/shared/components/global_functions.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models.dart/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

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
    try {
      await viewModel.saveDetailsToCache();

      if (mounted) {
        Navigation.navigateToFaceVerification(context: context);
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
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 18),
                      child: Text(
                        AppStrings.signUp,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 24, top: 30, right: 24, bottom: 40),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Consumer<AuthViewModel>(builder: (context, vm, _) {
                        return Column(
                          children: [
                            Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PrimaryTextFormField(
                                    labelText: AppStrings.studentIdNumber,
                                    keyboardType: TextInputType.visiblePassword,
                                    hintText: AppStrings.idNumberHintText,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    onChanged: (value) {
                                      vm.updateIDNumber(value);
                                    },
                                    errorText: vm.idNumber.isNotEmpty &&
                                            !vm.isIdNumberValid
                                        ? 'Invalid ID number format'
                                        : null,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: PrimaryTextFormField(
                                          labelText: AppStrings.level,
                                          keyboardType: TextInputType.number,
                                          hintText: AppStrings.levelHintText,
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
                                  ),
                                  const SizedBox(height: 20),
                                  PrimaryButton(
                                    enabled: vm.enableButton,
                                    onTap: handleSignUp,
                                    child: const Text(AppStrings.signUp),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
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
