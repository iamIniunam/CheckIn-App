import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/auth/models/app_user.dart';
import 'package:attendance_app/platform/data_source/api/auth/models/auth_request.dart';
import 'package:attendance_app/platform/data_source/api/auth/models/auth_response.dart';
import 'package:attendance_app/platform/data_source/persistence/manager.dart';
import 'package:attendance_app/platform/data_source/persistence/manager_extensions.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_search_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_view_model.dart';

class AuthViewModel extends ChangeNotifier {
  final Api _api = AppDI.getIt<Api>();
  final PreferenceManager _preferenceManager = AppDI.getIt<PreferenceManager>();

  // UI Results
  ValueNotifier<UIResult<StudentProfile>> signUpResult =
      ValueNotifier(UIResult.empty());
  ValueNotifier<UIResult<StudentProfile>> loginResult =
      ValueNotifier(UIResult.empty());

  AppUser? _appUser;
  AppUser? get appUser => _appUser;

  Future<void> saveAppUser(AppUser? user) async {
    _appUser = user;
    notifyListeners();
    await _preferenceManager.saveAppUser(appUser);
  }

  Future<UIResult<StudentProfile>> signUp(
      {required SignUpRequest signUpRequest}) async {
    signUpResult.value = UIResult.loading();

    final response = await _api.authApi.signUp(signUpRequest);
    if (response.status == ApiResponseStatus.Success) {
      final isError = response.response['error'] == true;

      if (isError) {
        loginResult.value = UIResult.error(
          message: response.response['message'] ??
              'Sign Up failed. Please try again.',
        );
        return loginResult.value;
      }

      try {
        final data = response.response['data'] ?? response.response;
        var student = StudentProfile.fromJson(data);

        final bool hasServerData = (student.firstName?.isNotEmpty ?? false) ||
            (student.lastName?.isNotEmpty ?? false) ||
            (student.idNumber?.isNotEmpty ?? false) ||
            (student.program?.isNotEmpty ?? false);

        if (!hasServerData) {
          student = StudentProfile(
            idNumber: signUpRequest.idNumber,
            firstName: signUpRequest.firstName,
            lastName: signUpRequest.lastName,
            program: signUpRequest.program,
          );
        }

        final appUser = AppUser(studentProfile: student);
        // Persist and update in-memory user so UI listeners get the new value immediately
        await saveAppUser(appUser);

        signUpResult.value =
            UIResult.success(data: student, message: response.message);
        return signUpResult.value;
      } catch (e) {
        signUpResult.value =
            UIResult.error(message: 'Failed to parse sign up response.');
        return signUpResult.value;
      }
    }
    signUpResult.value =
        UIResult.error(message: response.message ?? 'Sign up failed.');
    return signUpResult.value;
  }

  Future<UIResult<StudentProfile>> login(
      {required LoginRequest loginRequest}) async {
    loginResult.value = UIResult.loading();

    final response = await _api.authApi.login(loginRequest);
    if (response.status == ApiResponseStatus.Success) {
      final isError = response.response['error'] == true;

      if (isError) {
        loginResult.value = UIResult.error(
          message:
              response.response['message'] ?? 'Login failed. Please try again.',
        );
        return loginResult.value;
      }

      try {
        final data = response.response['data'] ?? response.response;
        final student = StudentProfile.fromJson(data);

        final appUser = AppUser(studentProfile: student);
        // Persist and update in-memory user so UI listeners get the new value immediately
        await saveAppUser(appUser);

        loginResult.value =
            UIResult.success(data: student, message: response.message);
        return loginResult.value;
      } catch (e) {
        loginResult.value =
            UIResult.error(message: 'Failed to parse login response.');
        return loginResult.value;
      }
    }
    loginResult.value =
        UIResult.error(message: response.message ?? 'Login failed.');
    return loginResult.value;
  }

  Future<void> logout() async {
    await _preferenceManager.clearUserData();
    _appUser = null;
    notifyListeners();

    try {
      final courseVm = AppDI.getIt<CourseViewModel>();
      courseVm.clear();
    } catch (_) {}

    try {
      final attendanceVm = AppDI.getIt<AttendanceViewModel>();
      attendanceVm.clear();
    } catch (_) {}

    try {
      final courseSearchVm = AppDI.getIt<CourseSearchViewModel>();
      courseSearchVm.clearSelectedCourses();
      courseSearchVm.clearFilter();
      courseSearchVm.clearSearch();
    } catch (_) {}

    try {
      loginResult.value = UIResult.empty();
    } catch (_) {}

    try {
      signUpResult.value = UIResult.empty();
    } catch (_) {}
  }
}
