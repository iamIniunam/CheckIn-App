import 'dart:convert';

import 'package:attendance_app/platform/repositories/auth_repository.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;
  Student? _currentStudent;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Student? get currentStudent => _currentStudent;

  bool get isLoggedIn => _currentStudent != null;

  Future<bool> login(
      {required String idNumber,
      required String password,
      required String level,
      required int semester}) async {
    setLoadingState(null, true);

    final response =
        await _authRepository.login(idNumber: idNumber, password: password);

    if (response.success && response.data != null) {
      _currentStudent = Student(
        idNumber: response.data?.idNumber ?? '',
        firstName: response.data?.firstName ?? '',
        lastName: response.data?.lastName ?? '',
        program: response.data?.program ?? '',
        password: response.data?.password ?? '',
        level: level,
        semester: semester,
      );

      if (_currentStudent != null) {
        await saveStudentData(_currentStudent);
      }
      await setIsUserLoggedIn(true);

      setLoadingState(null, false);
      return true;
    } else {
      setLoadingState(response.message, false);
      return false;
    }
  }

  Future<void> saveStudentData(Student? student) async {
    final pref = await SharedPreferences.getInstance();
    if (student != null) {
      await pref.setString(
        AppConstants.appUserKey,
        jsonEncode(
          student.toJson(),
        ),
      );
    }
  }

  Future<void> loadStudentData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final studentJson = pref.getString(AppConstants.appUserKey);

      debugPrint('Raw student JSON: $studentJson');

      if (studentJson != null && studentJson.isNotEmpty) {
        final decodedJson = jsonDecode(studentJson);
        debugPrint('Decoded JSON: $decodedJson');

        _currentStudent = Student.fromJson(decodedJson,
            level: decodedJson['level'], semester: decodedJson['semester']);

        notifyListeners();
      } else {
        debugPrint('No student data found in SharedPreferences');
      }
    } catch (e) {
      debugPrint('Error loading student data: $e');
      final pref = await SharedPreferences.getInstance();
      await pref.remove(AppConstants.appUserKey);
      await pref.remove(AppConstants.loggedInKey);
      _currentStudent = null;
      notifyListeners();
    }
  }

  Future<bool?> getIsUserLoggedIn() async {
    final pref = await SharedPreferences.getInstance();
    final isLoggedIn = pref.getBool(AppConstants.loggedInKey);

    if (isLoggedIn == true) {
      await loadStudentData();
    }

    return isLoggedIn;
  }

  Future<void> setIsUserLoggedIn(bool? value) async {
    final pref = await SharedPreferences.getInstance();
    if (value == null) {
      await pref.remove(AppConstants.loggedInKey);
      await pref.remove(AppConstants.appUserKey);
      _currentStudent = null;
      notifyListeners();
      return;
    }
    await pref.setBool(AppConstants.loggedInKey, value);
    if (!value) {
      _currentStudent = null;
      await pref.remove(AppConstants.appUserKey);
    }
    notifyListeners();
  }

  void setLoadingState(String? message, bool loading) {
    _errorMessage = message;
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> logout() async {
    await setIsUserLoggedIn(false);
    _currentStudent = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
