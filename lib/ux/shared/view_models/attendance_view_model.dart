import 'package:attendance_app/platform/repositories/course_repository.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:flutter/material.dart';

class AttendanceViewModel extends ChangeNotifier {
  final CourseRepository _courseRepository;

  AttendanceViewModel({CourseRepository? courseRepository})
      : _courseRepository = courseRepository ?? CourseRepository();

  List<CourseAttendanceRecord> _attendanceRecords = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CourseAttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

//Attendance statistics
  int get totalClasses => _attendanceRecords.length;
  int get attendedClasses =>
      _attendanceRecords.where((record) => record.isPresent).length;
  int get missedClasses => totalClasses - attendedClasses;
  double get attendancePercentage =>
      totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0.0;

  Future<void> loadAttendanceRecords(int courseId, String studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _courseRepository.fetchCourseAttendanceRecord(
          courseId, studentId);

      if (response.success && response.data != null) {
        _attendanceRecords = response.data ?? [];
        debugPrint('Successfully loaded ${_attendanceRecords.length} records');
      } else {
        _errorMessage = response.message ?? 'Failed to load attendance records';
        _attendanceRecords = [];
        debugPrint('Failed to load: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _attendanceRecords = [];
      debugPrint('Exception in loadAttendanceRecords: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clear() {
    _attendanceRecords = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
