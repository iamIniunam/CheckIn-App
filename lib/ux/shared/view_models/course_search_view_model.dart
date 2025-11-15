import 'package:attendance_app/platform/utils/course_search_helper.dart';
import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/course/models/course_request.dart';
import 'package:attendance_app/platform/data_source/api/course/models/course_response.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:flutter/material.dart';

class CourseSearchViewModel extends ChangeNotifier {
  final Api _api = AppDI.getIt<Api>();

  // All courses for search
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  String _searchQuery = '';
  bool _isLoadingCourses = false;
  String? _loadError;

  // Filter state
  int? _selectedLevel;
  int? _selectedSemester;
  String? _selectedSchool;
  bool _hasActiveFilter = false;

  // Selected courses state (for adding courses)
  final Set<Course> _selectedCourses = {};
  final Map<Course, String?> _chosenSchools = {};
  String? _errorMessage;

  // Getters for courses with search applied
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

  // Filter getters
  int? get selectedLevel => _selectedLevel;
  int? get selectedSemester => _selectedSemester;
  String? get selectedSchool => _selectedSchool;
  bool get hasActiveFilter => _hasActiveFilter;
  String get filterSummary {
    if (!_hasActiveFilter) return 'No Filter';
    List<String> parts = [];
    if (_selectedLevel != null) parts.add('Level: $_selectedLevel');
    if (_selectedSemester != null) parts.add('Semester: $_selectedSemester');
    if (_selectedSchool != null) parts.add('School: $_selectedSchool');

    return parts.isNotEmpty ? parts.join(', ') : 'No Filter';
  }

  // Selected courses getters
  Set<Course> get selectedCourses => Set.unmodifiable(_selectedCourses);
  Map<Course, String?> get chosenSchools => Map.unmodifiable(_chosenSchools);
  String? get errorMessage => _errorMessage;
  int get selectedCoursesCount => _selectedCourses.length;

  int get totalCreditHours => _selectedCourses.fold(
        0,
        (sum, course) => sum + (course.creditHours ?? 0),
      );

  // Search functionality
  void searchCourses(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Filter functionality
  Future<void> applyFilter(int? level, int? semester, String? school) async {
    final hasAnyFilter = level != null || semester != null || school != null;

    if (!hasAnyFilter) {
      clearFilter();
      return;
    }

    _selectedLevel = level;
    _selectedSemester = semester;
    _selectedSchool = school;
    _hasActiveFilter = true;

    _isLoadingCourses = true;
    _loadError = null;
    notifyListeners();

    try {
      List<Course> coursesToFilter;

      if (level != null && semester != null) {
        final request = GetCoursesForLevelAndSemesterRequest(
          levelId: level.toString(),
          semesterId: semester.toString(),
        );

        final response =
            await _api.courseApi.getCoursesForLevelAndSemester(request);

        if (response.status == ApiResponseStatus.Success &&
            response.response != null) {
          coursesToFilter = response.response as List<Course>;
          _loadError = null;
        } else {
          _loadError = response.message ?? 'Failed to load filtered courses';
          _filteredCourses = [];
          return;
        }
      } else {
        if (_allCourses.isEmpty) {
          await loadAllCourses();
        }
        coursesToFilter = _allCourses;
      }

      _filteredCourses = applyClientSideFilters(
        coursesToFilter,
        level: level,
        semester: semester,
        school: school,
      );

      _loadError = null;
    } catch (e) {
      _loadError = 'An unexpected error occurred: ${e.toString()}';
      _filteredCourses = [];
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  List<Course> applyClientSideFilters(
    List<Course> courses, {
    int? level,
    int? semester,
    String? school,
  }) {
    return courses.where((course) {
      if (level != null && course.level?.toString() != level.toString()) {
        return false;
      }
      if (semester != null &&
          course.semester?.toString() != semester.toString()) {
        return false;
      }
      if (school != null && course.school != school) {
        return false;
      }
      return true;
    }).toList();
  }

  void clearFilter() {
    _selectedLevel = null;
    _selectedSemester = null;
    _selectedSchool = null;
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
      final response = await _api.courseApi.getAllCourses();

      if (response.status == ApiResponseStatus.Success &&
          response.response != null) {
        _allCourses = response.response as List<Course>;
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

  Future<void> reloadAllCourses() async {
    return loadAllCourses();
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
