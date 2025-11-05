import 'dart:ui';

import 'package:attendance_app/platform/data_source/persistence/manager.dart';
import 'package:attendance_app/platform/data_source/persistence/manager_extensions.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/sign_up_page.dart';
import 'package:attendance_app/ux/views/splash_screen.dart';
import 'package:flutter/material.dart';

class CheckInApp extends StatelessWidget {
  const CheckInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CheckIn App',
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Nunito',
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
        bottomAppBarTheme: const BottomAppBarTheme(
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: AppColors.white,
          surfaceTintColor: AppColors.white,
        ),
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
            context: context, screen: const SignUpPage());
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
