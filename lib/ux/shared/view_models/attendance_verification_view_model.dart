import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/platform/utils/location_utils.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/platform/services/message_providers/message_providers.dart';
import 'package:attendance_app/ux/shared/models/models.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/online_code_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/qr_scan_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_location_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';

enum AutoFlowResult { success, unauthorized, failed }

class AttendanceVerificationViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel = AppDI.getIt<AuthViewModel>();
  final AttendanceViewModel _attendanceViewModel =
      AppDI.getIt<AttendanceViewModel>();
  final AttendanceLocationViewModel _attendanceLocationViewModel =
      AppDI.getIt<AttendanceLocationViewModel>();
  final QrScanViewModel _qrScanViewModel = AppDI.getIt<QrScanViewModel>();
  final OnlineCodeViewModel _onlineCodeViewModel =
      AppDI.getIt<OnlineCodeViewModel>();
  final VerificationMessageProvider _messageProvider;

  VerificationState _verificationState = const VerificationState();

  AttendanceVerificationViewModel({
    required AuthViewModel authViewModel,
    VerificationMessageProvider? messageProvider,
  }) : _messageProvider =
            messageProvider ?? DefaultVerificationMessageProvider() {
    _attendanceLocationViewModel.checkAttendanceResult
        .addListener(_onLocationResultChanged);
  }

  // ============================================================================
  // STATE ACCESSORS
  // ============================================================================

  VerificationState get verificationState => _verificationState;
  String? get scannedQrCode => _qrScanViewModel.scannedCode;
  String? get enteredOnlineCode => _onlineCodeViewModel.enteredCode;
  bool get isMarkingAttendance => _attendanceViewModel.isMarkingAttendance;
  String? get _studentId => _authViewModel.appUser?.studentProfile?.idNumber;

  /// Direct access to the location check result ValueNotifier
  ValueNotifier<UIResult<AttendanceResult>> get locationCheckResult =>
      _attendanceLocationViewModel.checkAttendanceResult;

  // ============================================================================
  // LOCATION DATA GETTERS (Clean implementation using UIResult)
  // ============================================================================

  /// Get current location result from UIResult
  UIResult<AttendanceResult> get currentLocationUIResult =>
      _attendanceLocationViewModel.checkAttendanceResult.value;

  /// Get attendance result data (null if empty/loading/error)
  AttendanceResult? get currentLocationResult => currentLocationUIResult.data;

  /// Formatted distance (e.g., "150m" or "1.5km")
  String? get formattedDistanceFromCampus =>
      currentLocationResult?.formattedDistance;

  /// Raw distance in meters
  double? get distanceFromCampus => currentLocationResult?.distance;

  /// GPS accuracy in meters
  double? get locationAccuracy => currentLocationResult?.accuracy;

  /// Location method ("GPS" or "Network")
  String? get locationMethod => currentLocationResult?.method;

  /// Complete location information map
  Map<String, dynamic> get locationInfo {
    final result = currentLocationResult;
    final position = result?.position;

    return {
      'distance': result?.formattedDistance ?? 'Unknown',
      'rawDistance': result?.distance,
      'accuracy': position?.accuracy != null
          ? LocationUtils.formatDistance(position!.accuracy)
          : null,
      'formattedAccuracy': position?.accuracy != null
          ? '±${LocationUtils.formatDistance(position!.accuracy)}'
          : 'Unknown',
      'method': result?.method ?? 'Unknown',
      'canAttend': result?.canAttend ?? false,
      'latitude': position?.latitude,
      'longitude': position?.longitude,
    };
  }

  /// Location verification status derived from UIResult
  LocationVerificationStatus? get locationStatus {
    final result = currentLocationUIResult;

    if (result.isEmpty || result.isLoading) {
      return null;
    }

    if (result.isSuccess && result.data?.canAttend == true) {
      return LocationVerificationStatus.successInRange;
    }

    if (result.isError || (result.data?.canAttend == false)) {
      final data = result.data;
      if (data?.distance != null) {
        return LocationVerificationStatus.outOfRange;
      }
      return LocationVerificationStatus.failed;
    }

    return null;
  }

  // ============================================================================
  // STEP STATE CHECKS
  // ============================================================================

  bool get requiresLocationCheck =>
      _verificationState.attendanceType == AttendanceType.inPerson;

  bool get isQrScanning =>
      _verificationState.currentStep == VerificationStep.qrCodeScan &&
      _verificationState.isLoading;

  bool get isLocationChecking =>
      _verificationState.currentStep == VerificationStep.locationCheck &&
      _verificationState.isLoading;

  bool get isSubmittingAttendance =>
      _verificationState.currentStep == VerificationStep.attendanceSubmission &&
      _verificationState.isLoading;

  // ============================================================================
  // LOCATION RESULT LISTENER
  // ============================================================================

  /// Automatically sync VerificationState with location check UIResult
  void _onLocationResultChanged() {
    final result = currentLocationUIResult;

    if (result.isLoading) {
      updateState(
          _verificationState.copyWith(isLoading: true, clearError: true));
    } else if (result.isSuccess) {
      updateState(
          _verificationState.copyWith(isLoading: false, clearError: true));
    } else if (result.isError) {
      updateState(_verificationState.copyWith(
        isLoading: false,
        errorMessage: result.message,
      ));
    }
  }

  // ============================================================================
  // USER LOCATION
  // ============================================================================

  Future<String> getuserLocation() async {
    final position = currentLocationResult?.position;

    if (position != null) {
      try {
        final place = await LocationUtils.getPlaceFromCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
          addCountry: false,
          maxWords: 2,
        );

        if (place != null && !place.toLowerCase().contains('error')) {
          return place;
        }
      } catch (_) {}

      return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    }
    return 'Location unavailable';
  }

  // ============================================================================
  // FLOW CONTROL
  // ============================================================================

  /// Set attendance type and reset flow
  void setAttendanceType(AttendanceType type) {
    final startStep = type == AttendanceType.online
        ? VerificationStep.onlineCodeEntry
        : VerificationStep.qrCodeScan;

    updateState(_verificationState.copyWith(
      attendanceType: type,
      currentStep: startStep,
      clearError: true,
    ));

    // Reset all sub-ViewModels
    _qrScanViewModel.reset();
    _onlineCodeViewModel.reset();
    _attendanceLocationViewModel.resetResult();
  }

  void onQrCodeScanned(String code) {
    _qrScanViewModel.setScannedCode(code);
  }

  void onOnlineCodeEntered(String code) {
    _onlineCodeViewModel.setCode(code);
  }

  // ============================================================================
  // LOCATION CHECKING
  // ============================================================================

  /// Check location - returns true if within range
  Future<bool> checkLocation({String campusId = 'house'}) async {
    if (!requiresLocationCheck) return true;

    updateState(_verificationState.copyWith(isLoading: true, clearError: true));

    try {
      await _attendanceLocationViewModel.checkAttendance(
        campusId: campusId,
        showSettingsOption: true,
      );

      // UIResult updates are handled by listener
      final result = currentLocationUIResult;
      return result.isSuccess && (result.data?.canAttend ?? false);
    } catch (e) {
      updateState(_verificationState.copyWith(
        isLoading: false,
        errorMessage: 'Location check failed: ${e.toString()}',
      ));
      return false;
    }
  }

  /// Retry location check
  Future<bool> retryLocationCheck({
    bool useNetworkOnly = false,
    String campusId = 'house',
  }) async {
    if (!requiresLocationCheck) return true;

    updateState(_verificationState.copyWith(isLoading: true, clearError: true));

    try {
      await _attendanceLocationViewModel.checkAttendance(
        campusId: campusId,
        showSettingsOption: !useNetworkOnly,
      );

      final result = currentLocationUIResult;
      return result.isSuccess && (result.data?.canAttend ?? false);
    } catch (e) {
      updateState(_verificationState.copyWith(
        isLoading: false,
        errorMessage: 'Location retry failed: ${e.toString()}',
      ));
      return false;
    }
  }

  // ============================================================================
  // ATTENDANCE SUBMISSION
  // ============================================================================

  Future<bool> submitAttendance() async {
    if (_studentId == null) {
      updateState(_verificationState.copyWith(
        isLoading: false,
        errorMessage: 'Student ID not found',
      ));
      return false;
    }

    updateState(_verificationState.copyWith(clearError: true));

    try {
      if (_verificationState.attendanceType == AttendanceType.inPerson) {
        return await submitInPersonAttendance();
      } else {
        return await submitOnlineAttendance();
      }
    } catch (e) {
      updateState(_verificationState.copyWith(
        errorMessage: 'Failed to submit attendance: ${e.toString()}',
      ));
      return false;
    }
  }

  Future<bool> submitInPersonAttendance() async {
    final qrCode = _qrScanViewModel.scannedCode;
    if (qrCode == null) {
      updateState(_verificationState.copyWith(
        errorMessage: 'QR code not scanned',
      ));
      return false;
    }

    final locStatus = locationStatus;
    final userLocation = await getuserLocation();
    final position = currentLocationResult?.position;

    if (locStatus == LocationVerificationStatus.successInRange) {
      final result = await _attendanceViewModel.markAttendanceAuthorized(
        code: qrCode,
        studentId: _studentId ?? '',
        location: userLocation,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      if (result.success) {
        return true;
      } else {
        updateState(_verificationState.copyWith(
          errorMessage: result.errorMessage,
        ));
        return false;
      }
    } else if (locStatus == LocationVerificationStatus.outOfRange) {
      // Send unauthorized mark but don't advance UI
      await _attendanceViewModel.markAttendanceUnauthorized(
        code: qrCode,
        studentId: _studentId ?? '',
        location: userLocation,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );
      return false;
    } else {
      updateState(_verificationState.copyWith(
        errorMessage: 'Location verification required',
      ));
      return false;
    }
  }

  Future<bool> submitOnlineAttendance() async {
    final onlineCode = _onlineCodeViewModel.enteredCode;
    if (onlineCode == null) {
      updateState(_verificationState.copyWith(
        errorMessage: 'Online code not entered',
      ));
      return false;
    }

    const userLocation = 'Online';

    final result = await _attendanceViewModel.markAttendanceAuthorized(
      code: onlineCode,
      studentId: _studentId ?? '',
      location: userLocation,
    );

    if (result.success) {
      return true;
    } else {
      String message = result.errorMessage ?? 'Unable to submit attendance';
      final lower = message.toLowerCase();
      final onlineCodeValue = onlineCode.trim();
      final isPlainCode =
          RegExp(r'^[A-Za-z0-9\-]{3,20}$').hasMatch(onlineCodeValue);

      if (lower.contains('unable to find class') && isPlainCode) {
        message =
            '$message — this usually means the attendance code entered is incorrect. '
            'Please check the code and try again.';
      }

      updateState(_verificationState.copyWith(errorMessage: message));
      return false;
    }
  }

  // ============================================================================
  // FLOW NAVIGATION
  // ============================================================================

  void moveToNextStep() {
    VerificationStep nextStep;

    switch (_verificationState.currentStep) {
      case VerificationStep.qrCodeScan:
        nextStep = VerificationStep.locationCheck;
        break;
      case VerificationStep.onlineCodeEntry:
        nextStep = VerificationStep.attendanceSubmission;
        break;
      case VerificationStep.locationCheck:
        nextStep = VerificationStep.attendanceSubmission;
        break;
      case VerificationStep.attendanceSubmission:
        nextStep = VerificationStep.completed;
        break;
      case VerificationStep.completed:
        return;
    }
    updateState(_verificationState.copyWith(currentStep: nextStep));
  }

  Future<AutoFlowResult> proceedWithAutomaticFlow() async {
    // LOCATION CHECK STEP
    if (_verificationState.currentStep == VerificationStep.locationCheck) {
      bool locationSuccess = await checkLocation();

      if (!locationSuccess) {
        final locStatus = locationStatus;
        if (locStatus == LocationVerificationStatus.outOfRange) {
          // Out of range - send unauthorized mark but don't advance UI
          final qrCode = _qrScanViewModel.scannedCode;
          if (qrCode == null) return AutoFlowResult.failed;

          final position = currentLocationResult?.position;
          final userLocation = await getuserLocation();

          await _attendanceViewModel.markAttendanceUnauthorized(
            code: qrCode,
            studentId: _studentId ?? '',
            location: userLocation,
            latitude: position?.latitude,
            longitude: position?.longitude,
          );

          return AutoFlowResult.unauthorized;
        } else {
          return AutoFlowResult.failed;
        }
      }

      moveToNextStep();
    }

    // SUBMISSION STEP
    if (_verificationState.currentStep ==
        VerificationStep.attendanceSubmission) {
      bool submissionSuccess = await submitAttendance();
      if (submissionSuccess) {
        moveToNextStep();
        return AutoFlowResult.success;
      }
      return AutoFlowResult.failed;
    }

    return AutoFlowResult.success;
  }

  // ============================================================================
  // PROGRESS
  // ============================================================================

  double getProgressPercentage() {
    final steps = getRequiredSteps();
    final currentIndex = steps.indexOf(_verificationState.currentStep);
    if (currentIndex == -1) return 0.0;
    return (currentIndex + 1) / steps.length;
  }

  List<VerificationStep> getRequiredSteps() {
    if (_verificationState.attendanceType == AttendanceType.online) {
      return [
        VerificationStep.onlineCodeEntry,
        VerificationStep.attendanceSubmission,
        VerificationStep.completed,
      ];
    } else {
      return [
        VerificationStep.qrCodeScan,
        VerificationStep.locationCheck,
        VerificationStep.attendanceSubmission,
        VerificationStep.completed,
      ];
    }
  }

  // ============================================================================
  // STATE MANAGEMENT
  // ============================================================================

  void updateState(VerificationState newState) {
    _verificationState = newState;
    notifyListeners();
  }

  void resetVerification() {
    _verificationState = const VerificationState();
    _attendanceLocationViewModel.resetResult();
    _qrScanViewModel.reset();
    _onlineCodeViewModel.reset();
    notifyListeners();
  }

  // ============================================================================
  // UI HELPERS
  // ============================================================================

  bool shouldEnableButton() {
    return !_verificationState.isLoading &&
            _verificationState.currentStep ==
                VerificationStep.onlineCodeEntry ||
        locationStatus == LocationVerificationStatus.outOfRange ||
        locationStatus == LocationVerificationStatus.failed ||
        _verificationState.currentStep == VerificationStep.completed;
  }

  bool shouldShowButton() {
    return _verificationState.currentStep == VerificationStep.onlineCodeEntry ||
        locationStatus == LocationVerificationStatus.outOfRange ||
        locationStatus == LocationVerificationStatus.failed ||
        _verificationState.currentStep == VerificationStep.completed;
  }

  // bool shouldShowRetryButton() {
  //   return _verificationState.currentStep == VerificationStep.locationCheck &&
  //       !_verificationState.isLoading &&
  //       _verificationState.errorMessage != null &&
  //       requiresLocationCheck;
  // }

  String getButtonText() => _messageProvider.getButtonText(
        _verificationState.currentStep,
        locationStatus: locationStatus,
      );

  String locationStatusHeaderMessage() {
    if (locationStatus == null) {
      return 'Verifying Location';
    }
    return _messageProvider.getLocationStatusHeaderMessage(locationStatus!);
  }

  String locationStatusMessage() {
    if (locationStatus == null) {
      return 'Checking if you\'re on campus...';
    }
    return _messageProvider.getLocationStatusMessage(locationStatus!);
  }

  @override
  void dispose() {
    _attendanceLocationViewModel.checkAttendanceResult
        .removeListener(_onLocationResultChanged);
    super.dispose();
  }
}
