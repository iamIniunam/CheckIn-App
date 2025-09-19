import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  String idNumber = '';
  String level = '';
  String semester = '';
  String password = '';

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

  Future<void> saveDetailsToCache() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(AppConstants.idNumberKey, idNumber);
    await pref.setString(AppConstants.levelKey, level);
    await pref.setString(AppConstants.semesterKey, semester);
    await pref.setString(AppConstants.passwordKey, password);
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
