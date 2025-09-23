import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  String idNumber = '';
  String level = '';
  String semester = '';
  String password = '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void updateIDNumber(String value) {
    idNumber = value;
    notifyListeners();
  }

  void updateLevel(String value) {
    level = value;
    notifyListeners();
  }

  void updateSemester(String value) {
    semester = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    notifyListeners();
  }

  void setLoadingState(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> saveDetailsToCache() async {
    try {
      setLoadingState(true);

      final pref = await SharedPreferences.getInstance();

      await Future.wait([
        pref.setString(AppConstants.idNumberKey, idNumber),
        pref.setString(AppConstants.levelKey, level),
        pref.setString(AppConstants.semesterKey, semester),
        pref.setString(AppConstants.passwordKey, password),
      ]);

      setLoadingState(false);
      return true;
    } catch (e) {
      setLoadingState(false);
      return false;
    }
  }

  Future<bool> signUp() async {
    if (!enableButton) return false;

    return await saveDetailsToCache();
  }

  static Future<bool> isUserSignedUp() async {
    try {
      final pref = await SharedPreferences.getInstance();

      final idNumber = pref.getString(AppConstants.idNumberKey);
      final level = pref.getString(AppConstants.levelKey);
      final semester = pref.getString(AppConstants.semesterKey);
      final password = pref.getString(AppConstants.passwordKey);

      return idNumber != null &&
          level != null &&
          semester != null &&
          password != null &&
          idNumber.isNotEmpty &&
          level.isNotEmpty &&
          semester.isNotEmpty &&
          password.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearUserData() async {
    try {
      final pref = await SharedPreferences.getInstance();

      await Future.wait([
        pref.remove(AppConstants.idNumberKey),
        pref.remove(AppConstants.levelKey),
        pref.remove(AppConstants.semesterKey),
        pref.remove(AppConstants.passwordKey),
      ]);

      idNumber = '';
      level = '';
      semester = '';
      password = '';

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isValidIdNumber(String idNumber) {
    if (idNumber.length != 12) {
      return false;
    }

    bool hasAorB = idNumber.contains('A') || idNumber.contains('B');
    bool hasY = idNumber.contains('Y');
    bool hasValidPrefix = idNumber.contains('ENG') ||
        idNumber.contains('ADS') ||
        idNumber.contains('ABS');

    return hasValidPrefix && hasAorB && hasY;
  }

  bool isValidLevel(String level) {
    if (level == '100' ||
        level == '200' ||
        level == '300' ||
        level == '400' && level.length == 3) {
      return true;
    } else {
      return false;
    }
  }

  bool isValidSemester(String semester) {
    if (semester.contains('1') ||
        semester.contains('2') && semester.length == 1) {
      return true;
    } else {
      return false;
    }
  }

  bool get isIdNumberValid => idNumber.isEmpty || isValidIdNumber(idNumber);
  bool get isLevelValid => level.isEmpty || isValidLevel(level);
  bool get isSemesterValid => semester.isEmpty || isValidSemester(semester);

  bool get enableButton {
    return idNumber.isNotEmpty &&
        level.isNotEmpty &&
        semester.isNotEmpty &&
        password.isNotEmpty &&
        isValidIdNumber(idNumber) &&
        isValidLevel(level) &&
        isValidSemester(semester);
  }
}
