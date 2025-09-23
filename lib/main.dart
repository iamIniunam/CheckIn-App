import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/user_view_model.dart';
import 'package:attendance_app/ux/views/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isLoggedIn = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyAl1DBprDxmRRksJXXXOZwGv1mnxfJUmkA',
            appId: '1:539127475744:android:6deb6ddbfdea9a6e05d645',
            messagingSenderId: '',
            projectId: 'attendance-app-2759d'));
  } catch (e) {
    debugPrint('$e');
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel(pref: prefs)),
        ChangeNotifierProvider(create: (_) => CourseViewModel()),
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
      home: const SplashScreen(),
    );
  }
}
