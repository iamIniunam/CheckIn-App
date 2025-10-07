import 'package:attendance_app/platform/repositories/course_repository.dart';
import 'package:attendance_app/platform/services/selected_courses_service.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';

class CourseViewModel extends ChangeNotifier {
  final CourseRepository _repository;
  final SelectedCourseService _selectedCoursesService;

  CourseViewModel({
    CourseRepository? repository,
    SelectedCourseService? selectedCoursesService,
  })  : _repository = repository ?? CourseRepository(),
        _selectedCoursesService =
            selectedCoursesService ?? SelectedCourseService();

  // Available courses from API
  List<Course> _availableCourses = [];
  bool _isLoadingCourses = false;
  String? _loadError;

  // Selected courses state
  final Set<Course> _selectedCourses = {};
  final Map<Course, String?> _chosenStreams = {};
  bool _isConfirming = false;
  String? _errorMessage;

  // Getters for available courses
  List<Course> get availableCourses => List.unmodifiable(_availableCourses);
  bool get isLoadingCourses => _isLoadingCourses;
  String? get loadError => _loadError;
  bool get hasLoadError => _loadError != null;

  // Getters for selected courses
  List<Course> get selectedCourses => _selectedCourses.toList();
  Map<Course, String?> get chosenStreams => Map.unmodifiable(_chosenStreams);
  bool get isConfirming => _isConfirming;
  String? get errorMessage => _errorMessage;

  int get totalCreditHours => _selectedCourses.fold(
      0, (sum, course) => sum + (course.creditHours ?? 0));

  bool get canConfirm =>
      _selectedCourses.isNotEmpty &&
      totalCreditHours <= AppConstants.requiredCreditHours &&
      !_isConfirming;

  bool get canAddCourse => totalCreditHours < AppConstants.requiredCreditHours;

  Future<void> loadCourses(String level, int semester) async {
    setLoadingState(null, true);

    try {
      final response = await _repository.fetchCoursesForLevelAndSemester(
        level,
        semester,
      );

      if (response.data != null) {
        _availableCourses = response.data ?? [];
        _loadError = null;
      } else {
        _loadError = response.message ?? 'Failed to load courses';
        _availableCourses = [];
      }
    } catch (e) {
      _loadError = 'An unexpected error occurred: ${e.toString()}';
      _availableCourses = [];
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  // Retry loading courses
  Future<void> reloadCourses(String level, int semester) async {
    return loadCourses(level, semester);
  }

  void setLoadingState(String? message, bool loading) {
    _loadError = message;
    _isLoadingCourses = loading;
    notifyListeners();
  }

  bool isCourseSelected(Course course) {
    return _chosenStreams[course] != null;
  }

  String? getCourseStream(Course course) {
    return _chosenStreams[course];
  }

  void updateCourseStream(Course course, String? stream) {
    clearError();

    if (_chosenStreams[course] == stream) {
      _chosenStreams.remove(course);
      _selectedCourses.remove(course);
    } else {
      if (!_selectedCourses.contains(course)) {
        final newTotal = totalCreditHours + (course.creditHours ?? 0);
        if (newTotal > AppConstants.requiredCreditHours) {
          setError('Adding this course would exceed the credit hour limit');
          return;
        }
      }
      _chosenStreams[course] = stream;
      _selectedCourses.add(course);
    }
    notifyListeners();
  }

  Future<bool> confirmCourses() async {
    if (!canConfirm) return false;

    _isConfirming = true;
    clearError();
    notifyListeners();

    try {
      // TODO: Add API call to save selected courses to backend
      await Future.delayed(const Duration(seconds: 1));
      _selectedCoursesService.updateSelectedCourses(
          _selectedCourses.toList(), _chosenStreams);

      _isConfirming = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isConfirming = false;
      setError('Failed to confirm courses: $e');
      return false;
    }
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
