import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/components/dashboard_metric_grid_view.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/drop_courses_page.dart';
import 'package:attendance_app/ux/views/onboarding/course_enrollment_page.dart';
import 'package:attendance_app/ux/views/profile/profile_page.dart';
import 'package:attendance_app/ux/views/settings/components/settings_card.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Settings',
      body: DashboardMetricGridView(
        crossAxisCount: 2,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          SettingsCard(
            icon: Iconsax.user,
            title: AppStrings.studentProfile,
            onTap: () {
              Navigation.navigateToScreen(
                  context: context, screen: const ProfilePage());
            },
          ),
          SettingsCard(
            icon: Iconsax.add_square,
            title: 'Add Courses',
            onTap: () {
              Navigation.navigateToScreen(
                context: context,
                screen: const CourseEnrollmentPage(isEdit: true),
              );
            },
          ),
          SettingsCard(
            icon: Iconsax.minus_square,
            title: 'Drop Courses',
            onTap: () {
              Navigation.navigateToScreen(
                context: context,
                screen: const DropCoursesPage(),
              );
            },
          ),
        ],
      ),
    );
  }
}
