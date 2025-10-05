import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:flutter/material.dart';

class SelectedCoursesService extends ChangeNotifier {
  static final SelectedCoursesService _instance =
      SelectedCoursesService._internal();
  factory SelectedCoursesService() => _instance;
  SelectedCoursesService._internal();

  List<Course> _selectedCourses = [];
  Map<String, String> _selectedStreams = {};

  List<Course> get selectedCourses => List.unmodifiable(_selectedCourses);
  Map<String, String> get selectedStreams => Map.unmodifiable(_selectedStreams);

  void updateSelectedCourses(
      List<Course> courses, Map<Course, String?> streams) {
    _selectedCourses = List.from(courses);
    _selectedStreams = {};

    for (final course in courses) {
      final stream = streams[course];
      if (stream != null) {
        _selectedStreams[course.courseCode] = stream;
      }
    }

    notifyListeners();
  }

  void clearSelectedCourses() {
    _selectedCourses.clear();
    _selectedStreams.clear();
    notifyListeners();
  }

  String? getStreamForCourse(String courseCode) {
    return _selectedStreams[courseCode];
  }

  int get totalCreditHours => _selectedCourses.fold(
        0,
        (sum, course) => sum + (course.creditHours ?? 0),
      );

  Future<void> saveSelectedCourses() async {
    try {} catch (e) {
      debugPrint('Error saving selected courses: $e');
    }
  }
}
