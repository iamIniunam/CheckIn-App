import 'package:attendance_app/platform/di/dependency_injection.dart';
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthViewModel authViewModel = AppDI.getIt<AuthViewModel>();

  Future<void> handleLogout() async {
    final navigatorState = Navigator.of(context, rootNavigator: false);
    AppDialogs.showLoadingDialog(context);

    await Future.delayed(const Duration(milliseconds: 100));

    try {
      await authViewModel.logout();
    } catch (e) {
      // ignore logout errors, but ensure we still navigate
    }

    if (!mounted) return;

    try {
      navigatorState.pop();
    } catch (_) {}

    Navigation.navigateToScreenAndClearAllPrevious(
      context: context,
      screen: const LoginPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: AppStrings.studentProfile,
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
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
                  ProfileDetailCard(
                      title: AppStrings.firstName,
                      value: authViewModel.appUser?.studentProfile?.firstName ??
                          'N/A'),
                  ProfileDetailCard(
                      title: AppStrings.lastName,
                      value: authViewModel.appUser?.studentProfile?.lastName ??
                          'N/A'),
                  ProfileDetailCard(
                      title: AppStrings.idNumber,
                      value: authViewModel.appUser?.studentProfile?.idNumber ??
                          'N/A'),
                  ProfileDetailCard(
                    title: AppStrings.program,
                    value:
                        authViewModel.appUser?.studentProfile?.program ?? 'N/A',
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
