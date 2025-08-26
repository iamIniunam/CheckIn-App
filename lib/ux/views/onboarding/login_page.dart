import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/resources/app_buttons.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_form_fields.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  String password = '';

  final formKey = GlobalKey<FormState>();

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
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
          body: Container(
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
                      AppStrings.login,
                      style: TextStyle(
                        color: Colors.white,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // const Text(
                        //   AppStrings.login,
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
                            children: [
                                PrimaryTextFormField(
                                  labelText: AppStrings.studentIdNumber,
                                  controller: idNumberController,
                                  keyboardType: TextInputType.visiblePassword,
                                  hintText: AppStrings.sampleIdNumber,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.characters
                                ),
                              // PrimaryTextFormField(
                              //   labelText: AppStrings.schoolEmail,
                              //   controller: emailController,
                              //   keyboardType: TextInputType.emailAddress,
                              //   hintText: AppStrings.studentEmailHint,
                              //   textInputAction: TextInputAction.next,
                              // ),
                              PrimaryTextFormField(
                                labelText: AppStrings.password,
                                hintText: AppStrings.enterYourPassword,
                                controller: passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                obscureText: !isPasswordVisible,
                                onChanged: (value) {
                                  setState(() {
                                    password = value;
                                  });
                                },
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
                              const SizedBox(height: 20),
                              PrimaryButton(
                                onTap: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  Navigation.navigateToScreen(
                                      context: context,
                                      screen: const NavigationHostPage());
                                },
                                child: const Text(AppStrings.login),
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
    );
  }
}
