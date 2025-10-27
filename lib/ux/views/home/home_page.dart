import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/utils/general_ui_utils.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/home/components/attendance_threshold_widget.dart';
import 'package:attendance_app/ux/views/home/components/semester_courses_dashboard_metric_view.dart';
import 'package:attendance_app/ux/views/home/components/current_class.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final studentId = authViewModel.currentStudent?.idNumber;

      if (studentId != null) {
        // Load registered courses
        context.read<CourseViewModel>().loadRegisteredCourses(studentId);

        // Load other data here if needed
        // e.g., attendance data, current class, etc.
      }
    });
  }

  Future<void> refreshData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final studentId = authViewModel.currentStudent?.idNumber;

    if (studentId != null) {
      // Reload all data when user pulls to refresh
      await context.read<CourseViewModel>().reloadRegisteredCourses(studentId);

      // Reload other data if needed
      // await context.read<AttendanceViewModel>().loadData(studentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      hideAppBar: true,
      headerTitle: UiUtils.getGreetingTitle(
          context.watch<AuthViewModel>().currentStudent?.firstName ?? ''),
      headerSubtitle: UiUtils.getGreetingSubtitle(),
      showInformationBanner: true,
      informationBannerText: AppStrings.qrCodeExpirationWarning,
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: ListView(
          children: const [
            CurrentClass(),
            AttendanceThresholdWidget(),
            SizedBox(height: 10),
            SemesterCoursesDashboardMetricView(),
            // SizedBox(height: 10),
            // TodaysClasses(),
          ],
        ),
      ),
    );
  }
}
