// import 'dart:convert';

// import 'package:attendance_app/ux/shared/models/ui_models.dart';
// import 'package:attendance_app/ux/shared/resources/app_constants.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SelectedCourseService extends ChangeNotifier {
//   static final SelectedCourseService _instance =
//       SelectedCourseService._internal();
//   factory SelectedCourseService() => _instance;
//   SelectedCourseService._internal();

//   List<Course> _selectedCourses = [];
//   Map<String, String> _selectedStreams = {};

//   List<Course> get selectedCourses => List.unmodifiable(_selectedCourses);
//   Map<String, String> get selectedStreams => Map.unmodifiable(_selectedStreams);

//   Future<void> updateSelectedCourses(
//       List<Course> courses, Map<Course, String?> streams) async {
//     _selectedCourses = List.from(courses);
//     _selectedStreams = {};

//     for (final course in courses) {
//       final stream = streams[course];
//       if (stream != null) {
//         _selectedStreams[course.courseCode] = stream;
//       }
//     }

//     // Persist selection to SharedPreferences
//     try {
//       final pref = await SharedPreferences.getInstance();
//       final coursesJson =
//           jsonEncode(_selectedCourses.map((c) => c.toJson()).toList());
//       final streamsJson = jsonEncode(_selectedStreams);
//       await pref.setString(AppConstants.selectedCoursesKey, coursesJson);
//       await pref.setString(AppConstants.selectedSchoolsKey, streamsJson);
//     } catch (e) {
//       debugPrint('Error persisting selected courses: $e');
//     }

//     notifyListeners();
//   }

//   Future<void> clearSelectedCourses() async {
//     _selectedCourses.clear();
//     _selectedStreams.clear();

//     try {
//       final pref = await SharedPreferences.getInstance();
//       await pref.remove(AppConstants.selectedCoursesKey);
//       await pref.remove(AppConstants.selectedSchoolsKey);
//     } catch (e) {
//       debugPrint('Error clearing persisted selected courses: $e');
//     }

//     notifyListeners();
//   }

//   String? getStreamForCourse(String courseCode) {
//     return _selectedStreams[courseCode];
//   }

//   int get totalCreditHours => _selectedCourses.fold(
//         0,
//         (sum, course) => sum + (course.creditHours ?? 0),
//       );

//   // Optional: Save to local storage or backend
//   Future<void> saveSelectedCourses() async {
//     try {
//       // TODO: Implement persistence if needed
//       debugPrint('Saving ${_selectedCourses.length} courses');
//     } catch (e) {
//       debugPrint('Error saving selected courses: $e');
//     }
//   }
// }
