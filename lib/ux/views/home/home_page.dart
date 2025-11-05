import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/utils/general_ui_utils.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
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
  late final AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
    _authViewModel = AppDI.getIt<AuthViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadData());
  }

  void loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentId = _authViewModel.appUser?.studentProfile?.idNumber;

      if (studentId != null && studentId.isNotEmpty) {
        context.read<CourseViewModel>().loadRegisteredCourses(studentId);
      }
    });
  }

  Future<void> refreshData() async {
    final studentId = _authViewModel.appUser?.studentProfile?.idNumber;

    if (studentId != null) {
      await context.read<CourseViewModel>().reloadRegisteredCourses(studentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      hideAppBar: true,
      headerTitle: UiUtils.getGreetingTitle(
          _authViewModel.appUser?.studentProfile?.firstName ?? ''),
      headerSubtitle: UiUtils.getGreetingSubtitle(),
      showInformationBanner: true,
      informationBannerText: AppStrings.qrCodeExpirationWarning,
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: ListView(
          children: const [
            CurrentClass(),
            // AttendanceThresholdWidget(),
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
