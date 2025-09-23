import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserViewModel extends ChangeNotifier {
  UserViewModel({required this.pref});

  final SharedPreferences pref;

  String get idNumber => pref.getString(AppConstants.idNumberKey) ?? '';
  String get level => pref.getString(AppConstants.levelKey) ?? '';
  String get semester => pref.getString(AppConstants.semesterKey) ?? '';
  String get password => pref.getString(AppConstants.passwordKey) ?? '';
}