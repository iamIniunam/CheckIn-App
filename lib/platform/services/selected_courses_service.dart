import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:flutter/material.dart';

class SelectedCourseService extends ChangeNotifier {
  static final SelectedCourseService _instance =
      SelectedCourseService._internal();
  factory SelectedCourseService() => _instance;
  SelectedCourseService._internal();

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

  // Optional: Save to local storage or backend
  Future<void> saveSelectedCourses() async {
    try {
      // TODO: Implement persistence if needed
      debugPrint('Saving ${_selectedCourses.length} courses');
    } catch (e) {
      debugPrint('Error saving selected courses: $e');
    }
  }
}
