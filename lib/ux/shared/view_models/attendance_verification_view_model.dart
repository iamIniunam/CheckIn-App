import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/platform/utils/location_utils.dart';
import 'package:attendance_app/platform/utils/multi_campus_location_helper.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/platform/services/message_providers.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/online_code_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/qr_scan_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_location_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';

class AttendanceVerificationViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel = AppDI.getIt<AuthViewModel>();
  final AttendanceViewModel _attendanceViewModel =
      AppDI.getIt<AttendanceViewModel>();
  final AttendanceLocationViewModel _attendanceLocationViewModel =
      AppDI.getIt<AttendanceLocationViewModel>();
  final QrScanViewModel _qrScanViewModel = AppDI.getIt<QrScanViewModel>();
  final OnlineCodeViewModel _onlineCodeViewModel =
      AppDI.getIt<OnlineCodeViewModel>();
  final MultiCampusLocationHelper _multiCampusHelper =
      AppDI.getIt<MultiCampusLocationHelper>();
  final VerificationMessageProvider _messageProvider;

  ValueNotifier<UIResult<bool>> locationCheckResult =
      ValueNotifier<UIResult<bool>>(UIResult.empty());

  ValueNotifier<UIResult<bool>> attendanceSubmissionResult =
      ValueNotifier<UIResult<bool>>(UIResult.empty());

  AttendanceType _attendanceType = AttendanceType.inPerson;
  VerificationStep _currentStep = VerificationStep.qrCodeScan;

  AttendanceVerificationViewModel({
    required AuthViewModel authViewModel,
    VerificationMessageProvider? messageProvider,
  }) : _messageProvider =
            messageProvider ?? DefaultVerificationMessageProvider() {
    _attendanceLocationViewModel.checkAttendanceResult
        .addListener(_onLocationResultChanged);
  }

  AttendanceType get attendanceType => _attendanceType;
  VerificationStep get currentStep => _currentStep;

  // ============================================================================
  // STATE ACCESSORS
  // ============================================================================

  String? get scannedQrCode => _qrScanViewModel.scannedCode;
  String? get enteredOnlineCode => _onlineCodeViewModel.enteredCode;
  String? get _studentId => _authViewModel.appUser?.studentProfile?.idNumber;

  /// Direct access to the location check result ValueNotifier
  ValueNotifier<UIResult<AttendanceResult>> get attendanceLocationResult =>
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
          ? LocationUtils.formatDistance(position?.accuracy ?? 0.0)
          : null,
      'formattedAccuracy': position?.accuracy != null
          ? '±${LocationUtils.formatDistance(position?.accuracy ?? 0.0)}'
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

  bool get requiresLocationCheck => _attendanceType == AttendanceType.inPerson;

  bool get isQrScanning =>
      _currentStep == VerificationStep.qrCodeScan &&
      locationCheckResult.value.isLoading;

  bool get isLocationChecking =>
      _currentStep == VerificationStep.locationCheck &&
      locationCheckResult.value.isLoading;

  bool get isSubmittingAttendance =>
      _currentStep == VerificationStep.attendanceSubmission &&
      attendanceSubmissionResult.value.isLoading;

  // ============================================================================
  // LOCATION RESULT LISTENER
  // ============================================================================

  /// Automatically sync VerificationState with location check UIResult
  void _onLocationResultChanged() {
    final result = currentLocationUIResult;

    if (result.isLoading) {
      locationCheckResult.value = UIResult.loading();
    } else if (result.isSuccess) {
      final canAttend = result.data?.canAttend ?? false;
      locationCheckResult.value = UIResult.success(
        data: canAttend,
        message: result.message,
      );
    } else if (result.isError) {
      locationCheckResult.value = UIResult.error(message: result.message);
    }

    notifyListeners();
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
    _attendanceType = type;
    _currentStep = type == AttendanceType.online
        ? VerificationStep.onlineCodeEntry
        : VerificationStep.qrCodeScan;

    // Reset all sub-ViewModels and results
    _qrScanViewModel.reset();
    _onlineCodeViewModel.reset();
    _attendanceLocationViewModel.resetResult();
    locationCheckResult.value = UIResult.empty();
    attendanceSubmissionResult.value = UIResult.empty();

    notifyListeners();
  }

  QrScanResult validateAndSetQrCode(String code) {
    final result = _qrScanViewModel.validateAndSetCode(code);

    if (result.isValid) {
      notifyListeners();
    }

    return result;
  }

  bool isValidQrCode(String code) {
    return _qrScanViewModel.isValidCode(code);
  }

  String? getQrValidationError(String code) {
    return _qrScanViewModel.getValidationError(code);
  }

  // void onQrCodeScanned(String code) {
  //   final result = _qrScanViewModel.validateAndSetCode(code);

  //   if (result.isValid) {
  //     notifyListeners();
  //   }
  // }

  OnlineCodeResult validateAndSetOnlineCode(String code) {
    final result = _onlineCodeViewModel.validateAndSetCode(code);

    if (result.isValid) {
      notifyListeners();
    }

    return result;
  }

  bool isValidOnlineCode(String code) {
    return _onlineCodeViewModel.isValidCode(code);
  }

  String? getOnlineCodeValidationError(String code) {
    return _onlineCodeViewModel.getValidationError(code);
  }

  void onOnlineCodeEntered(String code) {
    _onlineCodeViewModel.setCode(code);
  }

  // ============================================================================
  // LOCATION CHECKING
  // ============================================================================

  /// Check location - returns true if within range
  Future<bool> checkLocation(
      {List<String> campusIds = const [
        'seaview',
        'kcc',
        'house',
      ]}) async {
    if (!requiresLocationCheck) return true;

    locationCheckResult.value = UIResult.loading();
    notifyListeners();

    try {
      if (campusIds.length > 1) {
        return await checkLocationAdvanced(campusIds: campusIds);
      } else {
        return await checkLocationSimple(campusIds: campusIds);
      }
    } catch (e) {
      locationCheckResult.value =
          UIResult.error(message: 'Location check failed: ${e.toString()}');
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkLocationSimple({required List<String> campusIds}) async {
    for (final campusId in campusIds) {
      await _attendanceLocationViewModel.checkAttendance(
        campusId: campusId,
        showSettingsOption: campusIds.indexOf(campusId) == 0,
      );
      final result = currentLocationUIResult;

      // If this campus is in range, we're done
      if (result.isSuccess && (result.data?.canAttend ?? false)) {
        locationCheckResult.value = UIResult.success(data: true);
        notifyListeners();
        return true;
      }
    }

    final result = currentLocationUIResult;
    if (result.data != null) {
      locationCheckResult.value = UIResult.error(
        message:
            'You are ${result.data?.formattedDistance} from the nearest campus',
      );
      notifyListeners();
    }

    return false;
  }

  Future<bool> checkLocationAdvanced({required List<String> campusIds}) async {
    final result = await _multiCampusHelper.checkMultipleCampuses(
      campusIds: campusIds,
      showSettingsOption: true,
    );

    debugPrint(
        'AttendanceVerification: multi-campus result -> isWithinRange=${result.isWithinRange}, matched=${result.matchedCampusId}, error=${result.error}');

    if (result.isWithinRange) {
      // Success! Show which campus matched
      locationCheckResult.value = UIResult.success(data: true);
      notifyListeners();
      return true;
    } else {
      // Not in range - show nearest campus info
      locationCheckResult.value =
          UIResult.error(message: result.getErrorMessage());
      notifyListeners();
      return false;
    }
  }

  /// Retry location check
  Future<bool> retryLocationCheck(
      {bool useNetworkOnly = false,
      List<String> campusIds = const ['seaview', 'kcc', 'house']}) async {
    if (!requiresLocationCheck) return true;

    locationCheckResult.value = UIResult.loading();
    notifyListeners();

    try {
      for (final campusId in campusIds) {
        await _attendanceLocationViewModel.checkAttendance(
          campusId: campusId,
          showSettingsOption:
              !useNetworkOnly && campusIds.indexOf(campusId) == 0,
        );

        final result = currentLocationUIResult;

        // If this campus is in range, we're done!
        if (result.isSuccess && (result.data?.canAttend ?? false)) {
          locationCheckResult.value = UIResult.success(data: true);
          notifyListeners();
          return true;
        }
      }

      final result = currentLocationUIResult;
      if (result.data != null) {
        locationCheckResult.value = UIResult.error(
            message:
                'You are ${result.data?.formattedDistance} from the nearest campus');
        notifyListeners();
      }

      return false;
    } catch (e) {
      locationCheckResult.value =
          UIResult.error(message: 'Location retry failed: ${e.toString()}');
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // ATTENDANCE SUBMISSION
  // ============================================================================

  Future<bool> submitAttendance() async {
    if (_studentId == null) {
      attendanceSubmissionResult.value =
          UIResult.error(message: 'Student ID not found');
      notifyListeners();
      return false;
    }

    attendanceSubmissionResult.value = UIResult.loading();
    notifyListeners();

    try {
      if (_attendanceType == AttendanceType.inPerson) {
        return await submitInPersonAttendance();
      } else {
        return await submitOnlineAttendance();
      }
    } catch (e) {
      attendanceSubmissionResult.value = UIResult.error(
          message: 'Failed to submit attendance: ${e.toString()}');
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitInPersonAttendance() async {
    final qrCode = _qrScanViewModel.scannedCode;
    if (qrCode == null) {
      attendanceSubmissionResult.value =
          UIResult.error(message: 'QR code not scanned');
      notifyListeners();
      return false;
    }

    final locStatus = locationStatus;
    final userLocation = await getuserLocation();
    final position = currentLocationResult?.position;

    if (locStatus == LocationVerificationStatus.successInRange) {
      await _attendanceViewModel.markAttendanceAuthorized(
        code: qrCode,
        studentId: _studentId ?? '',
        location: userLocation,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      final result = _attendanceViewModel.markAttendanceResult.value;

      if (result.isSuccess) {
        attendanceSubmissionResult.value =
            UIResult.success(data: true, message: result.message);
        notifyListeners();
        return true;
      } else {
        attendanceSubmissionResult.value = UIResult.error(
            message: result.message ?? 'Failed to mark attendance');
        notifyListeners();
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
      final result = _attendanceViewModel.markAttendanceResult.value;

      if (!result.isSuccess) {
        attendanceSubmissionResult.value = UIResult.error(
            message: result.message ?? 'Location verification failed');
      } else {
        attendanceSubmissionResult.value =
            UIResult.error(message: 'You are too far from campus');
      }
      notifyListeners();
      return false;
    } else {
      attendanceSubmissionResult.value =
          UIResult.error(message: 'Location verification required');
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitOnlineAttendance() async {
    final onlineCode = _onlineCodeViewModel.enteredCode;
    if (onlineCode == null) {
      attendanceSubmissionResult.value =
          UIResult.error(message: 'Online code not entered');
      notifyListeners();
      return false;
    }

    const userLocation = 'Online';

    await _attendanceViewModel.markAttendanceAuthorized(
      code: onlineCode,
      studentId: _studentId ?? '',
      location: userLocation,
    );

    final result = _attendanceViewModel.markAttendanceResult.value;

    if (result.isSuccess) {
      attendanceSubmissionResult.value =
          UIResult.success(data: true, message: result.message);
      notifyListeners();
      return true;
    } else {
      attendanceSubmissionResult.value = UIResult.error(
          message: result.message ?? 'Failed to submit attendance');
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // FLOW NAVIGATION
  // ============================================================================

  void moveToNextStep() {
    switch (_currentStep) {
      case VerificationStep.qrCodeScan:
        _currentStep = VerificationStep.locationCheck;
        break;
      case VerificationStep.onlineCodeEntry:
        _currentStep = VerificationStep.attendanceSubmission;
        break;
      case VerificationStep.locationCheck:
        _currentStep = VerificationStep.attendanceSubmission;
        break;
      case VerificationStep.attendanceSubmission:
        _currentStep = VerificationStep.completed;
        break;
      case VerificationStep.completed:
        return;
    }
    notifyListeners();
  }

  Future<AutoFlowResult> proceedWithAutomaticFlow() async {
    // LOCATION CHECK STEP
    if (_currentStep == VerificationStep.locationCheck) {
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
    if (_currentStep == VerificationStep.attendanceSubmission) {
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
    final currentIndex = steps.indexOf(_currentStep);
    if (currentIndex == -1) return 0.0;
    return (currentIndex + 1) / steps.length;
  }

  List<VerificationStep> getRequiredSteps() {
    if (_attendanceType == AttendanceType.online) {
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

  void resetVerification() {
    _attendanceType = AttendanceType.inPerson;
    _currentStep = VerificationStep.qrCodeScan;

    _attendanceLocationViewModel.resetResult();
    _qrScanViewModel.reset();
    _onlineCodeViewModel.reset();

    locationCheckResult.value = UIResult.empty();
    attendanceSubmissionResult.value = UIResult.empty();

    notifyListeners();
  }

  // ============================================================================
  // UI HELPERS
  // ============================================================================

  bool shouldEnableButton() {
    return !attendanceSubmissionResult.value.isLoading &&
            _currentStep == VerificationStep.onlineCodeEntry ||
        locationStatus == LocationVerificationStatus.outOfRange ||
        locationStatus == LocationVerificationStatus.failed ||
        _currentStep == VerificationStep.completed ||
        attendanceSubmissionResult.value.isError;
  }

  bool shouldShowButton() {
    return _currentStep == VerificationStep.onlineCodeEntry ||
        locationStatus == LocationVerificationStatus.outOfRange ||
        locationStatus == LocationVerificationStatus.failed ||
        _currentStep == VerificationStep.completed ||
        attendanceSubmissionResult.value.isError;
  }

  String getButtonText() => _messageProvider.getButtonText(
        _currentStep,
        locationStatus: locationStatus,
      );

  String locationStatusHeaderMessage() {
    if (locationStatus == null) {
      return 'Verifying Location';
    }
    return _messageProvider.getLocationStatusHeaderMessage(locationStatus);
  }

  String locationStatusMessage() {
    if (locationStatus == null) {
      return 'Checking if you\'re on campus...';
    }
    return _messageProvider.getLocationStatusMessage(locationStatus);
  }

  @override
  void dispose() {
    _attendanceLocationViewModel.checkAttendanceResult
        .removeListener(_onLocationResultChanged);
    super.dispose();
  }
}
