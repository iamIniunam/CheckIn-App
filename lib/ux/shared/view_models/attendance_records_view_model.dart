import 'package:attendance_app/platform/repositories/attendance_repository.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:flutter/material.dart';

class AttendanceRecordsViewModel extends ChangeNotifier {
  final AttendanceRepository _attendanceRepository;

  AttendanceRecordsViewModel({AttendanceRepository? attendanceRepository})
      : _attendanceRepository = attendanceRepository ?? AttendanceRepository();

  List<CourseAttendanceRecord> _attendanceRecords = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  int? _lastCourseId;
  String? _lastStudentId;

  List<CourseAttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
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

    // remember parameters so we can refresh later
    _lastCourseId = courseId;
    _lastStudentId = studentId;

    try {
      final response = await _attendanceRepository.fetchCourseAttendanceRecord(
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

  /// Refreshes the currently loaded attendance records using the last
  /// requested courseId and studentId. This uses [_isRefreshing] so UI can
  /// differentiate between first-load and background refresh.
  Future<void> refresh() async {
    if (_lastCourseId == null || _lastStudentId == null) return;
    // If already refreshing, avoid duplicate refreshes
    if (_isRefreshing) return;

    _isRefreshing = true;
    notifyListeners();

    try {
      final response = await _attendanceRepository.fetchCourseAttendanceRecord(
          _lastCourseId!, _lastStudentId!);

      if (response.success && response.data != null) {
        _attendanceRecords = response.data ?? [];
        _errorMessage = null;
        debugPrint(
            'Successfully refreshed ${_attendanceRecords.length} records');
      } else {
        _errorMessage =
            response.message ?? 'Failed to refresh attendance records';
        _attendanceRecords = [];
        debugPrint('Failed to refresh: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _attendanceRecords = [];
      debugPrint('Exception in refresh: $e');
    } finally {
      _isRefreshing = false;
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
