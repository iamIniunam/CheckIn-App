import 'package:attendance_app/platform/api/auth/models/auth_request.dart';
import 'package:attendance_app/platform/repositories/auth_repository.dart';
import 'package:attendance_app/platform/services/auth_service.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:flutter/material.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final AuthService _authService;

  AuthViewModel({AuthRepository? authRepository, AuthService? authService})
      : _authRepository = authRepository ?? AuthRepository(),
        _authService = authService ?? AuthService();

  AuthState _state = AuthState.idle;
  String? _errorMessage;
  String? _successMessage;
  Student? _currentStudent;
  bool _isLoggedIn = false;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Student? get currentStudent => _currentStudent;
  bool get isLoading => _state == AuthState.loading;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkLoginStatus() async {
    _isLoggedIn = await _authService.isLoggedIn();

    if (_isLoggedIn) {
      _currentStudent = await _authService.getStudentData();
    }

    notifyListeners();
  }

  Future<bool> signUp({
    required String idNumber,
    required String firstName,
    required String lastName,
    required String program,
    required String password,
  }) async {
    setState(AuthState.loading);
    clearMessages();

    final request = SignUpRequest(
      idNumber: idNumber,
      firstName: firstName,
      lastName: lastName,
      program: program,
      password: password,
    );

    final response = await _authRepository.signUp(request);

    if (response.success && response.data != null) {
      _currentStudent = response.data;
      _successMessage = response.message ?? 'Sign up successful';

      await _authService.saveLoginState(response.data!);
      _isLoggedIn = true;

      setState(AuthState.success);
      return true;
    } else {
      _errorMessage = response.message ?? 'Sign up failed';
      setState(AuthState.error);
      return false;
    }
  }

  Future<bool> login({
    required String idNumber,
    required String password,
  }) async {
    setState(AuthState.loading);
    clearMessages();

    final request = LoginRequest(
      idNumber: idNumber,
      password: password,
    );

    final response = await _authRepository.login(request);

    if (response.success && response.data != null) {
      _currentStudent = response.data;
      _successMessage = response.message ?? 'Login successful!';

      await _authService.saveLoginState(response.data!);
      _isLoggedIn = true;

      setState(AuthState.success);
      return true;
    } else {
      _errorMessage = response.message ?? 'Login failed';
      setState(AuthState.error);
      return false;
    }
  }

  Future<void> loadSavedStudent() async {
    try {
      final student = await AuthService().getStudentData();
      if (student != null) {
        _currentStudent = student;
        _successMessage ??= 'Restored session';
        setState(AuthState.success);
      } else {
        setState(AuthState.idle);
      }
    } catch (e) {
      debugPrint('Failed to load saved student: $e');
      setState(AuthState.error);
    }
  }

  Future<void> logout() async {
    await _authService.logOut();
    _currentStudent = null;
    _isLoggedIn = false;
    clearMessages();
    setState(AuthState.idle);
  }

  void resetState() {
    setState(AuthState.idle);
    notifyListeners();
  }

  void setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
