import 'package:attendance_app/platform/services/attendance_service.dart';
import 'package:attendance_app/platform/services/face_verification_service.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/message_providers.dart';
import 'package:attendance_app/ux/shared/models/models.dart.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/view_models/location_verification_view_model.dart';
import 'package:flutter/material.dart';

class FaceVerificationViewModel extends ChangeNotifier {
  VerificationState _state = const VerificationState();
  final LocationVerificationViewModel _locationViewModel;
  final FaceVerificationService _faceService;
  final AttendanceService _attendanceService;
  final VerificationMessageProvider _messageProvider;

  FaceVerificationViewModel({
    FaceVerificationService? faceService,
    AttendanceService? attendanceService,
    VerificationMessageProvider? messageProvider,
    LocationVerificationViewModel? locationViewModel,
  })  : _faceService = faceService ?? MockFaceVerificationService(),
        _attendanceService = attendanceService ?? MockAttendanceService(),
        _messageProvider =
            messageProvider ?? DefaultVerificationMessageProvider(),
        _locationViewModel =
            locationViewModel ?? LocationVerificationViewModel();

  VerificationState get state => _state;
  LocationState get locationState => _locationViewModel.state;

  bool get requiresLocationCheck =>
      _state.attendanceType == AttendanceType.inPerson;
  bool get isFaceVerifying =>
      _state.currentStep == VerificationStep.faceVerification &&
      _state.isLoading;
  bool get isLocationChecking =>
      _state.currentStep == VerificationStep.locationCheck && _state.isLoading;
  bool get isSubmittingAttendance =>
      _state.currentStep == VerificationStep.attendanceSubmission &&
      _state.isLoading;

  bool shouldEnableButton() {
    return !_state.isLoading &&
        _state.currentStep == VerificationStep.faceVerification;
  }

  bool shouldShowButton(FaceVerificationMode mode) {
    if (mode == FaceVerificationMode.signUp) return true;
    return _state.currentStep == VerificationStep.faceVerification;
  }

  bool shouldShowRetryButton() {
    return _state.currentStep == VerificationStep.locationCheck &&
        !_state.isLoading &&
        _state.errorMessage != null &&
        requiresLocationCheck;
  }

  String getButtonText(FaceVerificationMode mode) =>
      _messageProvider.getButtonText(mode, _state.currentStep);

  double getProgressPercentage() {
    final requiredSteps = getRequiredSteps();
    final currentIndex = requiredSteps.indexOf(_state.currentStep);

    if (currentIndex == -1) return 0.0;

    return (currentIndex + 1) / requiredSteps.length;
  }

  void setAttendanceType(AttendanceType type) {
    updateState(_state.copyWith(attendanceType: type));
  }

  Future<bool> startVerificationFlow({AttendanceType? attendanceType}) async {
    if (attendanceType != null) {
      setAttendanceType(attendanceType);
    }

    if (_state.currentStep == VerificationStep.faceVerification) {
      bool faceSuccess = await verifyFace();
      if (!faceSuccess) return false;

      moveToNextStep();
      return await proceedWithAutomaticFlow();
    }
    return true;
  }

  Future<bool> retryLocationCheck({bool useNetworkOnly = false}) async {
    if (!requiresLocationCheck) return true;

    updateState(_state.copyWith(isLoading: true, clearError: true));

    try {
      bool success;
      if (useNetworkOnly) {
        success = await _locationViewModel.retyrWithNetworkOnly(
          campusLat: AppConstants.chisomLat,
          campusLong: AppConstants.chisomLong,
          maxDistanceMeters: AppConstants.maxDistanceMeters,
        );
      } else {
        success = await _locationViewModel.verifyLocation(
          campusLat: AppConstants.chisomLat,
          campusLong: AppConstants.chisomLong,
          maxDistanceMeters: AppConstants.maxDistanceMeters,
          showSettingsOption: false,
        );
      }

      if (!success) {
        updateState(_state.copyWith(
          errorMessage: _locationViewModel.state.statusMessage,
        ));
      }
      return success;
    } finally {
      updateState(_state.copyWith(isLoading: false));
    }
  }

  void resetVerification() {
    _state = const VerificationState();
    _locationViewModel.reset();
    notifyListeners();
  }

  Future<bool> verifyFace() async {
    updateState(_state.copyWith(isLoading: true, clearError: true));

    try {
      bool success = await _faceService.verifyFace();
      if (success) {
        updateState(_state.copyWith(faceVerificationPassed: true));
      } else {
        updateState(_state.copyWith(
          errorMessage: _messageProvider
              .getErrorMessage(VerificationError.faceVerificationFailed),
        ));
      }
      return success;
    } finally {
      updateState(_state.copyWith(isLoading: false));
    }
  }

  Future<bool> checkLocation() async {
    if (!requiresLocationCheck) return true;

    updateState(_state.copyWith(isLoading: true, clearError: true));

    try {
      bool success = await _locationViewModel.verifyLocation(
        campusLat: AppConstants.chisomLat,
        campusLong: AppConstants.chisomLong,
        maxDistanceMeters: AppConstants.maxDistanceMeters,
        showSettingsOption: true,
      );

      if (!success) {
        updateState(_state.copyWith(
            errorMessage: _locationViewModel.state.statusMessage));
      }
      return success;
    } finally {
      updateState(_state.copyWith(isLoading: false));
    }
  }

  Future<bool> submitAttendance() async {
    updateState(_state.copyWith(isLoading: true, clearError: true));

    try {
      if (requiresLocationCheck &&
          _locationViewModel.state.currentPosition == null) {
        throw Exception('Location data not available for in-person attendance');
      }

      if (!_state.faceVerificationPassed) {
        throw Exception('Face verification not completed');
      }

      if (requiresLocationCheck &&
          _locationViewModel.state.verificationStatus !=
              LocationVerificationStatus.successInRange) {
        throw Exception(
            'Location verification required for in-person attendance');
      }

      bool success = await _attendanceService.submitAttendance(
        faceVerified: _state.faceVerificationPassed,
        attendanceType: _state.attendanceType!,
        position: _locationViewModel.state.currentPosition,
        distanceFromCampus: _locationViewModel.state.distanceFromCampus,
        locationMethod: getLocationMethod(),
        isIndoorLocation: _locationViewModel.state.isIndoorLocation,
        locationStatus: _locationViewModel.state.verificationStatus,
      );

      if (!success) {
        updateState(_state.copyWith(
          errorMessage: _messageProvider
              .getErrorMessage(VerificationError.attendanceSubmissionFailed),
        ));
      }

      return success;
    } catch (e) {
      updateState(_state.copyWith(
        errorMessage: _messageProvider.getErrorMessage(
          VerificationError.attendanceSubmissionFailed,
          context: {'details': e.toString()},
        ),
      ));
      return false;
    } finally {
      updateState(_state.copyWith(isLoading: false));
    }
  }

  Future<bool> proceedWithAutomaticFlow() async {
    if (_state.currentStep == VerificationStep.locationCheck) {
      bool locationSuccess = await checkLocation();
      if (!locationSuccess) return false;

      moveToNextStep();
    }

    if (_state.currentStep == VerificationStep.attendanceSubmission) {
      bool submissionSuccess = await submitAttendance();
      if (submissionSuccess) {
        moveToNextStep();
      }
      return submissionSuccess;
    }

    return true;
  }

  void moveToNextStep() {
    VerificationStep nextStep;

    switch (_state.currentStep) {
      case VerificationStep.faceVerification:
        nextStep = requiresLocationCheck
            ? VerificationStep.locationCheck
            : VerificationStep.attendanceSubmission;
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
    updateState(_state.copyWith(currentStep: nextStep));
  }

  void updateState(VerificationState newState) {
    _state = newState;
    notifyListeners();
  }

  String getLocationMethod() {
    final locationState = _locationViewModel.state;
    if (locationState.isNetworkBased) return 'network';
    if (locationState.isIndoorLocation) return 'indoor_gps';
    return 'gps';
  }

  List<VerificationStep> getRequiredSteps() {
    List<VerificationStep> steps = [
      VerificationStep.faceVerification,
      VerificationStep.attendanceSubmission,
      VerificationStep.completed,
    ];

    if (requiresLocationCheck) {
      steps.insert(1, VerificationStep.locationCheck);
    }

    return steps;
  }
}
