import 'package:attendance_app/platform/api/auth_api/models/auth_request.dart';
import 'package:attendance_app/platform/repositories/auth_repository.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:flutter/material.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  AuthState _state = AuthState.idle;
  String? _errorMessage;
  String? _successMessage;
  Student? _currentStudent;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Student? get currentStudent => _currentStudent;
  bool get isLoading => _state == AuthState.loading;

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
      setState(AuthState.success);
      return true;
    } else {
      _errorMessage = response.message ?? 'Login failed';
      setState(AuthState.error);
      return false;
    }
  }

  void logout() {
    _currentStudent = null;
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

  // Future<void> saveStudentData(Student? student) async {
  //   final pref = await SharedPreferences.getInstance();
  //   if (student != null) {
  //     await pref.setString(
  //       AppConstants.appUserKey,
  //       jsonEncode(
  //         student.toJson(),
  //       ),
  //     );
  //   }
  // }

  // Future<void> loadStudentData() async {
  //   try {
  //     final pref = await SharedPreferences.getInstance();
  //     final studentJson = pref.getString(AppConstants.appUserKey);

  //     // debugPrint('Raw student JSON: $studentJson');

  //     if (studentJson != null && studentJson.isNotEmpty) {
  //       final decodedJson = jsonDecode(studentJson);
  //       // debugPrint('Decoded JSON: $decodedJson');

  //       _currentStudent = Student.fromJson(decodedJson);

  //       notifyListeners();
  //     } else {
  //       debugPrint('No student data found in SharedPreferences');
  //     }
  //   } catch (e) {
  //     debugPrint('Error loading student data: $e');
  //     final pref = await SharedPreferences.getInstance();
  //     await pref.remove(AppConstants.appUserKey);
  //     await pref.remove(AppConstants.loggedInKey);
  //     _currentStudent = null;
  //     notifyListeners();
  //   }
  // }

  // Future<bool?> getIsUserLoggedIn() async {
  //   final pref = await SharedPreferences.getInstance();
  //   final isLoggedIn = pref.getBool(AppConstants.loggedInKey);

  //   if (isLoggedIn == true) {
  //     await loadStudentData();
  //   }

  //   return isLoggedIn;
  // }

  // Future<void> setIsUserLoggedIn(bool? value) async {
  //   final pref = await SharedPreferences.getInstance();
  //   if (value == null) {
  //     await pref.remove(AppConstants.loggedInKey);
  //     await pref.remove(AppConstants.appUserKey);
  //     _currentStudent = null;
  //     notifyListeners();
  //     return;
  //   }
  //   await pref.setBool(AppConstants.loggedInKey, value);
  //   if (!value) {
  //     _currentStudent = null;
  //     await pref.remove(AppConstants.appUserKey);
  //   }
  //   notifyListeners();
  // }

  // void setLoadingState(String? message, bool loading) {
  //   _loginError = message;
  //   _isLoading = loading;
  //   notifyListeners();
  // }

  // Future<void> logout() async {
  //   await setIsUserLoggedIn(false);
  //   _currentStudent = null;
  //   _loginError = null;
  //   notifyListeners();
  // }

  // void clearError() {
  //   _loginError = null;
  //   notifyListeners();
  // }
}
