import 'package:attendance_app/platform/repositories/course_repository.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:flutter/material.dart';

class CourseViewModel extends ChangeNotifier {
  final CourseRepository _repository;

  CourseViewModel({CourseRepository? repository})
      : _repository = repository ?? CourseRepository();

  // Registered courses from API
  List<Course> _registeredCourses = [];
  bool _isLoadingRegisteredCourses = false;
  bool _isRegisteringCourses = false;
  String? _registeredCoursesError;
  String? _registrationError;
  bool _hasLoadedRegisteredCourses = false;

  // Getters
  List<Course> get registeredCourses => List.unmodifiable(_registeredCourses);
  bool get isLoadingRegisteredCourses => _isLoadingRegisteredCourses;
  bool get isRegisteringCourses => _isRegisteringCourses;
  String? get registeredCoursesError => _registeredCoursesError;
  String? get registrationError => _registrationError;
  bool get hasRegisteredCoursesError => _registeredCoursesError != null;
  bool get hasRegistrationError => _registrationError != null;
  bool get hasLoadedRegisteredCourses => _hasLoadedRegisteredCourses;

  // Load registered courses
  Future<void> loadRegisteredCourses(String studentId,
      {bool forceRefresh = false}) async {
    if (_hasLoadedRegisteredCourses && !forceRefresh) return;

    _isLoadingRegisteredCourses = true;
    _registeredCoursesError = null;
    notifyListeners();

    try {
      final response = await _repository.fetchRegisteredCourses(studentId);

      if (response.data != null) {
        _registeredCourses = response.data ?? [];
        _registeredCoursesError = null;
        _hasLoadedRegisteredCourses = true;
      } else {
        _registeredCoursesError =
            response.message ?? 'Failed to load registered courses';
        _registeredCourses = [];
      }
    } catch (e) {
      _registeredCoursesError = 'An unexpected error occurred: ${e.toString()}';
      _registeredCourses = [];
    } finally {
      _isLoadingRegisteredCourses = false;
      notifyListeners();
    }
  }

  // Register courses (with simulation for now)
  Future<bool> registerCourses({
    required String studentId,
    required List<Course> courses,
    required Map<Course, String?> chosenSchools,
  }) async {
    _isRegisteringCourses = true;
    _registrationError = null;
    notifyListeners();

    try {
      // Simulate API call (remove this when you have the real endpoint)
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Replace with actual API call when endpoint is ready
      // Prepare courses data for API
      // final coursesData = courses.map((course) {
      //   return {
      //     'course_id': course.id,
      //     'school': chosenSchools[course],
      //   };
      // }).toList();

      // final response = await _repository.registerCourses(
      //   studentId: studentId,
      //   courses: coursesData,
      // );

      // if (response.success) {
      //   // Reload registered courses after successful registration
      //   await loadRegisteredCourses(studentId, forceRefresh: true);
      //   _isRegisteringCourses = false;
      //   notifyListeners();
      //   return true;
      // } else {
      //   _registrationError = response.message ?? 'Failed to register courses';
      //   _isRegisteringCourses = false;
      //   notifyListeners();
      //   return false;
      // }

      // Simulate success for now
      debugPrint(
          'Registering ${courses.length} courses for student: $studentId');
      courses.forEach((course) {
        debugPrint(
            'Course: ${course.courseCode} - School: ${chosenSchools[course]}');
      });

      // Simulate adding to registered courses
      _registeredCourses.addAll(courses);
      _hasLoadedRegisteredCourses = true;

      _isRegisteringCourses = false;
      notifyListeners();
      return true;
    } catch (e) {
      _registrationError = 'An unexpected error occurred: ${e.toString()}';
      _isRegisteringCourses = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> reloadRegisteredCourses(String studentId) async {
    return loadRegisteredCourses(studentId, forceRefresh: true);
  }

  void clearRegisteredCoursesError() {
    _registeredCoursesError = null;
    notifyListeners();
  }

  void clearRegistrationError() {
    _registrationError = null;
    notifyListeners();
  }
}
