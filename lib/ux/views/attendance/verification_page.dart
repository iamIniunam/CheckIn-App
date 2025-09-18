// // ignore_for_file: unused_field, use_build_context_synchronously, avoid_print

// import 'package:attendance_app/ux/shared/resources/app_buttons.dart';
// import 'package:attendance_app/ux/shared/resources/app_colors.dart';
// import 'package:attendance_app/ux/shared/resources/app_form_fields.dart';
// import 'package:attendance_app/ux/shared/components/global_functions.dart';
// import 'package:attendance_app/ux/navigation/navigation.dart';
// import 'package:attendance_app/ux/shared/resources/app_images.dart';
// import 'package:attendance_app/ux/shared/resources/app_strings.dart';
// import 'package:attendance_app/ux/views/attendance/verification_success_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class VerificationPage extends StatefulWidget {
//   const VerificationPage({super.key});

//   @override
//   State<VerificationPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<VerificationPage> {
//   final _auth = FirebaseAuth.instance;

//   final TextEditingController idNumberController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   bool isPasswordVisible = false;
//   bool showSpinner = false;

//   late String password;
//   late String email;

//   final formKey = GlobalKey<FormState>();

//   void togglePasswordVisibility() {
//     setState(() {
//       isPasswordVisible = !isPasswordVisible;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusManager.instance.primaryFocus?.unfocus();
//       },
//       child: AbsorbPointer(
//         absorbing: false, //this hides the keyboard anytime the screen is tapped
//         child: Scaffold(
//           resizeToAvoidBottomInset:
//               false, //this stops the background image from moving anytime the keyboard is initiated
//           body: ModalProgressHUD(
//             inAsyncCall: showSpinner,
//             child: Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AppImages.backgroundImage,
//                   fit: BoxFit.cover,
//                   colorFilter: ColorFilter.mode(
//                       Colors.black.withOpacity(0.7), BlendMode.darken),
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 24, right: 24),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.only(bottom: 18),
//                       child: Text(
//                         'You came to class huh?',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 45,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.only(
//                           left: 24, top: 30, right: 24, bottom: 40),
//                       decoration: BoxDecoration(
//                         color: AppColors.white,
//                         borderRadius: BorderRadius.circular(28),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             "Let's verify that",
//                             style: TextStyle(
//                               color: AppColors.defaultColor,
//                               fontSize: 30,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           Form(
//                             key: formKey,
//                             child: Column(
//                               children: [
//                                 PrimaryTextFormField(
//                                     labelText: AppStrings.studentIdNumber,
//                                     controller: idNumberController,
//                                     keyboardType: TextInputType.visiblePassword,
//                                     hintText: AppStrings.sampleIdNumber,
//                                     textInputAction: TextInputAction.next,
//                                     textCapitalization:
//                                         TextCapitalization.characters),
//                                 // PrimaryTextFormField(
//                                 //   labelText: AppStrings.schoolEmail,
//                                 //   controller: emailController,
//                                 //   keyboardType: TextInputType.emailAddress,
//                                 //   hintText: AppStrings.studentEmailHint,
//                                 //   textInputAction: TextInputAction.next,
//                                 // ),
//                                 PrimaryTextFormField(
//                                   labelText: AppStrings.password,
//                                   hintText: AppStrings.enterYourPassword,
//                                   controller: passwordController,
//                                   keyboardType: TextInputType.visiblePassword,
//                                   textInputAction: TextInputAction.done,
//                                   obscureText: !isPasswordVisible,
//                                   onChanged: (value) {
//                                     setState(() {
//                                       password = value;
//                                     });
//                                   },
//                                   suffixWidget: IconButton(
//                                     icon: Icon(
//                                       isPasswordVisible
//                                           ? Icons.visibility
//                                           : Icons.visibility_off,
//                                       color: AppColors.defaultColor,
//                                     ),
//                                     onPressed: togglePasswordVisibility,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 20),
//                                 PrimaryButton(
//                                   backgroundColor: Colors.blueGrey.shade900,
//                                   onTap: () async {
//                                     setState(() {
//                                       showSpinner = true;
//                                     });

//                                     //check if email entered is a school email
//                                     if (isSchoolEmail(emailController.text) ==
//                                         false) {
//                                       setState(() {
//                                         showSpinner = false;
//                                       });
//                                       showAlert(
//                                           context: context,
//                                           title: 'Invalid Email',
//                                           desc:
//                                               'Please enter a valid AIT email address');
//                                       return;
//                                     }

//                                     //confirm email entered is the same as the email used to sign up
//                                     SharedPreferences prefs =
//                                         await SharedPreferences.getInstance();
//                                     var email = prefs.getString('email');
//                                     if (email != emailController.text) {
//                                       setState(() {
//                                         showSpinner = false;
//                                       });
//                                       showAlert(
//                                           context: context,
//                                           title: 'Email mismatch',
//                                           desc:
//                                               'The email you entered does not match the email you signed up with');
//                                       return;
//                                     }

//                                     try {
//                                       await _auth.signInWithEmailAndPassword(
//                                           email: emailController.text,
//                                           password: passwordController.text);
//                                       FocusManager.instance.primaryFocus
//                                           ?.unfocus();
//                                       Navigation.navigateToScreen(
//                                           context: context,
//                                           screen:
//                                               const VerificationSuccessPage());
//                                       setState(() {
//                                         showSpinner = false;
//                                       });
//                                     } catch (e) {
//                                       setState(() {
//                                         showSpinner = false;
//                                       });
//                                       showAlert(
//                                         context: context,
//                                         title: 'Verification failed',
//                                         desc: 'Incorrect password',
//                                       );
//                                       print(e);
//                                     }
//                                   },
//                                   child: const Text('Verify'),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
