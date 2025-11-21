import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/components/custom_app_bar.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/utils/general_ui_utils.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/views/attendance_history/attendance_history_page.dart';
import 'package:attendance_app/ux/views/home/home_page.dart';
import 'package:attendance_app/ux/views/attendance/select_attendance_mode_page.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NavigationHostPage extends StatefulWidget {
  const NavigationHostPage({super.key, this.index});

  final int? index;

  @override
  State<NavigationHostPage> createState() => _NavigationHostPageState();
}

class _NavigationHostPageState extends State<NavigationHostPage> {
  final AuthViewModel _authViewModel = AppDI.getIt<AuthViewModel>();
  int currentPageIndex = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.index ?? 0;
    pages = [
      const HomePage(),
      const SelectAttendanceModePage(),
      const AttendanceHistoryPage(),
    ];
  }

  final List<Map<String, dynamic>> bottomNavItems = [
    {'icon': Iconsax.home5, 'text': AppStrings.home},
    {'icon': Iconsax.profile_tick5, 'text': AppStrings.attendance},
    {'icon': Iconsax.calendar5, 'text': AppStrings.history},
  ];

  @override
  Widget build(BuildContext context) {
    return AppPage(
      hideAppBar: true,
      hasBottomPadding: currentPageIndex != 2,
      body: Column(
        children: [
          CustomAppBar(
            title: getPageTitle(currentPageIndex),
            subtitle: getPageSubtitle(currentPageIndex),
          ),
          Expanded(
            child: pages[currentPageIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            bottomNavItems.length,
            (index) {
              return BottomNavIcon(
                icon: bottomNavItems[index]['icon'],
                text: bottomNavItems[index]['text'],
                isSelected: currentPageIndex == index,
                onTap: () => setState(
                  () => currentPageIndex = index,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String getPageTitle(int value) {
    switch (value) {
      case 0:
        return UiUtils.getGreetingTitle(
            _authViewModel.appUser?.studentProfile?.firstName ?? '');
      case 1:
        return AppStrings.selectAttendanceType;
      case 2:
        return AppStrings.attendanceHistory;
      default:
        return '';
    }
  }

  String getPageSubtitle(int value) {
    switch (value) {
      case 0:
        return UiUtils.getGreetingSubtitle();
      case 1:
        return AppStrings.areYouAttendingInPersonOrOnline;
      case 2:
        return AppStrings.viewYourAttendanceHistory;
      default:
        return '';
    }
  }
}

class BottomNavIcon extends StatelessWidget {
  const BottomNavIcon({
    super.key,
    required this.icon,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppMaterial(
      onTap: onTap,
      color: isSelected ? AppColors.primaryTeal : null,
      borderRadius: isSelected ? BorderRadius.circular(16.0) : null,
      inkwellBorderRadius: BorderRadius.circular(16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.defaultColor : AppColors.grey,
            ),
            Visibility(
              visible: isSelected,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      color:
                          isSelected ? AppColors.defaultColor : AppColors.white,
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
    );
  }
}
