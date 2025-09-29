import 'package:attendance_app/platform/services/attendance_service.dart';
import 'package:attendance_app/platform/services/face_verification_service.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/message_providers.dart';
import 'package:attendance_app/ux/shared/models/models.dart.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/view_models/location_verification_view_model.dart';
import 'package:flutter/material.dart';

class FaceVerificationViewModel extends ChangeNotifier {
  VerificationState _verificationState = const VerificationState();
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

  VerificationState get verificationState => _verificationState;
  LocationState get locationState => _locationViewModel.state;

  bool get requiresLocationCheck =>
      _verificationState.attendanceType == AttendanceType.inPerson;
  bool get isFaceVerifying =>
      _verificationState.currentStep == VerificationStep.faceVerification &&
      _verificationState.isLoading;
  bool get isLocationChecking =>
      _verificationState.currentStep == VerificationStep.locationCheck &&
      _verificationState.isLoading;
  bool get isSubmittingAttendance =>
      _verificationState.currentStep == VerificationStep.attendanceSubmission &&
      _verificationState.isLoading;

  bool shouldEnableButton() {
    return !_verificationState.isLoading &&
            _verificationState.currentStep ==
                VerificationStep.faceVerification ||
        _locationViewModel.state.verificationStatus ==
            LocationVerificationStatus.outOfRange ||
        _locationViewModel.state.verificationStatus ==
            LocationVerificationStatus.failed;
  }

  bool shouldShowButton(FaceVerificationMode mode) {
    if (mode == FaceVerificationMode.signUp) return true;
    return _verificationState.currentStep ==
            VerificationStep.faceVerification ||
        _locationViewModel.state.verificationStatus ==
            LocationVerificationStatus.outOfRange ||
        _locationViewModel.state.verificationStatus ==
            LocationVerificationStatus.failed;
    //TODO: complete the action for location verification failed (try again) and find a way to simulate a failed instance
  }

  bool shouldShowRetryButton() {
    return _verificationState.currentStep == VerificationStep.locationCheck &&
        !_verificationState.isLoading &&
        _verificationState.errorMessage != null &&
        requiresLocationCheck;
  }

  String getButtonText(FaceVerificationMode mode) =>
      _messageProvider.getButtonText(mode, _verificationState.currentStep,
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

  double getProgressPercentage() {
    final requiredSteps = getRequiredSteps();
    final currentIndex = requiredSteps.indexOf(_verificationState.currentStep);

    if (currentIndex == -1) return 0.0;

    return (currentIndex + 1) / requiredSteps.length;
  }

  void setAttendanceType(AttendanceType type) {
    updateState(_verificationState.copyWith(attendanceType: type));
  }

  Future<bool> startVerificationFlow({AttendanceType? attendanceType}) async {
    if (attendanceType != null) {
      setAttendanceType(attendanceType);
    }

    if (_verificationState.currentStep == VerificationStep.faceVerification) {
      bool faceSuccess = await verifyFace();
      if (!faceSuccess) return false;

      moveToNextStep();
      return await proceedWithAutomaticFlow();
    }
    return true;
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
          errorMessage: _locationViewModel.state.errorMessage,
        ));
      }
      return success;
    } finally {
      updateState(_verificationState.copyWith(isLoading: false));
    }
  }

  void resetVerification() {
    _verificationState = const VerificationState();
    _locationViewModel.reset();
    notifyListeners();
  }

  Future<bool> verifyFace() async {
    updateState(_verificationState.copyWith(isLoading: true, clearError: true));

    try {
      bool success = await _faceService.verifyFace();
      if (success) {
        updateState(_verificationState.copyWith(faceVerificationPassed: true));
      } else {
        updateState(_verificationState.copyWith(
          errorMessage: _messageProvider
              .getErrorMessage(VerificationError.faceVerificationFailed),
        ));
      }
      return success;
    } finally {
      updateState(_verificationState.copyWith(isLoading: false));
    }
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
            errorMessage: _locationViewModel.state.errorMessage));
      }
      return success;
    } finally {
      updateState(_verificationState.copyWith(isLoading: false));
    }
  }

  Future<bool> submitAttendance() async {
    updateState(_verificationState.copyWith(isLoading: true, clearError: true));

    try {
      if (requiresLocationCheck &&
          _locationViewModel.state.currentPosition == null) {
        throw Exception('Location data not available for in-person attendance');
      }

      if (!_verificationState.faceVerificationPassed) {
        throw Exception('Face verification not completed');
      }

      if (requiresLocationCheck &&
          _locationViewModel.state.verificationStatus !=
              LocationVerificationStatus.successInRange) {
        throw Exception(
            'Location verification required for in-person attendance');
      }

      bool success = await _attendanceService.submitAttendance(
        faceVerified: _verificationState.faceVerificationPassed,
        attendanceType: _verificationState.attendanceType ??
            AttendanceType.inPerson, //TODO: check if this is safe and wise
        position: _locationViewModel.state.currentPosition,
        distanceFromCampus: _locationViewModel.state.distanceFromCampus,
        locationMethod: getLocationMethod(),
        isIndoorLocation: _locationViewModel.state.isIndoorLocation,
        locationStatus: _locationViewModel.state.verificationStatus,
      );

      if (!success) {
        updateState(_verificationState.copyWith(
          errorMessage: _messageProvider
              .getErrorMessage(VerificationError.attendanceSubmissionFailed),
        ));
      }

      return success;
    } catch (e) {
      updateState(_verificationState.copyWith(
        errorMessage: _messageProvider.getErrorMessage(
          VerificationError.attendanceSubmissionFailed,
          context: {'details': e.toString()},
        ),
      ));
      return false;
    } finally {
      updateState(_verificationState.copyWith(isLoading: false));
    }
  }

  Future<bool> proceedWithAutomaticFlow() async {
    if (_verificationState.currentStep == VerificationStep.locationCheck) {
      bool locationSuccess = await checkLocation();
      if (!locationSuccess) return false;

      moveToNextStep();
    }

    if (_verificationState.currentStep ==
        VerificationStep.attendanceSubmission) {
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

    switch (_verificationState.currentStep) {
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
    updateState(_verificationState.copyWith(currentStep: nextStep));
  }

  void updateState(VerificationState newState) {
    _verificationState = newState;
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
