import 'dart:convert';
import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/attendance/models/attedance_response.dart';
import 'package:attendance_app/platform/data_source/api/attendance/models/attendance_request.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:flutter/material.dart';

class AttendanceMarkResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  const AttendanceMarkResult({
    required this.success,
    this.message,
    this.errorMessage,
  });

  factory AttendanceMarkResult.success([String? message]) {
    return AttendanceMarkResult(
      success: true,
      message: message ?? 'Attendance marked successfully',
    );
  }

  factory AttendanceMarkResult.failure(String errorMessage) {
    return AttendanceMarkResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

class AttendanceViewModel extends ChangeNotifier {
  final Api _api = AppDI.getIt<Api>();

  List<CourseAttendanceRecord> _attendanceRecords = [];
  bool _isMarkingAttendance = false;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  String? _markAttendanceError;
  int? _lastCourseId;
  String? _lastStudentId;

  List<CourseAttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get isMarkingAttendance => _isMarkingAttendance;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  String? get markAttendanceError => _markAttendanceError;
  bool get hasError => _errorMessage != null;
  bool get hasMarkAttendanceError => _markAttendanceError != null;

  // Attendance statistics
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

    _lastCourseId = courseId;
    _lastStudentId = studentId;

    try {
      final request = GetCourseAttendanceRequest(
        courseId: courseId,
        studentId: studentId,
      );

      final response =
          await _api.attendanceApi.getCourseAttendanceRecord(request);

      if (response.status == ApiResponseStatus.Success &&
          response.response != null) {
        _attendanceRecords = response.response as List<CourseAttendanceRecord>;
        _errorMessage = null;
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

  Future<AttendanceMarkResult> markAttendanceAuthorized({
    required String code,
    required String studentId,
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    _isMarkingAttendance = true;
    _markAttendanceError = null;
    notifyListeners();

    try {
      String codeToSend = _extractSessionId(code);

      final request = MarkAttendanceRequest(
        code: codeToSend,
        studentId: studentId,
        status: AttendanceStatus.authorized.value,
        location: location,
        latitude: latitude,
        longitude: longitude,
      );

      final response = await _api.attendanceApi.markAttendance(request);

      _isMarkingAttendance = false;
      notifyListeners();

      if (response.status == ApiResponseStatus.Success) {
        return AttendanceMarkResult.success(response.message);
      } else {
        _markAttendanceError = response.message ?? 'Failed to mark attendance';
        return AttendanceMarkResult.failure(_markAttendanceError ?? '');
      }
    } catch (e) {
      _markAttendanceError = 'An unexpected error occurred: ${e.toString()}';
      _isMarkingAttendance = false;
      notifyListeners();
      return AttendanceMarkResult.failure(_markAttendanceError ?? '');
    }
  }

  Future<AttendanceMarkResult> markAttendanceUnauthorized({
    required String code,
    required String studentId,
    required String? location,
    double? latitude,
    double? longitude,
  }) async {
    _isMarkingAttendance = true;
    _markAttendanceError = null;
    notifyListeners();

    try {
      String codeToSend = _extractSessionId(code);

      final request = MarkAttendanceRequest(
        code: codeToSend,
        studentId: studentId,
        status: AttendanceStatus.unauthorized.value,
        location: location,
        latitude: latitude,
        longitude: longitude,
      );

      debugPrint('markAttendanceUnauthorized - Request: ${request.toMap()}');
      final response = await _api.attendanceApi.markAttendance(request);

      _isMarkingAttendance = false;
      notifyListeners();

      if (response.status == ApiResponseStatus.Success) {
        return AttendanceMarkResult.success(response.message);
      } else {
        _markAttendanceError = response.message ?? 'Failed to mark attendance';
        return AttendanceMarkResult.failure(_markAttendanceError ?? '');
      }
    } catch (e) {
      _markAttendanceError = 'An unexpected error occurred: ${e.toString()}';
      _isMarkingAttendance = false;
      notifyListeners();
      return AttendanceMarkResult.failure(_markAttendanceError ?? '');
    }
  }

  String _extractSessionId(String code) {
    try {
      dynamic parsed;
      try {
        parsed = jsonDecode(code);
      } catch (_) {
        try {
          final decoded = Uri.decodeFull(code);
          parsed = jsonDecode(decoded);
        } catch (_) {
          parsed = null;
        }
      }

      if (parsed is Map<String, dynamic>) {
        if (parsed.containsKey('sessionId')) {
          return parsed['sessionId'].toString();
        } else if (parsed.containsKey('session_id')) {
          return parsed['session_id'].toString();
        } else if (parsed.containsKey('id')) {
          return parsed['id'].toString();
        } else {
          return jsonEncode(parsed);
        }
      }
    } catch (_) {
      // Ignore parse errors
    }
    return code;
  }

  Future<void> refresh() async {
    if (_lastCourseId == null || _lastStudentId == null) return;
    if (_isRefreshing) return;

    _isRefreshing = true;
    notifyListeners();

    try {
      final request = GetCourseAttendanceRequest(
        courseId: _lastCourseId!,
        studentId: _lastStudentId!,
      );

      final response =
          await _api.attendanceApi.getCourseAttendanceRecord(request);

      if (response.status == ApiResponseStatus.Success &&
          response.response != null) {
        _attendanceRecords = response.response as List<CourseAttendanceRecord>;
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

  void clearMarkAttendanceError() {
    _markAttendanceError = null;
    notifyListeners();
  }

  void clear() {
    _attendanceRecords = [];
    _errorMessage = null;
    _markAttendanceError = null;
    _isLoading = false;
    _isMarkingAttendance = false;
    notifyListeners();
  }
}
