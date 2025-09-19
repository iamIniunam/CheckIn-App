import 'package:attendance_app/platform/utils/location_service.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class FaceVerificationViewModel extends ChangeNotifier {
  VerificationStep _currentStep = VerificationStep.faceVerification;
  bool _isVerifying = false;
  String? _errorMessage;
  String? _locationStatus;
  Position? _currentPosition;
  double? _distanceFromCampus;
  bool _faceVerificationPassed = false;
  AttendanceType? _attendanceType;

  VerificationStep get currentStep => _currentStep;
  bool get isVerifying => _isVerifying;
  String? get errorMessage => _errorMessage;
  String? get locationStatus => _locationStatus;
  bool get faceVerificationPassed => _faceVerificationPassed;
  double? get distanceFromCampus => _distanceFromCampus;
  AttendanceType? get attendanceType => _attendanceType;

  bool get isFaceVerifying =>
      _currentStep == VerificationStep.faceVerification && _isVerifying;
  bool get isLocationChecking =>
      _currentStep == VerificationStep.locationCheck && _isVerifying;
  bool get isSubmittingAttendance =>
      _currentStep == VerificationStep.attendanceSubmission && _isVerifying;

  bool get requiresLocationCheck => _attendanceType == AttendanceType.inPerson;

  void setAttendanceType(AttendanceType type) {
    _attendanceType = type;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isVerifying = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void setLocationStatus(String? status) {
    _locationStatus = status;
    notifyListeners();
  }

  void moveToNextStep() {
    switch (_currentStep) {
      case VerificationStep.faceVerification:
        if (requiresLocationCheck) {
          _currentStep = VerificationStep.locationCheck;
        } else {
          _currentStep = VerificationStep.attendanceSubmission;
        }
        break;
      case VerificationStep.locationCheck:
        _currentStep = VerificationStep.attendanceSubmission;
        break;
      case VerificationStep.attendanceSubmission:
        _currentStep = VerificationStep.completed;
        break;
      case VerificationStep.completed:
        break;
      default:
    }
    notifyListeners();
  }

  Future<bool> verifyFace() async {
    setError(null);
    setLoading(true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      _faceVerificationPassed = true;
      return true;
    } catch (e) {
      setError('Face verification failed. Please try again');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> checkLocation() async {
    if (!requiresLocationCheck) return true;

    setError(null);
    setLocationStatus('Checking your location...');
    setLoading(true);

    try {
      AttendanceLocationResult result = await LocationService.canMarkAttendance(
        campusLat: AppConstants.campusLat,
        campusLong: AppConstants.campusLong,
        maxDistanceMeters: AppConstants.maxDistanceMeters,
        showSettingsOption: true,
      );

      _currentPosition = result.currentPosition;
      _distanceFromCampus = result.distanceFromCampus;

      if (result.canMarkAttendance) {
        setLocationStatus(
            'Location verified - ${LocationService.formatDistance(result.distanceFromCampus ?? 0)} from campus');
        return true;
      } else {
        setError(result.errorMessage ?? 'Location verification failed');
        setLocationStatus('Location check failed');
        return false;
      }
    } catch (e) {
      setError('Location verification failed: ${e.toString()}');
      setLocationStatus('Location check failed');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> submitAttendance() async {
    setError(null);
    setLoading(true);

    try {
      if (requiresLocationCheck && _currentPosition == null) {
        throw Exception('Location data not available for in-person attendance');
      }

      if (!_faceVerificationPassed) {
        throw Exception('Face verification not completed');
      }

      Map<String, dynamic> attendanceData = {
        'timestamp': DateTime.now().toIso8601String(),
        'faceVerified': _faceVerificationPassed,
        'attendanceType': _attendanceType?.name,
      };

      if (requiresLocationCheck && _currentPosition != null) {
        attendanceData.addAll({
          'latitude': _currentPosition?.latitude,
          'longitude': _currentPosition?.longitude,
          'accuracy': _currentPosition?.accuracy,
          'distanceFromCampus': _distanceFromCampus,
        });
      }

      await Future.delayed(const Duration(seconds: 2));

      debugPrint('Attendance submitted: $attendanceData');
      return true;
    } catch (e) {
      setError('Failed to submit attendance: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> startVerificationFlow({AttendanceType? attendanceType}) async {
    if (attendanceType != null) {
      setAttendanceType(attendanceType);
    }

    if (_currentStep == VerificationStep.faceVerification) {
      bool faceSuccess = await verifyFace();
      if (!faceSuccess) return false;

      moveToNextStep();
      return await proceedWithAutomaticFlow();
    }
    return true;
  }

  Future<bool> proceedWithAutomaticFlow() async {
    if (_currentStep == VerificationStep.locationCheck) {
      bool locationSuccess = await checkLocation();
      if (!locationSuccess) return false;

      moveToNextStep();
    }

    if (_currentStep == VerificationStep.attendanceSubmission) {
      bool submissionSuccess = await submitAttendance();
      if (submissionSuccess) {
        moveToNextStep();
      }
      return submissionSuccess;
    }

    return true;
  }

  void resetVerification() {
    _currentStep = VerificationStep.faceVerification;
    _isVerifying = false;
    _errorMessage = null;
    _locationStatus = null;
    _currentPosition = null;
    _distanceFromCampus = null;
    _faceVerificationPassed = false;
    _attendanceType = null;
    notifyListeners();
  }

  String getStepDescription() {
    switch (_currentStep) {
      case VerificationStep.faceVerification:
        return 'Position your face in the circle and tap verify';
      case VerificationStep.locationCheck:
        return requiresLocationCheck
            ? 'Verifying your location...'
            : 'Location check skipped for online attendance';
      case VerificationStep.attendanceSubmission:
        return requiresLocationCheck
            ? 'Submitting in-person attendance...'
            : 'Submitting online attendance...';
      case VerificationStep.completed:
        return 'Verification completed successfully!';
    }
  }

  String getButtonText(FaceVerificationMode mode) {
    switch (mode) {
      case FaceVerificationMode.signUp:
        return 'Register Face';
      case FaceVerificationMode.attendanceInPerson:
      case FaceVerificationMode.attendanceOnline:
        if (_currentStep == VerificationStep.faceVerification) {
          return 'Verify Face';
        }
        return 'Processing...';
    }
  }

  bool shouldEnableButton() {
    return !_isVerifying && _currentStep == VerificationStep.faceVerification;
  }

  bool shouldShowButton(FaceVerificationMode mode) {
    if (mode == FaceVerificationMode.signUp) return true;
    return _currentStep == VerificationStep.faceVerification;
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

  double getProgressPercentage() {
    final requiredSteps = getRequiredSteps();
    final currentIndex = requiredSteps.indexOf(_currentStep);

    if (currentIndex == -1) return 0.0;

    return (currentIndex + 1) / requiredSteps.length;
  }

  String getAttendanceTypeDisplayName() {
    switch (_attendanceType) {
      case AttendanceType.inPerson:
        return 'In-Person';
      case AttendanceType.online:
        return 'Online';
      case null:
        return 'Not Set';
    }
  }
}

enum VerificationStep {
  faceVerification,
  locationCheck,
  attendanceSubmission,
  completed,
}

enum FaceVerificationMode { signUp, attendanceInPerson, attendanceOnline }

enum AttendanceType { inPerson, online }
