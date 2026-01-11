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
import 'package:attendance_app/ux/shared/view_models/remote_config_view_model.dart';
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
      theme: AppTheme.appTheme,
      navigatorKey: Navigation.navigatorKey,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
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
  final AuthViewModel _authViewModel = AppDI.getIt<AuthViewModel>();
  final CourseViewModel _courseViewModel = AppDI.getIt<CourseViewModel>();
  final RemoteConfigViewModel _remoteConfigViewModel =
      AppDI.getIt<RemoteConfigViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _authViewModel.saveAppUser(_manager.appUser);
      await _remoteConfigViewModel.initialize();

      final studentId = _manager.appUser?.studentProfile?.idNumber ?? '';
      if (studentId.isNotEmpty) {
        try {
          await _courseViewModel.loadRegisteredCourses(studentId);
        } catch (e, stack) {
          debugPrint(
              'Error loading courses or initializing attendance history: $e\n$stack');
        }
      }

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      if (_manager.appUser == null) {
        Navigation.navigateToScreenAndClearAllPrevious(
            context: context, screen: const LoginPage());
        return;
      }
      Navigation.navigateToScreenAndClearAllPrevious(
          context: context, screen: const NavigationHostPage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
