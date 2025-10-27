import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/views/onboarding/login_page.dart';
import 'package:attendance_app/ux/views/profile/components/profile_detail_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // late UserViewModel userViewModel;
  // late CourseSearchViewModel searchViewModel;

  // @override
  // void initState() {
  //   super.initState();
  //   // userViewModel = context.read<UserViewModel>();
  //   // searchViewModel = context.read<CourseSearchViewModel>();
  // }

  // String getUserSchool() {
  //   String savedSchool = userViewModel.savedPrimarySchool;
  //   if (savedSchool.isNotEmpty) {
  //     return savedSchool;
  //   }

  //   String calculatedSchool =
  //       userViewModel.getUserPrimarySchool(searchViewModel.chosenSchools);
  //   return calculatedSchool;
  // }

  Future<void> handleLogout() async {
    final navigatorState = Navigator.of(context, rootNavigator: false);
    final authViewModel = context.read<AuthViewModel>();

    AppDialogs.showLoadingDialog(context);

    await Future.delayed(const Duration(milliseconds: 100));

    await authViewModel.logout();

    if (!mounted) return;

    try {
      navigatorState.pop();
    } catch (_) {}

    Navigation.navigateToScreen(
      context: context,
      screen: const LoginPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final semester = userViewModel.semester;

    // String semesterText;
    // if (semester == 1) {
    //   semesterText = '1st';
    // } else if (semester == 2) {
    //   semesterText = '2nd';
    // } else {
    //   semesterText = 'Unknown';
    // }

    final currentStudent = context.watch<AuthViewModel>().currentStudent;

    return AppPageScaffold(
      title: AppStrings.studentProfile,
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            // AppMaterial(
            //   customBorder: const CircleBorder(),
            //   child: CircleAvatar(
            //     radius: 80,
            //     backgroundColor: AppColors.defaultColor,
            //     foregroundColor: AppColors.transparent,
            //     backgroundImage: AppImages.defaultProfileImageTeal,
            //   ),
            // ),
            // const SizedBox(height: 16),
            // Text(
            //   userViewModel.fullName,
            //   style: const TextStyle(
            //       color: AppColors.defaultColor,
            //       fontSize: 24,
            //       fontWeight: FontWeight.bold),
            // ),
            // Text(
            //   userViewModel.program,
            //   style: const TextStyle(
            //       color: Colors.grey,
            //       fontSize: 18,
            //       fontWeight: FontWeight.w500),
            // ),
            // const SizedBox(height: 36),
            Container(
              padding: const EdgeInsets.only(
                  left: 36, top: 24, right: 36, bottom: 36),
              decoration: BoxDecoration(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.defaultColor)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileDetailItem(
                      title: AppStrings.firstName,
                      value: currentStudent?.firstName ?? 'N/A'),
                  ProfileDetailItem(
                      title: AppStrings.lastName,
                      value: currentStudent?.lastName ?? 'N/A'),
                  ProfileDetailItem(
                      title: AppStrings.idNumber,
                      value: currentStudent?.idNumber ?? 'N/A'),
                  ProfileDetailItem(
                    title: AppStrings.program,
                    value: currentStudent?.program ?? 'N/A',
                    textDirection: TextDirection.rtl,
                  ),
                  // ProfileDetailItem(
                  //     title: AppStrings.studentLevel,
                  //     value: 'Level ${userViewModel.level}'),
                  // ProfileDetailItem(
                  //     title: AppStrings.currentSemester,
                  //     value: '$semesterText Semester'),
                  // ProfileDetailItem(
                  //     title: AppStrings.school, value: getUserSchool()),
                ],
              ),
            ),
            const Spacer(),
            // Logout button pinned to the bottom
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: PrimaryButton(
                backgroundColor: AppColors.transparent,
                foregroundColor: AppColors.red500,
                overlayColor: AppColors.red500.withOpacity(0.05),
                onTap: handleLogout,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 20),
                    SizedBox(width: 4),
                    Text('Logout'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
