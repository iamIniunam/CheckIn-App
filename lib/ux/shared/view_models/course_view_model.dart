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

  int _totalCoursesToRegister = 0;
  int _coursesRegistered = 0;
  List<String> _failedCourses = [];

  // Getters
  List<Course> get registeredCourses => List.unmodifiable(_registeredCourses);
  bool get isLoadingRegisteredCourses => _isLoadingRegisteredCourses;
  bool get isRegisteringCourses => _isRegisteringCourses;
  String? get registeredCoursesError => _registeredCoursesError;
  String? get registrationError => _registrationError;
  bool get hasRegisteredCoursesError => _registeredCoursesError != null;
  bool get hasRegistrationError => _registrationError != null;
  bool get hasLoadedRegisteredCourses => _hasLoadedRegisteredCourses;

  int get totalCoursesToRegister => _totalCoursesToRegister;
  int get coursesRegistered => _coursesRegistered;
  double get registrationProgress => _totalCoursesToRegister > 0
      ? _coursesRegistered / _totalCoursesToRegister
      : 0.0;
  List<String> get failedCourses => List.unmodifiable(_failedCourses);

  Future<void> loadRegisteredCourses(String studentId,
      {bool forceRefresh = false}) async {
    if (_hasLoadedRegisteredCourses && !forceRefresh) return;

    // Defensive: do not attempt network call if studentId is empty.
    if (studentId.trim().isEmpty) {
      _registeredCoursesError = 'No student id provided';
      _registeredCourses = [];
      _isLoadingRegisteredCourses = false;
      _hasLoadedRegisteredCourses = false;
      notifyListeners();
      return;
    }

    _isLoadingRegisteredCourses = true;
    _registeredCoursesError = null;
    notifyListeners();

    try {
      final response = await _repository.fetchRegisteredCourses(studentId);

      if (response.data != null) {
        // Ensure each course is assigned a unique color from the palette.
        final raw = response.data ?? [];
        _registeredCourses = Course.assignUniqueColors(raw);
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

  Future<bool> registerCourses({
    required String studentId,
    required List<Course> courses,
  }) async {
    // Validate that the same course code hasn't been selected from
    // different schools. If so, block registration and show a clear error.
    final Map<String, Set<String>> codeToSchools = {};
    for (final course in courses) {
      final code = course.courseCode;
      final school = (course.school ?? '').trim();
      codeToSchools.putIfAbsent(code, () => <String>{});
      codeToSchools[code]?.add(school);
    }

    final conflicts = codeToSchools.entries
        .where((e) => e.value.length > 1)
        .toList(growable: false);

    if (conflicts.isNotEmpty) {
      final details = conflicts
          .map((e) =>
              '${e.key} — ${e.value.where((s) => s.isNotEmpty).join(', ')}')
          .join('; ');
      _registrationError =
          'Duplicate course codes found in multiple schools: $details. \n\nPlease select only one.';
      _isRegisteringCourses = false;
      notifyListeners();
      return false;
    }

    _isRegisteringCourses = true;
    _registrationError = null;
    _totalCoursesToRegister = courses.length;
    _coursesRegistered = 0;
    _failedCourses = [];
    notifyListeners();

    try {
      for (final course in courses) {
        if (course.id == null) {
          debugPrint('Skipping ${course.courseCode} - no ID');
          _failedCourses.add('${course.courseCode} (No ID)');
          continue;
        }

        try {
          // debugPrint(
          //     'Registering course: ${course.courseCode} (ID: ${course.id}) for student: $studentId');

          final response = await _repository.registerCourse(
            courseId: course.id ?? 0,
            studentId: studentId,
          );

          // debugPrint(
          //     'Register API response for ${course.courseCode}: success=${response.success}, status=${response.statusCode}, message=${response.message}, data=${response.data}');

          if (response.success) {
            _coursesRegistered++;
            debugPrint('Successfully registered ${course.courseCode}');
          } else {
            _failedCourses
                .add('${course.courseCode} (Error: ${response.message})');
            debugPrint(
                'Failed to register ${course.courseCode}: ${response.message}');
          }
        } catch (e) {
          _failedCourses.add('${course.courseCode} (Error: $e)');
          debugPrint('Error registering ${course.courseCode}: $e');
        }
        notifyListeners();
      }

      final allSuccess = _failedCourses.isEmpty;

      if (allSuccess) {
        await loadRegisteredCourses(studentId, forceRefresh: true);

        _isRegisteringCourses = false;
        notifyListeners();
        return true;
      } else {
        // Some courses failed
        _registrationError = _failedCourses.length == courses.length
            ? 'Failed to register all courses'
            : 'Successfully registered $_coursesRegistered of $_totalCoursesToRegister courses';

        // Still reload to get updated list
        await loadRegisteredCourses(studentId, forceRefresh: true);

        _isRegisteringCourses = false;
        notifyListeners();
        return _coursesRegistered > 0; // Return true if at least one succeeded
      }
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
