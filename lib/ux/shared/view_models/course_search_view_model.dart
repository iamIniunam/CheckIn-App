import 'package:attendance_app/platform/course_search_helper.dart';
import 'package:attendance_app/platform/repositories/course_repository.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:flutter/material.dart';

class CourseSearchViewModel extends ChangeNotifier {
  final CourseRepository _repository;

  CourseSearchViewModel({CourseRepository? repository})
      : _repository = repository ?? CourseRepository();

//All courses for search
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  String _searchQuery = '';
  bool _isLoadingCourses = false;
  String? _loadError;

  //Filter state
  int? _selectedLevel;
  int? _selectedSemester;
  bool _hasActiveFilter = false;

  //Selected courses state (for adding courses)
  final Set<Course> _selectedCourses = {};
  final Map<Course, String?> _chosenSchools = {};
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
    if (!_hasActiveFilter) return 'No Filter';
    return 'Level: ${_selectedLevel ?? ''}, Semester: ${_selectedSemester ?? ''}';
  }

  //Selected courses getters
  Set<Course> get selectedCourses => Set.unmodifiable(_selectedCourses);
  Map<Course, String?> get chosenSchools => Map.unmodifiable(_chosenSchools);
  String? get errorMessage => _errorMessage;
  int get selectedCoursesCount => _selectedCourses.length;

  int get totalCreditHours => _selectedCourses.fold(
        0,
        (sum, course) => sum + (course.creditHours ?? 0),
      );

  //Search functionality
  void searchCourses(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Filter functionality
  Future<void> applyFilter(int? level, int? semester) async {
    if (level == null || semester == null) {
      clearFilter();
      return;
    }

    _selectedLevel = level;
    _selectedSemester = semester;
    _hasActiveFilter = true;

    _isLoadingCourses = true;
    _loadError = null;
    notifyListeners();

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
    _loadError = null;
    notifyListeners();
  }

  // Load all courses
  Future<void> loadAllCourses() async {
    _isLoadingCourses = true;
    _loadError = null;
    notifyListeners();

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

  bool isCourseSelected(Course course) {
    return _chosenSchools[course] != null;
  }

  String? getChosenSchoolForCourse(Course course) {
    return _chosenSchools[course];
  }

  void updateChosenSchool(Course course, String? school) {
    _errorMessage = null;

    if (_chosenSchools[course] == school) {
      _chosenSchools.remove(course);
      _selectedCourses.remove(course);
    } else {
      _chosenSchools[course] = school;
      _selectedCourses.add(course);
    }
    notifyListeners();
  }

  void clearSelectedCourses() {
    _selectedCourses.clear();
    _chosenSchools.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
