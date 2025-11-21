import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData appTheme = ThemeData(
    fontFamily: 'Nunito',
    useMaterial3: false,
    primarySwatch: Colors.blueGrey,
    primaryColor: AppColors.defaultColor,
    scaffoldBackgroundColor: AppColors.white,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
    bottomAppBarTheme: const BottomAppBarTheme(
      elevation: 0,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.transparent,
      surfaceTintColor: AppColors.transparent,
    ),
  );
}
