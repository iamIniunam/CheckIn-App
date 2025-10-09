import 'package:attendance_app/platform/course_search_helper.dart';
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

  // All courses from API
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  String _searchQuery = '';
  bool _isLoadingCourses = false;
  String? _loadError;

  //Filter state
  int? _selectedLevel;
  int? _selectedSemester;
  bool _hasActiveFilter = false;

  // Selected courses state
  final Set<Course> _selectedCourses = {};
  final Map<Course, String?> _chosenSchools = {};
  bool _isConfirming = false;
  String? _errorMessage;

  //Getters for courses with search applied
  List<Course> get displayedCourses {
    final courseToSearch = _hasActiveFilter ? _filteredCourses : _allCourses;
    if (_searchQuery.isEmpty) {
      return List.unmodifiable(courseToSearch);
    }

    return CourseSearchHelper.searchCourses(courseToSearch, _searchQuery);
  }

  // Getters for all courses
  List<Course> get allCourses => List.unmodifiable(_allCourses);
  String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.isNotEmpty;
  bool get isLoadingCourses => _isLoadingCourses;
  String? get loadError => _loadError;
  bool get hasLoadError => _loadError != null;

  //Filter getters
  int? get selectedLevel => _selectedLevel;
  int? get selectedSemester => _selectedSemester;
  bool get hasActiveFilter => _hasActiveFilter;
  String get filterSummary {
    if (!_hasActiveFilter) return 'No filters applied';
    return 'Level $_selectedLevel, Semester $_selectedSemester';
  }

  // Getters for selected courses
  List<Course> get selectedCourses => _selectedCourses.toList();
  Map<Course, String?> get chosenSchools => Map.unmodifiable(_chosenSchools);
  bool get isConfirming => _isConfirming;
  String? get errorMessage => _errorMessage;

  int get totalCreditHours => _selectedCourses.fold(
      0, (sum, course) => sum + (course.creditHours ?? 0));

  bool get canConfirm =>
      _selectedCourses.isNotEmpty &&
      totalCreditHours <= AppConstants.requiredCreditHours &&
      !_isConfirming;

  bool get canAddCourse => totalCreditHours < AppConstants.requiredCreditHours;

  void searchCourses(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> applyFilter(int? level, int? semester) async {
    if (level == null || semester == null) {
      clearFilter();
      return;
    }

    _selectedLevel = level;
    _selectedSemester = semester;
    _hasActiveFilter = true;

    setLoadingState(null, true);

    try {
      final response = await _repository.fetchCoursesForLevelAndSemester(
          level.toString(), semester);

      if (response.data != null) {
        _filteredCourses = response.data ?? [];
        _loadError = null;
      } else {
        _loadError = response.message ?? 'Failed to load filtered courses';
        _filteredCourses = [];
      }
    } catch (e) {
      _loadError = 'An unexpected error occurred: ${e.toString()}';
      _filteredCourses = [];
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  void clearFilter() {
    _selectedLevel = null;
    _selectedSemester = null;
    _hasActiveFilter = false;
    _filteredCourses = [];
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> loadAllCourses() async {
    setLoadingState(null, true);

    try {
      final response = await _repository.fetchAllCourses();

      if (response.data != null) {
        _allCourses = response.data ?? [];
        _loadError = null;
      } else {
        _loadError = response.message ?? 'Failed to load courses';
        _allCourses = [];
      }
    } catch (e) {
      _loadError = 'An unexpected error occurred: ${e.toString()}';
      _allCourses = [];
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  // Future<void> loadCoursesForLevels(String level, int semester) async {
  //   setLoadingState(null, true);

  //   try {
  //     final response = await _repository.fetchCoursesForLevelAndSemester(
  //       level,
  //       semester,
  //     );

  //     if (response.data != null) {
  //       _availableCourses = response.data ?? [];
  //       _loadError = null;
  //     } else {
  //       _loadError = response.message ?? 'Failed to load courses';
  //       _availableCourses = [];
  //     }
  //   } catch (e) {
  //     _loadError = 'An unexpected error occurred: ${e.toString()}';
  //     _availableCourses = [];
  //   } finally {
  //     _isLoadingCourses = false;
  //     notifyListeners();
  //   }
  // }

  // Retry loading courses
  // Future<void> reloadCoursesForLevels(String level, int semester) async {
  //   return loadCoursesForLevels(level, semester);
  // }

  void setLoadingState(String? message, bool loading) {
    _loadError = message;
    _isLoadingCourses = loading;
    notifyListeners();
  }

  bool isCourseSelected(Course course) {
    return _chosenSchools[course] != null;
  }

  String? getCourseSchool(Course course) {
    return _chosenSchools[course];
  }

  void updateCourseSchool(Course course, String? school) {
    clearError();

    if (_chosenSchools[course] == school) {
      _chosenSchools.remove(course);
      _selectedCourses.remove(course);
    } else {
      if (!_selectedCourses.contains(course)) {
        final newTotal = totalCreditHours + (course.creditHours ?? 0);
        if (newTotal > AppConstants.requiredCreditHours) {
          setError('Adding this course would exceed the credit hour limit');
          return;
        }
      }
      _chosenSchools[course] = school;
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
          _selectedCourses.toList(), _chosenSchools);

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
