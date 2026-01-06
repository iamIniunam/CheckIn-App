import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/api_base_models.dart';
import 'package:attendance_app/platform/data_source/api/attendance/models/attedance_response.dart';
import 'package:attendance_app/platform/data_source/api/attendance/models/attendance_request.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/qr_scan_view_model.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class AttendanceViewModel extends ChangeNotifier {
  final Api _api = AppDI.getIt<Api>();
  final QrScanViewModel _qrScanViewModel = AppDI.getIt<QrScanViewModel>();

  final Map<int, List<CourseAttendanceRecord>> _courseAttendanceCache = {};
  ValueNotifier<UIResult<List<CourseAttendanceRecord>>> courseAttendanceResult =
      ValueNotifier(UIResult.empty());
  int? _lastCourseId;
  String? _lastStudentIdForCourse;
  final PagingController<int, AttendanceHistory>
      attendanceHistoryPagingController = PagingController(firstPageKey: 1);
  int currentPageForAttendanceHistory = 1;
  ValueNotifier<UIResult<String>> markAttendanceResult =
      ValueNotifier(UIResult.empty());

  Future<void> fetchCourseAttendanceRecords(
      int courseId, String studentId) async {
    courseAttendanceResult.value = UIResult.loading();

    _lastCourseId = courseId;
    _lastStudentIdForCourse = studentId;

    try {
      final request = GetCourseAttendanceRequest(
        courseId: courseId,
        studentId: studentId,
      );

      final response =
          await _api.attendanceApi.getCourseAttendanceRecord(request);

      if (response.status == ApiResponseStatus.Success &&
          response.response != null) {
        final records = response.response as List<CourseAttendanceRecord>;
        _courseAttendanceCache[courseId] = records;

        courseAttendanceResult.value =
            UIResult.success(data: records, message: response.message);
        notifyListeners();
      } else {
        _courseAttendanceCache[courseId] = [];
        courseAttendanceResult.value = UIResult.error(
          message: response.message ?? 'Failed to load attendance records',
        );
      }
    } catch (e) {
      _courseAttendanceCache[courseId] = [];
      courseAttendanceResult.value = UIResult.error(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  List<CourseAttendanceRecord> getCourseAttendanceRecords(int courseId) {
    return _courseAttendanceCache[courseId] ?? [];
  }

  int totalClasses(int courseId) {
    return getCourseAttendanceRecords(courseId).length;
  }

  int attendedClasses(int courseId) {
    return getCourseAttendanceRecords(courseId)
        .where((record) => record.isPresent)
        .length;
  }

  int missedClasses(int courseId) {
    return totalClasses(courseId) - attendedClasses(courseId);
  }

  int attendancePercentage(int courseId) {
    final total = totalClasses(courseId);
    final attended = attendedClasses(courseId);
    return total > 0 ? ((attended / total) * 100).toInt() : 0;
  }

  Future<void> refreshCourseAttendance() async {
    if (_lastCourseId == null || _lastStudentIdForCourse == null) return;
    await fetchCourseAttendanceRecords(
        _lastCourseId ?? 0, _lastStudentIdForCourse ?? '');
  }

  Future<ApiResponse<ListDataResponse<AttendanceHistory>>>
      getPaginatedAttendanceHistory(
          {required GetAttendanceHistoryRequest
              getAttendanceHistoryRequest}) async {
    var response = await _api.attendanceApi
        .getAttendanceHistory(getAttendanceHistoryRequest);
    return response;
  }

  Future<void> markAttendanceAuthorized({
    required String code,
    required String studentId,
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    markAttendanceResult.value = UIResult.loading();

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

      if (!markAttendanceResult.value.isLoading) return;

      if (response.status == ApiResponseStatus.Success) {
        markAttendanceResult.value = UIResult.success(
          data: response.message ?? 'Attendance marked successfully',
          message: response.message,
        );
      } else {
        markAttendanceResult.value = UIResult.error(
          message: response.message ?? 'Failed to mark attendance',
        );
      }
    } catch (e) {
      markAttendanceResult.value = UIResult.error(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<void> markAttendanceUnauthorized({
    required String code,
    required String studentId,
    required String? location,
    double? latitude,
    double? longitude,
  }) async {
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

      if (!markAttendanceResult.value.isLoading) return;

      if (response.status == ApiResponseStatus.Success) {
        markAttendanceResult.value = UIResult.success(
          data: response.message ?? 'Attendance marked successfully',
          message: response.message,
        );
      } else {
        markAttendanceResult.value = UIResult.error(
          message: response.message ?? 'Failed to mark attendance',
        );
      }
    } catch (e) {
      markAttendanceResult.value = UIResult.error(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  String _extractSessionId(String code) {
    final uuid = _qrScanViewModel.extractUuid(code);
    return uuid ?? code;
  }

  void clear() {
    _courseAttendanceCache.clear();
    _lastCourseId = null;
    _lastStudentIdForCourse = null;
    courseAttendanceResult.value = UIResult.empty();

    // if (_isListenerAttachedForAttendanceHistory) {
    //   attendanceHistoryPagingController
    //       .removePageRequestListener(_fetchAttendanceHistoryPage);
    // }
    currentPageForAttendanceHistory = 1;

    markAttendanceResult.value = UIResult.empty();
    notifyListeners();
  }

  @override
  void dispose() {
    attendanceHistoryPagingController.dispose();
    courseAttendanceResult.dispose();
    markAttendanceResult.dispose();
    super.dispose();
  }
}
