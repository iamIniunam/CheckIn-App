import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_records_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_search_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/user_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/sign_up_page.dart';
import 'package:attendance_app/ux/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isLoggedIn = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final authViewModel = AuthViewModel();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authViewModel),
        ChangeNotifierProvider(create: (_) => CourseViewModel()),
        ChangeNotifierProvider(create: (_) => AttendanceRecordsViewModel()),
        ChangeNotifierProvider(create: (_) => CourseSearchViewModel()),
        ChangeNotifierProxyProvider<AuthViewModel, UserViewModel>(
          create: (_) =>
              UserViewModel(pref: prefs, authViewModel: authViewModel),
          update: (_, auth, previous) =>
              previous ?? UserViewModel(pref: prefs, authViewModel: auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      home: const NavigationHostPage(),
    );
  }
}
