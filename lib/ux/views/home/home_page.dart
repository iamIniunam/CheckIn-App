// ignore_for_file: avoid_print

import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/utils/general_ui_utils.dart';
import 'package:attendance_app/ux/views/home/components/attendance_threshold_widget.dart';
import 'package:attendance_app/ux/views/home/components/semester_courses_dashboard_metric_view.dart';
import 'package:attendance_app/ux/views/home/components/current_class.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      hideAppBar: true,
      headerTitle: UiUtils.getGreetingTitle(AppStrings.sampleAppUser),
      headerSubtitle: UiUtils.getGreetingSubtitle(),
      showInformationBanner: true,
      informationBannerText: AppStrings.qrCodeExpirationWarning,
      hasRefreshIndicator: true,
      body: ListView(
        children: const [
          CurrentClass(),
          AttendanceThresholdWidget(),
          SizedBox(height: 10),
          SemesterCoursesDashboardMetricView(),
          SizedBox(height: 10),
          // TodaysClasses(),
        ],
      ),
    );
  }
}
