import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/components/dashboard_metric_grid_view.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/onboarding/course_enrollment_page.dart';
import 'package:attendance_app/ux/views/profile/profile_page.dart';
import 'package:attendance_app/ux/views/settings/components/settings_card.dart';
import 'package:flutter/material.dart';

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
            icon: Icons.person_rounded,
            title: AppStrings.studentProfile,
            onTap: () {
              Navigation.navigateToScreen(
                  context: context, screen: const ProfilePage());
            },
          ),
          SettingsCard(
            icon: Icons.edit_note_rounded,
            title: 'Add/Drop Courses',
            onTap: () {
              Navigation.navigateToScreen(
                  context: context,
                  screen: const CourseEnrollmentPage(isEdit: true));
            },
          ),
        ],
      ),
    );
  }
}
