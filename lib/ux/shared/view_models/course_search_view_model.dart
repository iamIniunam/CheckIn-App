import 'package:attendance_app/platform/utils/course_search_helper.dart';
import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/course/models/course_request.dart';
import 'package:attendance_app/platform/data_source/api/course/models/course_response.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:flutter/material.dart';

class CourseSearchViewModel extends ChangeNotifier {
  final Api _api = AppDI.getIt<Api>();

  // UI Results using ValueNotifier
  ValueNotifier<UIResult<List<Course>>> allCoursesResult =
      ValueNotifier(UIResult.empty());

  // All courses for search
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  String _searchQuery = '';

  // Filter state
  int? _selectedLevel;
  int? _selectedSemester;
  String? _selectedSchool;
  bool _hasActiveFilter = false;

  // Selected courses state (simplified - just a set of courses)
  final Set<Course> _selectedCourses = {};

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

  // Convenience getters for loading state
  bool get isLoadingCourses => allCoursesResult.value.state == UIState.loading;
  String? get loadError => allCoursesResult.value.message;
  bool get hasLoadError => allCoursesResult.value.state == UIState.error;

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
  Future<UIResult<List<Course>>> applyFilter(
    int? level,
    int? semester,
    String? school,
  ) async {
    final hasAnyFilter = level != null || semester != null || school != null;

    if (!hasAnyFilter) {
      clearFilter();
      return UIResult.success(data: _allCourses);
    }

    _selectedLevel = level;
    _selectedSemester = semester;
    _selectedSchool = school;
    _hasActiveFilter = true;

    allCoursesResult.value = UIResult.loading();

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
        } else {
          _filteredCourses = [];
          allCoursesResult.value = UIResult.error(
            message: response.message ?? 'Failed to load filtered courses',
          );
          notifyListeners();
          return allCoursesResult.value;
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

      allCoursesResult.value = UIResult.success(
        data: _filteredCourses,
        message: 'Filter applied successfully',
      );
      notifyListeners();
      return allCoursesResult.value;
    } catch (e) {
      _filteredCourses = [];
      allCoursesResult.value = UIResult.error(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
      notifyListeners();
      return allCoursesResult.value;
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
    allCoursesResult.value = UIResult.success(data: _allCourses);
    notifyListeners();
  }

  // Load all courses
  Future<UIResult<List<Course>>> loadAllCourses() async {
    allCoursesResult.value = UIResult.loading();

    try {
      final response = await _api.courseApi.getAllCourses();

      if (response.status == ApiResponseStatus.Success &&
          response.response != null) {
        _allCourses = response.response as List<Course>;

        allCoursesResult.value = UIResult.success(
          data: _allCourses,
          message: response.message,
        );
        notifyListeners();
        return allCoursesResult.value;
      } else {
        _allCourses = [];

        allCoursesResult.value = UIResult.error(
          message: response.message ?? 'Failed to load courses',
        );
        notifyListeners();
        return allCoursesResult.value;
      }
    } catch (e) {
      _allCourses = [];

      allCoursesResult.value = UIResult.error(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
      notifyListeners();
      return allCoursesResult.value;
    }
  }

  Future<UIResult<List<Course>>> reloadAllCourses() async {
    return loadAllCourses();
  }

  // Simplified course selection - just toggle
  bool isCourseSelected(Course course) {
    return _selectedCourses.contains(course);
  }

  void toggleCourseSelection(Course course) {
    if (_selectedCourses.contains(course)) {
      _selectedCourses.remove(course);
    } else {
      _selectedCourses.add(course);
    }
    notifyListeners();
  }

  void clearSelectedCourses() {
    _selectedCourses.clear();
    notifyListeners();
  }

  void clearError() {
    if (allCoursesResult.value.state == UIState.error) {
      allCoursesResult.value = UIResult.empty();
    }
  }

  // Clear all state (useful on logout)
  void clear() {
    _allCourses = [];
    _filteredCourses = [];
    _searchQuery = '';
    _selectedLevel = null;
    _selectedSemester = null;
    _selectedSchool = null;
    _hasActiveFilter = false;
    _selectedCourses.clear();
    allCoursesResult.value = UIResult.empty();
    notifyListeners();
  }
}
