import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/attendance_history/attendance_history_page.dart';
import 'package:attendance_app/ux/views/home/home_page.dart';
import 'package:attendance_app/ux/views/attendance/select_attendance_mode_page.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NavigationHostPage extends StatefulWidget {
  const NavigationHostPage({super.key});

  @override
  State<NavigationHostPage> createState() => _NavigationHostPageState();
}

class _NavigationHostPageState extends State<NavigationHostPage> {
  int currentPageIndex = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const HomePage(),
      const SelectAttendanceModePage(),
      const AttendanceHistoryPage()
    ];
  }

  final List<Map<String, dynamic>> bottomNavItems = [
    {'icon': Iconsax.home5, 'text': AppStrings.home},
    {'icon': Iconsax.profile_tick5, 'text': AppStrings.attendance},
    {'icon': Iconsax.calendar5, 'text': AppStrings.history},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPageIndex],
      bottomNavigationBar:
          // currentPageIndex == 1
          //     ? null
          //     :
          BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            bottomNavItems.length,
            (index) {
              return BottomNavIcon(icon: bottomNavItems[index]['icon'], text: bottomNavItems[index]['text'], isSelected: currentPageIndex == index, onTap: () => setState(() => currentPageIndex = index));
            },
          ),
        ),
      ),
    );
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
      borderRadius: BorderRadius.circular(16.0),
      inkwellBorderRadius: BorderRadius.circular(16.0),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primaryTeal,
                borderRadius: BorderRadius.circular(16.0),
              )
            : null,
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
                        color: isSelected
                            ? AppColors.defaultColor
                            : AppColors.white,
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
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
