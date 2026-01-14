import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/bottom_sheets/show_app_bottom_sheet.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/view_models/remote_config_view_model.dart';
import 'package:attendance_app/ux/views/attendance/components/padded_column.dart';
import 'package:attendance_app/ux/views/onboarding/login_page.dart';
import 'package:attendance_app/ux/views/profile/components/profile_detail_card.dart';
import 'package:attendance_app/ux/views/profile/logout_confirmation_bottom_sheet.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthViewModel authViewModel = AppDI.getIt<AuthViewModel>();
  final RemoteConfigViewModel remoteConfigViewModel =
      AppDI.getIt<RemoteConfigViewModel>();

  void logOut(context) async {
    AppDialogs.showLoadingDialog(context);
    await Future.delayed(const Duration(milliseconds: 100));
    await authViewModel.logout();
    Navigation.navigateToScreenAndClearAllPrevious(
      context: context,
      screen: const LoginPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: AppStrings.studentProfile,
      body: PaddedColumn(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
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
                  showDivider: false,
                ),
              ],
            ),
          ),
          Visibility(
            visible: remoteConfigViewModel.showLogoutButton,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: PrimaryButton(
                backgroundColor: AppColors.transparent,
                foregroundColor: AppColors.red500,
                overlayColor: AppColors.red500.withOpacity(0.05),
                onTap: () async {
                  bool? result = await showAppBottomSheet(
                    context: context,
                    showCloseButton: false,
                    child: const LogoutConfirmationBottomSheet(),
                  );
                  if (result == true && context.mounted) {
                    logOut(context);
                  }
                },
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
          ),
        ],
      ),
    );
  }
}
