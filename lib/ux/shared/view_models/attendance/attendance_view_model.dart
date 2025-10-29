import 'dart:convert';
import 'package:attendance_app/platform/api/attendance/models/attendance_request.dart';
import 'package:attendance_app/platform/repositories/attendance_repository.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
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
  final AttendanceRepository _attendanceRepository;

  AttendanceViewModel({AttendanceRepository? attendanceRepository})
      : _attendanceRepository = attendanceRepository ?? AttendanceRepository();

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
      // The QR scanner may provide a JSON payload (with sessionId, className, etc.)
      // while the backend likely expects a simple session identifier. Attempt
      // to parse the QR code and extract a sessionId if present, otherwise
      // fall back to sending the raw code string.
      String codeToSend = code;
      try {
        dynamic parsed;
        try {
          parsed = jsonDecode(code);
        } catch (_) {
          // Try URL-decoding then JSON decode (some QR generators URL-encode payload)
          try {
            final decoded = Uri.decodeFull(code);
            parsed = jsonDecode(decoded);
          } catch (_) {
            parsed = null;
          }
        }

        if (parsed is Map<String, dynamic>) {
          if (parsed.containsKey('sessionId')) {
            codeToSend = parsed['sessionId'].toString();
          } else if (parsed.containsKey('session_id')) {
            codeToSend = parsed['session_id'].toString();
          } else if (parsed.containsKey('id')) {
            codeToSend = parsed['id'].toString();
          } else {
            codeToSend = jsonEncode(parsed);
          }
        }
      } catch (_) {
        // ignore parse errors and use the raw code string
      }

      final request = MarkAttendanceRequest(
        code: codeToSend,
        studentId: studentId,
        status: AttendanceStatus.authorized.value,
        location: location,
        latitude: latitude,
        longitude: longitude,
      );

      final response = await _attendanceRepository.markAttendance(request);

      _isMarkingAttendance = false;
      notifyListeners();

      if (response.success) {
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
      // Try to extract a session id from QR payload similar to the authorized flow
      String codeToSend = code;
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
            codeToSend = parsed['sessionId'].toString();
          } else if (parsed.containsKey('session_id')) {
            codeToSend = parsed['session_id'].toString();
          } else if (parsed.containsKey('id')) {
            codeToSend = parsed['id'].toString();
          } else {
            codeToSend = jsonEncode(parsed);
          }
        }
      } catch (_) {
        // ignore
      }

      final request = MarkAttendanceRequest(
        code: codeToSend,
        studentId: studentId,
        status: AttendanceStatus.unauthorized.value,
        location: location,
        latitude: latitude,
        longitude: longitude,
      );

      debugPrint('markAttendanceUnauthorized - Request: ${request.toJson()}');
      final response = await _attendanceRepository.markAttendance(request);

      _isMarkingAttendance = false;
      notifyListeners();

      if (response.success) {
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

  // Future<AttendanceMarkResult> markOnlineAttendance(
  //     {required String code, required String studentId}) async {
  //   _isMarkingAttendance = true;
  //   _markAttendanceError = null;
  //   notifyListeners();

  //   try {
  //     final request = MarkAttendanceRequest(
  //       code: code,
  //       studentId: studentId,
  //       status: AttendanceStatus.authorized.value,
  //     );

  //     final response = await _attendanceRepository.markAttendance(request);

  //     _isMarkingAttendance = false;
  //     notifyListeners();

  //     if (response.success) {
  //       return AttendanceMarkResult.success(response.message);
  //     } else {
  //       _markAttendanceError = response.message ?? 'Failed to mark attendance';
  //       return AttendanceMarkResult.failure(_markAttendanceError ?? '');
  //     }
  //   } catch (e) {
  //     _markAttendanceError = 'An unexpected error occurred: ${e.toString()}';
  //     _isMarkingAttendance = false;
  //     notifyListeners();
  //     return AttendanceMarkResult.failure(_markAttendanceError ?? '');
  //   }
  // }

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
          _lastCourseId ?? 0, _lastStudentId ?? '');

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
