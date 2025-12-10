import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/shared/components/information_banner.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/home/components/semester_courses_dashboard_metric_view.dart';
import 'package:attendance_app/ux/views/home/components/mark_attendance_quick_access.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthViewModel _authViewModel = AppDI.getIt<AuthViewModel>();
  final CourseViewModel _courseViewModel = AppDI.getIt<CourseViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadData());
  }

  void loadData() async {
    final studentId = _authViewModel.appUser?.studentProfile?.idNumber;

    if (studentId != null && studentId.isNotEmpty) {
      _courseViewModel.loadRegisteredCourses(studentId);
    }
  }

  Future<void> refreshData() async {
    final studentId = _authViewModel.appUser?.studentProfile?.idNumber;

    if (studentId != null) {
      Future.microtask(
          () => _courseViewModel.reloadRegisteredCourses(studentId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      displacement: 60,
      onRefresh: refreshData,
      child: Column(
        children: [
          const InformationBanner(text: AppStrings.qrCodeExpirationWarning),
          Expanded(
            child: ListView(
              children: const [
                MarkAttendanceQuickAccess(),
                // AttendanceThresholdWidget(),
                SizedBox(height: 10),
                SemesterCoursesDashboardMetricView(),
                // SizedBox(height: 10),
                // TodaysClasses(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
