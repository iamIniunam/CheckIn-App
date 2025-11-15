import 'dart:convert';

import 'package:attendance_app/platform/data_source/api/auth/models/app_user.dart';
import 'package:attendance_app/platform/data_source/persistence/manager.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';

extension PreferenceManagerExtensions on PreferenceManager {
  AppUser? get appUser {
    String jsonString = sharedPreference.getString(AppConstants.appUser) ?? "";
    if (jsonString.isEmpty) return null;
    Map<String, dynamic> json = jsonDecode(jsonString);
    return AppUser.fromJson(json);
  }

  Future saveAppUser(AppUser? value) async {
    if (value == null) {
      await sharedPreference.remove(AppConstants.appUser);
      return;
    }
    await sharedPreference.setString(
        AppConstants.appUser, jsonEncode(value.toMap()));
  }

  bool get isLoggedIn {
    return appUser != null;
  }

  Future<void> clearUserData() async {
    await saveAppUser(null);
  }

  // Clear all preferences
  Future<void> clearAll() async {
    await sharedPreference.clear();
  }
}
