import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/platform/services/message_providers/message_providers.dart';
import 'package:attendance_app/ux/shared/models/models.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/online_code_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/qr_scan_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/location_verification_view_model.dart';
import 'package:flutter/material.dart';

enum AutoFlowResult { success, unauthorized, failed }

class AttendanceVerificationViewModel extends ChangeNotifier {
  VerificationState _verificationState = const VerificationState();

  final LocationVerificationViewModel _locationViewModel;
  final QrScanViewModel _qrScanViewModel;
  final OnlineCodeViewModel _onlineCodeViewModel;
  final AttendanceViewModel _attendanceViewModel;
  final AuthViewModel _authViewModel;
  // final AttendanceService _attendanceService;
  final VerificationMessageProvider _messageProvider;
  // final FaceVerificationViewModel _faceViewModel; // Future

  AttendanceVerificationViewModel({
    required AuthViewModel authViewModel,
    LocationVerificationViewModel? locationViewModel,
    QrScanViewModel? qrScanViewModel,
    OnlineCodeViewModel? onlineCodeViewModel,
    AttendanceViewModel? attendanceViewModel,
    VerificationMessageProvider? messageProvider,
  })  : _authViewModel = authViewModel,
        _locationViewModel =
            locationViewModel ?? LocationVerificationViewModel(),
        _qrScanViewModel = qrScanViewModel ?? QrScanViewModel(),
        _onlineCodeViewModel = onlineCodeViewModel ?? OnlineCodeViewModel(),
        _attendanceViewModel = attendanceViewModel ?? AttendanceViewModel(),
        _messageProvider =
            messageProvider ?? DefaultVerificationMessageProvider();

  VerificationState get verificationState => _verificationState;
  LocationState get locationState => _locationViewModel.state;
  String? get scannedQrCode => _qrScanViewModel.scannedCode;
  String? get enteredOnlineCode => _onlineCodeViewModel.enteredCode;
  bool get isMarkingAttendance => _attendanceViewModel.isMarkingAttendance;

  String? get _studentId => _authViewModel.currentStudent?.idNumber;

  String getuserLocation() {
    final position = _locationViewModel.state.currentPosition;
    if (position != null) {
      return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    }
    return 'Location unavailable';
  }

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

  // Set attendance type and reset flow
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
    _locationViewModel.reset();
  }

  void onQrCodeScanned(String code) {
    _qrScanViewModel.setScannedCode(code);
    debugPrint('QR code scanned: $code');
  }

  void onOnlineCodeEntered(String code) {
    _onlineCodeViewModel.setCode(code);
    debugPrint('Online code entered: $code');
  }

  Future<bool> checkLocation() async {
    if (!requiresLocationCheck) return true;

    updateState(_verificationState.copyWith(isLoading: true, clearError: true));

    try {
      bool success = await _locationViewModel.verifyLocation(
        campusLat: AppConstants.seaviewLat,
        campusLong: AppConstants.seaviewLong,
        maxDistanceMeters: AppConstants.maxDistanceMeters,
        showSettingsOption: true,
      );

      if (!success) {
        updateState(_verificationState.copyWith(
          isLoading: false,
          errorMessage: _locationViewModel.state.errorMessage,
        ));
      } else {
        updateState(_verificationState.copyWith(isLoading: false));
      }

      return success;
    } catch (e) {
      updateState(_verificationState.copyWith(
        isLoading: false,
        errorMessage: 'Location check failed: ${e.toString()}',
      ));
      return false;
    }
  }

  Future<bool> retryLocationCheck({bool useNetworkOnly = false}) async {
    if (!requiresLocationCheck) return true;

    updateState(_verificationState.copyWith(isLoading: true, clearError: true));

    try {
      bool success;
      if (useNetworkOnly) {
        success = await _locationViewModel.retyrWithNetworkOnly(
          campusLat: AppConstants.seaviewLat,
          campusLong: AppConstants.seaviewLong,
          maxDistanceMeters: AppConstants.maxDistanceMeters,
        );
      } else {
        success = await _locationViewModel.verifyLocation(
          campusLat: AppConstants.seaviewLat,
          campusLong: AppConstants.seaviewLong,
          maxDistanceMeters: AppConstants.maxDistanceMeters,
          showSettingsOption: false,
        );
      }

      if (!success) {
        updateState(_verificationState.copyWith(
          isLoading: false,
          errorMessage: _locationViewModel.state.errorMessage,
        ));
      } else {
        updateState(_verificationState.copyWith(isLoading: false));
      }

      return success;
    } catch (e) {
      updateState(_verificationState.copyWith(
        isLoading: false,
        errorMessage: 'Location retry failed: ${e.toString()}',
      ));
      return false;
    }
  }

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
      debugPrint(
          'submitInPersonAttendance: qrCode is null - aborting submission');
      updateState(_verificationState.copyWith(
        errorMessage: 'QR code not scanned',
      ));
      return false;
    }

    final locationStatus = _locationViewModel.state.verificationStatus;
    final userLocation = getuserLocation();
    final position = _locationViewModel.state.currentPosition;

    if (locationStatus == LocationVerificationStatus.successInRange) {
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
    } else if (locationStatus == LocationVerificationStatus.outOfRange) {
      debugPrint(
          'submitInPersonAttendance: Out of range — sending unauthorized mark.');
      debugPrint(
          'submitInPersonAttendance: code=$qrCode, student=${_studentId ?? ''}, location=$userLocation, lat=${position?.latitude}, lng=${position?.longitude}');

      // Send unauthorized mark, but DO NOT advance the UI flow on success.
      final result = await _attendanceViewModel.markAttendanceUnauthorized(
        code: qrCode,
        studentId: _studentId ?? '',
        location: userLocation,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      debugPrint(
          'markAttendanceUnauthorized result: success=${result.success}, message=${result.message ?? result.errorMessage}');
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
        code: onlineCode, studentId: _studentId ?? '', location: userLocation);

    if (result.success) {
      return true;
    } else {
      // If the backend returned the generic 'Unable to find class' message
      // it's likely because the student entered a wrong/invalid online code.
      // Append a user-friendly hint to the error message so the student
      // understands they should re-check the code.
      String message = result.errorMessage ?? 'Unable to submit attendance';
      final lower = message.toLowerCase();
      // Only append the 'wrong code' hint when the error text looks like the
      // server returned the specific 'Unable to find class' message AND the
      // entered online code is plausibly a user-typed code (not JSON or a
      // long payload). This reduces false positives for unrelated server
      // errors.
      final onlineCodeValue = onlineCode.trim();
      final isPlainCode =
          RegExp(r'^[A-Za-z0-9\-]{3,20}$').hasMatch(onlineCodeValue);
      if (lower.contains('unable to find class') && isPlainCode) {
        message =
            '$message — this usually means the attendance code entered is incorrect. Please check the code and try again.';
      }

      updateState(_verificationState.copyWith(
        errorMessage: message,
      ));
      return false;
    }
  }

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
    debugPrint(
        'proceedWithAutomaticFlow: currentStep=${_verificationState.currentStep}, scannedQr=${_qrScanViewModel.scannedCode}');

    // LOCATION CHECK STEP
    if (_verificationState.currentStep == VerificationStep.locationCheck) {
      bool locationSuccess = await checkLocation();

      // If location check failed because user is out of range, we want to
      // record an "unauthorized" attendance (so devs can see it) but we must
      // NOT advance the UI to the submission content. We'll send the
      // unauthorized mark and then return AutoFlowResult.unauthorized so the
      // caller can end the flow silently.
      if (!locationSuccess) {
        final locStatus = _locationViewModel.state.verificationStatus;
        if (locStatus == LocationVerificationStatus.outOfRange) {
          debugPrint(
              'proceedWithAutomaticFlow: location out-of-range — sending unauthorized mark and ending flow silently');

          final qrCode = _qrScanViewModel.scannedCode;
          if (qrCode == null) {
            debugPrint(
                'proceedWithAutomaticFlow: scanned QR code missing while handling out-of-range; aborting');
            return AutoFlowResult.failed;
          }

          final position = _locationViewModel.state.currentPosition;
          final userLocation = getuserLocation();

          // Fire the unauthorized mark and await result so devs receive it,
          // but do NOT change the visible verification step.
          final result = await _attendanceViewModel.markAttendanceUnauthorized(
            code: qrCode,
            studentId: _studentId ?? '',
            location: userLocation,
            latitude: position?.latitude,
            longitude: position?.longitude,
          );

          debugPrint(
              'proceedWithAutomaticFlow: markAttendanceUnauthorized result: success=${result.success}, message=${result.message ?? result.errorMessage}');

          // Regardless of whether the backend accepted it, do not advance UI.
          return AutoFlowResult.unauthorized;
        } else {
          debugPrint(
              'proceedWithAutomaticFlow: location check failed with status=$locStatus — aborting flow');
          return AutoFlowResult.failed;
        }
      }

      // Location check succeeded — advance to submission step and continue.
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

  void updateState(VerificationState newState) {
    _verificationState = newState;
    notifyListeners();
  }

  void resetVerification() {
    _verificationState = const VerificationState();
    _locationViewModel.reset();
    _qrScanViewModel.reset();
    _onlineCodeViewModel.reset();
    notifyListeners();
  }

  bool shouldEnableButton() {
    return !_verificationState.isLoading &&
            _verificationState.currentStep ==
                VerificationStep.onlineCodeEntry ||
        _locationViewModel.state.verificationStatus ==
            LocationVerificationStatus.outOfRange ||
        _locationViewModel.state.verificationStatus ==
            LocationVerificationStatus.failed ||
        _verificationState.currentStep == VerificationStep.completed;
  }

  bool shouldShowButton() {
    return _verificationState.currentStep == VerificationStep.onlineCodeEntry ||
        _locationViewModel.state.verificationStatus ==
            LocationVerificationStatus.outOfRange ||
        _locationViewModel.state.verificationStatus ==
            LocationVerificationStatus.failed ||
        _verificationState.currentStep == VerificationStep.completed;
    //TODO: complete the action for location verification failed (try again) and find a way to simulate a failed instance
  }

  bool shouldShowRetryButton() {
    return _verificationState.currentStep == VerificationStep.locationCheck &&
        !_verificationState.isLoading &&
        _verificationState.errorMessage != null &&
        requiresLocationCheck;
  }

  String getButtonText() =>
      _messageProvider.getButtonText(_verificationState.currentStep,
          locationStatus: _locationViewModel.state.verificationStatus);

  String locationStatusHeaderMessage() {
    if (_locationViewModel.state.verificationStatus == null) {
      return 'Verifying Location';
    }
    return _messageProvider.getLocationStatusHeaderMessage(
        _locationViewModel.state.verificationStatus ??
            LocationVerificationStatus.successInRange); //TODO: check this again
  }

  String locationStatusMessage() {
    if (_locationViewModel.state.verificationStatus == null) {
      return 'Checking if you\'re on campus...';
    }
    return _messageProvider.getLocationStatusMessage(
        _locationViewModel.state.verificationStatus ??
            LocationVerificationStatus.successInRange); //TODO: check this again
  }
}
