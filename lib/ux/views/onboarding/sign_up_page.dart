// ignore_for_file: unused_field, use_build_context_synchronously, avoid_print

import 'package:attendance_app/platform/providers/student_info_provider.dart';
import 'package:attendance_app/ux/shared/components/global_functions.dart';
import 'package:attendance_app/ux/shared/resources/app_buttons.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_form_fields.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/attendance/face_verification_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:attendance_app/ux/shared/components/global_functions.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuth.instance;

  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool showSpinner = false;

  final formKey = GlobalKey<FormState>();

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      isConfirmPasswordVisible = !isConfirmPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus
            ?.unfocus(); //this hides the keyboard anytime the screen is tapped
      },
      child: AbsorbPointer(
        absorbing: false,
        child: Scaffold(
          resizeToAvoidBottomInset:
              false, //this stops the background image from moving anytime the keyboard is initiated
          body: ModalProgressHUD(
            inAsyncCall: showSpinner,
            child: Container(
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
                      child: Column(
                        children: [
                          // const Text(
                          //   AppStrings.signUp,
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //     color: AppColors.defaultColor,
                          //     fontSize: 30,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          // const SizedBox(height: 20),
                          Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PrimaryTextFormField(
                                    labelText: AppStrings.studentIdNumber,
                                    controller: idNumberController,
                                    keyboardType: TextInputType.visiblePassword,
                                    hintText: AppStrings.idNumberHintText,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.characters),
                                Row(
                                  children: [
                                    Expanded(
                                      child: PrimaryTextFormField(
                                          labelText: AppStrings.level,
                                          controller: levelController,
                                          keyboardType: TextInputType.number,
                                          hintText: AppStrings.levelHintText,
                                          textInputAction:
                                              TextInputAction.next),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: PrimaryTextFormField(
                                          labelText: AppStrings.semester,
                                          controller: semesterController,
                                          keyboardType: TextInputType.number,
                                          hintText: AppStrings.semesterHintText,
                                          textInputAction:
                                              TextInputAction.next),
                                    ),
                                  ],
                                ),
                                PrimaryTextFormField(
                                  labelText: AppStrings.password,
                                  hintText: AppStrings.enterAPassword,
                                  obscureText: !isPasswordVisible,
                                  controller: passwordController,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.next,
                                  suffixWidget: IconButton(
                                    icon: Icon(
                                      isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.defaultColor,
                                    ),
                                    onPressed: togglePasswordVisibility,
                                  ),
                                ),
                                PrimaryTextFormField(
                                  labelText: AppStrings.confirmPassword,
                                  hintText: AppStrings.reenterYourPassword,
                                  obscureText: !isConfirmPasswordVisible,
                                  controller: confirmPasswordController,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.done,
                                  suffixWidget: IconButton(
                                    icon: Icon(
                                      isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.defaultColor,
                                    ),
                                    onPressed: toggleConfirmPasswordVisibility,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                PrimaryButton(
                                  // enabled: false,
                                  onTap: () async {
                                    //check if email entered is a school email
                                    // if (isSchoolEmail(emailController.text) ==
                                    //     false) {
                                    //   setState(() {
                                    //     showSpinner = false;
                                    //   });
                                    //   showAlert(
                                    //       context: context,
                                    //       title: AppStrings.invalidEmail,
                                    //       desc: AppStrings
                                    //           .pleaseEnterAValidAitEmailAdd);
                                    //   return;
                                    // }

                                    // if (passwordController.text !=
                                    //     confirmPasswordController.text) {
                                    //   showAlert(
                                    //     context: context,
                                    //     title: AppStrings.signUpFailed,
                                    //     desc: AppStrings.passwordsDoNotMatch,
                                    //   );
                                    //   return;
                                    // }
                                    // setState(() {
                                    //   showSpinner = true;
                                    // });
                                    // try {
                                    //   await _auth
                                    //       .createUserWithEmailAndPassword(
                                    //           email: emailController.text,
                                    //           password:
                                    //               passwordController.text);
                                    //   FocusManager.instance.primaryFocus
                                    //       ?.unfocus();
                                    //   //saves data on device and making the sign up page not to show once
                                    //   //a user has signed up already(keeping the user signed in)
                                    //   SharedPreferences prefs =
                                    //       await SharedPreferences.getInstance();
                                    //   prefs.setString(
                                    //       'email', emailController.text);
                                    //   prefs.setBool('isLoggedIn', true);

                                    final idNumber =
                                        idNumberController.text.trim();
                                    final level = levelController.text.trim();
                                    final semester =
                                        semesterController.text.trim();

                                    context
                                        .read<StudentInfoProvider>()
                                        .setStudentInfo(
                                            idNumber: idNumber,
                                            level: level,
                                            semester: semester);

                                    Navigation
                                        .navigateToScreenAndClearAllPrevious(
                                            context: context,
                                            screen: const FaceVerificationPage(
                                              mode: FaceVerificationMode.signUp,
                                            ));
                                    //     setState(() {
                                    //       showSpinner = false;
                                    //     });
                                    //   } catch (e) {
                                    //     setState(() {
                                    //       showSpinner = false;
                                    //     });
                                    //     showAlert(
                                    //       context: context,
                                    //       title: AppStrings.signUpFailed,
                                    //       desc: e.toString(),
                                    //     );
                                    //     print(e);
                                    //   }
                                  },
                                  child: const Text(AppStrings.signUp),
                                ),
                              ],
                            ),
                          ),
                        ],
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
