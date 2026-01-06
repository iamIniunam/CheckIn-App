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

  ValueNotifier<UIResult<List<CourseAttendanceRecord>>> courseAttendanceResult =
      ValueNotifier(UIResult.empty());

  final PagingController<int, AttendanceHistory>
      attendanceHistoryPagingController = PagingController(firstPageKey: 1);
  int currentPageForAttendanceHistory = 1;

  PagingController<int, CourseAttendanceRecord>
      courseAttendancePagingController = PagingController(firstPageKey: 1);
  int currentPageForCourseAttendance = 1;

  ValueNotifier<UIResult<AttendanceSummary>> attendanceSummaryResult =
      ValueNotifier(UIResult.empty());

  ValueNotifier<UIResult<String>> markAttendanceResult =
      ValueNotifier(UIResult.empty());

  void resetCourseAttendancePaging() {
    currentPageForCourseAttendance = 1;
    courseAttendancePagingController.dispose();
    courseAttendancePagingController =
        PagingController<int, CourseAttendanceRecord>(firstPageKey: 1);
  }

  Future<ApiResponse<ListDataResponse<CourseAttendanceRecord>>>
      getPaginatedCourseAttendanceRecords(
          {required GetCourseAttendanceRequest
              getCourseAttendanceRequest}) async {
    var response = await _api.attendanceApi
        .getCourseAttendanceRecord(getCourseAttendanceRequest);
    return response;
  }

  Future<ApiResponse<ListDataResponse<CourseAttendanceRecord>>>
      getAttendanceSummary({
    required int courseId,
    required String studentId,
  }) async {
    attendanceSummaryResult.value = UIResult.loading();
    final response = await _api.attendanceApi.getCourseAttendanceRecord(
      GetCourseAttendanceRequest(
        courseId: courseId,
        studentId: studentId,
        pageIndex: 1,
        pageSize: 1,
      ),
    );

    if (response.extra != null) {
      attendanceSummaryResult.value = UIResult.success(
        data: response.extra as AttendanceSummary,
      );
    } else {
      attendanceSummaryResult.value =
          UIResult.error(message: 'Failed to load attendance summary');
    }

    return response;
  }

  void resetAttendanceSummary() {
    attendanceSummaryResult.value = UIResult.empty();
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
    courseAttendanceResult.value = UIResult.empty();
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
