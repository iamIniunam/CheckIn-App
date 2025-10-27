import 'dart:convert';

import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> saveLoginState(Student student) async {
    await init();
    try {
      final studentJson = jsonEncode(student.toJson());
      await _prefs?.setBool(AppConstants.isLoggedInKey, true);
      await _prefs?.setString(AppConstants.studentDataKey, studentJson);
      return true;
    } catch (e) {
      debugPrint('Error saving login state: $e');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    await init();
    return _prefs?.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  Future<Student?> getStudentData() async {
    await init();
    try {
      final studentJson = _prefs?.getString(AppConstants.studentDataKey);
      if (studentJson != null) {
        final studentMap = jsonDecode(studentJson) as Map<String, dynamic>;
        return Student.fromJson(studentMap);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting student data: $e');
      return null;
    }
  }

  Future<bool> clearLoginState() async {
    await init();
    try {
      await _prefs?.remove(AppConstants.isLoggedInKey);
      await _prefs?.remove(AppConstants.studentDataKey);
      // Or use clear() to remove all preferences
      // await _prefs!.clear();
      return true;
    } catch (e) {
      debugPrint('Error clearing login state: $e');
      return false;
    }
  }

  Future<bool> updateStudentData(Student student) async {
    await init();
    try {
      final studentJson = jsonEncode(student.toJson());
      await _prefs!.setString(AppConstants.studentDataKey, studentJson);
      return true;
    } catch (e) {
      debugPrint('Error updating student data: $e');
      return false;
    }
  }
}
