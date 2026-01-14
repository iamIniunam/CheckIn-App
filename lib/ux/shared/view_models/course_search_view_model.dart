import 'package:attendance_app/platform/data_source/api/api_base_models.dart';
import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/course/models/course_request.dart';
import 'package:attendance_app/platform/data_source/api/course/models/course_response.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CourseSearchViewModel extends ChangeNotifier {
  final Api _api = AppDI.getIt<Api>();

  PagingController<int, Course> coursesPagingController =
      PagingController(firstPageKey: 1);
  int currentPageForCourses = 1;
  List<Course> firstPageAllCourses = [];
  String _searchQuery = '';

  // Filter state
  int? _selectedLevel;
  int? _selectedSemester;
  String? _selectedSchool;
  bool _hasActiveFilter = false;

  // Selected courses state (simplified - just a set of courses)
  final Set<Course> _selectedCourses = {};

  // String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.isNotEmpty;

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

  void applyFilter(int? level, int? semester, String? school) {
    _selectedLevel = level;
    _selectedSemester = semester;
    _selectedSchool = school;
    _hasActiveFilter = level != null || semester != null || school != null;
    notifyListeners();
  }

  void clearFilter() {
    _selectedLevel = null;
    _selectedSemester = null;
    _selectedSchool = null;
    _hasActiveFilter = false;
    notifyListeners();
  }

  Future<ApiResponse<ListDataResponse<Course>>> getPagedCourses(
      {required GetAllCoursesRequest getAllCoursesRequest}) async {
    var result = await _api.courseApi.getAllCourses(
      getAllCoursesRequest: getAllCoursesRequest,
    );

    return result;
  }

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

  void resetPaging() {
    firstPageAllCourses = [];
    currentPageForCourses = 1;
    coursesPagingController.itemList?.clear();

    // Dispose and recreate the controller to clear all listeners
    coursesPagingController.dispose();
    coursesPagingController = PagingController(firstPageKey: 1);

    notifyListeners();
  }

  void clearSelectedCourses() {
    _selectedCourses.clear();
    notifyListeners();
  }

  void clear() {
    _searchQuery = '';
    _selectedLevel = null;
    _selectedSemester = null;
    _selectedSchool = null;
    _hasActiveFilter = false;
    _selectedCourses.clear();
    firstPageAllCourses = [];
    notifyListeners();
  }
}
