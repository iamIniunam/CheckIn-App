import 'package:attendance_app/platform/repositories/auth_repository.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:flutter/material.dart';

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

  Future<bool> login(String idNumber, String password) async {
    setLoadingState(null, true);

    final response = await _authRepository.login(
      idNumber: idNumber,
      password: password,
    );

    if (response.success && response.data != null) {
      _currentStudent = response.data;
      setLoadingState(null, false);
      return true;
    } else {
      setLoadingState(response.message, false);
      return false;
    }
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
