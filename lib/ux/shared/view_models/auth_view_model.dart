import 'package:attendance_app/platform/repositories/auth_repository.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  String level = '';
  int semester = 0;
  bool _isLoading = false;
  String? _errorMessage;
  Student? _currentStudent;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Student? get currentStudent => _currentStudent;

  bool get isLoggedIn => _currentStudent != null;

  Future<bool> login(String idNumber, String password) async {
    setLoadingState(null, true);

    final response =
        await _authRepository.login(idNumber: idNumber, password: password);

    if (response.success && response.data != null) {
      _currentStudent = response.data;
      saveLevelAndSemesterToCache();
      setIsUserLoggedIn(true);
      setLoadingState(null, false);
      return true;
    } else {
      setLoadingState(response.message, false);
      return false;
    }
  }

  void updateLevel(String value) {
    level = value;
    notifyListeners();
  }

  void updateSemester(int value) {
    semester = value;
    notifyListeners();
  }

  Future<bool> saveLevelAndSemesterToCache() async {
    try {
      final pref = await SharedPreferences.getInstance();

      await Future.wait([
        pref.setString(AppConstants.levelKey, level),
        pref.setInt(AppConstants.semesterKey, semester),
      ]);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool?> getIsUserLoggedIn() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(AppConstants.loggedInKey);
  }

  Future<void> setIsUserLoggedIn(bool? value) async {
    final pref = await SharedPreferences.getInstance();
    if (value == null) {
      await pref.remove(AppConstants.loggedInKey);
      _currentStudent = null;
      notifyListeners();
      return;
    }
    await pref.setBool(AppConstants.loggedInKey, value);
    if (!value) {
      _currentStudent = null;
    }
    notifyListeners();
  }

  void setLoadingState(String? message, bool loading) {
    _errorMessage = message;
    _isLoading = loading;
    notifyListeners();
  }

  void logout() {
    _currentStudent = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
