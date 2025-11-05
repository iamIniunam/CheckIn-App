import 'dart:async';
import 'dart:io';

import 'package:attendance_app/app.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_search_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runAppWithZone();
}

void runAppWithZone() {
  runZonedGuarded<Future<void>>(
    () async {
      final appFuture = initializeApp();
      runApp(
        FutureBuilder<SharedPreferences>(
          future: appFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SplashScreen();
            }
            return MultiProvider(
              providers: [
                ChangeNotifierProvider<AuthViewModel>(
                  create: (_) => AppDI.getIt<AuthViewModel>(),
                ),
                ChangeNotifierProvider<CourseViewModel>(
                  create: (_) => AppDI.getIt<CourseViewModel>(),
                ),
                ChangeNotifierProvider<AttendanceViewModel>(
                  create: (_) => AppDI.getIt<AttendanceViewModel>(),
                ),
                ChangeNotifierProvider<CourseSearchViewModel>(
                  create: (_) => AppDI.getIt<CourseSearchViewModel>(),
                ),
              ],
              child: const CheckInApp(),
            );
          },
        ),
      );
    },
    errorHandler,
  );
}

Future<SharedPreferences> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  SharedPreferences preferences = await SharedPreferences.getInstance();

  try {
    await AppDI.init(sharedPreferences: preferences);
  } catch (e) {
    if (kDebugMode) {
      print('Initialization error: $e');
    }
  }
  return preferences;
}

void errorHandler(Object error, StackTrace stack) {
  if (kDebugMode) {
    print('Error: $error');
    print('Stack trace: $stack');
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
