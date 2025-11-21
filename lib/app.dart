import 'dart:ui';

import 'package:attendance_app/platform/data_source/persistence/manager.dart';
import 'package:attendance_app/platform/data_source/persistence/manager_extensions.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/resources/app_theme.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/login_page.dart';
import 'package:attendance_app/ux/views/splash_screen.dart';
import 'package:flutter/material.dart';

class CheckInApp extends StatelessWidget {
  const CheckInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      navigatorKey: Navigation.navigatorKey,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      theme: AppTheme.appTheme,
      home: const EntryPage(),
    );
  }
}

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final _manager = AppDI.getIt<PreferenceManager>();
  final _authViewModel = AppDI.getIt<AuthViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _authViewModel.saveAppUser(_manager.appUser);

      final savedUser = _manager.appUser;

      if (savedUser == null) {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigation.navigateToScreenAndClearAllPrevious(
            context: context, screen: const LoginPage());
        return;
      }

      final studentId = savedUser.studentProfile?.idNumber ?? '';
      if (studentId.isNotEmpty) {
        Future.microtask(() async {
          try {
            await AppDI.getIt<CourseViewModel>()
                .loadRegisteredCourses(studentId);
          } catch (e) {
            // ignore background errors; UI can surface retries
          }
        });
      }

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigation.navigateToScreenAndClearAllPrevious(
          context: context, screen: const NavigationHostPage());
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
