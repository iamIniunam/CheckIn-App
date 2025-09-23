import 'package:attendance_app/platform/services/selected_courses_service.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';

class CourseViewModel extends ChangeNotifier {
  final SelectedCoursesService _selectedCoursesService =
      SelectedCoursesService();

  final Set<Course> _selectedCourses = {};
  final Map<Course, String?> _chosenStreams = {};
  bool _isConfirming = false;
  String? _errorMessage;

  final List<Course> _availableCourses = [
    Course(
        courseCode: 'CS306',
        creditHours: 1,
        courseTitle: 'Computer Architecture Lab'),
    Course(
        courseCode: 'CS311', creditHours: 3, courseTitle: 'Datebase system 1'),
    Course(
        courseCode: 'CE301/CE302',
        creditHours: 3,
        courseTitle: 'Electronic Device & Circuits Electronics Lab'),
    Course(
        courseCode: 'CE303',
        creditHours: 1,
        courseTitle: 'Embedded Microprocessor Systems'),
    Course(
        courseCode: 'EEE303',
        creditHours: 1,
        courseTitle: 'Communication Systems 1'),
    Course(
        courseCode: 'CE304',
        creditHours: 3,
        courseTitle: 'Systems and Signals'),
    Course(
        courseCode: 'CS208',
        creditHours: 3,
        courseTitle: 'Data Communications & Computer Networks 1'),
    Course(
        courseCode: 'ENG307',
        creditHours: 1,
        courseTitle: 'Eng Lab 4 - Microcomputer Tech Lab'),
    Course(
        courseCode: 'ENG306',
        creditHours: 2,
        courseTitle: 'Research Methodology'),
    Course(
        courseCode: 'FAB301',
        creditHours: 0,
        courseTitle: 'Digital Fabrication for Product Development'),
  ];

  List<Course> get availableCourses => List.unmodifiable(_availableCourses);
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
