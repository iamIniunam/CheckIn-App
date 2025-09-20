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
  bool _isIndoorLocation = false;
  bool _isNetworkBased = false;

  VerificationStep get currentStep => _currentStep;
  bool get isVerifying => _isVerifying;
  String? get errorMessage => _errorMessage;
  String? get locationStatus => _locationStatus;
  bool get faceVerificationPassed => _faceVerificationPassed;
  double? get distanceFromCampus => _distanceFromCampus;
  AttendanceType? get attendanceType => _attendanceType;
  bool get isIndoorLocation => _isIndoorLocation;
  bool get isNetworkBased => _isNetworkBased;

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
      // Simulate face verification process
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
    setLocationStatus('Checking your location in the building...');
    setLoading(true);

    try {
      AttendanceLocationResult result =
          await LocationService.canMarkAttendanceHybrid(
        campusLat: AppConstants.chisomLat,
        campusLong: AppConstants.chisomLong,
        maxDistanceMeters: AppConstants.maxDistanceMeters,
        showSettingsOption: true,
      );

      _currentPosition = result.currentPosition;
      _distanceFromCampus = result.distanceFromCampus;
      _isIndoorLocation = result.isIndoorLocation;
      _isNetworkBased = result.isNetworkBased;

      if (result.canMarkAttendance) {
        // Enhanced status message based on location type
        String statusMessage;
        if (result.isNetworkBased) {
          statusMessage = 'Location verified using network (GPS weak indoors)';
        } else if (result.isIndoorLocation) {
          statusMessage =
              'Location verified - ${LocationService.formatDistance(result.distanceFromCampus ?? 0)} from campus (indoor GPS)';
        } else {
          statusMessage =
              'Location verified - ${LocationService.formatDistance(result.distanceFromCampus ?? 0)} from campus';
        }

        setLocationStatus(statusMessage);
        return true;
      } else {
        setError(result.errorMessage ?? 'Location verification failed');
        setLocationStatus('Location check failed');
        return false;
      }
    } catch (e) {
      String errorMsg = 'Location verification failed: ${e.toString()}';

      // Provide helpful error messages for building-related issues
      if (e.toString().toLowerCase().contains('timeout') ||
          e.toString().toLowerCase().contains('accuracy')) {
        errorMsg =
            '''Location verification failed - GPS signal weak inside building.

          Try:
          • Moving closer to a window
          • Ensuring WiFi is enabled
          • Going outside briefly to get location''';
      }

      setError(errorMsg);
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
          'locationMethod': _getLocationMethod(),
          'isIndoorLocation': _isIndoorLocation,
        });
      }

      // Simulate API call
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

  String _getLocationMethod() {
    if (_isNetworkBased) return 'network';
    if (_isIndoorLocation) return 'indoor_gps';
    return 'gps';
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

  // Method to retry location check with different settings
  Future<bool> retryLocationCheck({bool useNetworkOnly = false}) async {
    if (!requiresLocationCheck) return true;

    setError(null);
    setLocationStatus(useNetworkOnly
        ? 'Trying network-based location...'
        : 'Retrying location check...');
    setLoading(true);

    try {
      AttendanceLocationResult result;

      if (useNetworkOnly) {
        result = await LocationService.canMarkAttendanceNetworkBased(
          campusLat: AppConstants.chisomLat,
          campusLong: AppConstants.chisomLong,
          maxDistanceMeters: AppConstants.maxDistanceMeters,
        );
      } else {
        result = await LocationService.canMarkAttendanceHybrid(
          campusLat: AppConstants.chisomLat,
          campusLong: AppConstants.chisomLong,
          maxDistanceMeters: AppConstants.maxDistanceMeters,
          showSettingsOption: false, // Don't show settings dialog on retry
        );
      }

      _currentPosition = result.currentPosition;
      _distanceFromCampus = result.distanceFromCampus;
      _isIndoorLocation = result.isIndoorLocation;
      _isNetworkBased = result.isNetworkBased;

      if (result.canMarkAttendance) {
        setLocationStatus('Location verified on retry!');
        return true;
      } else {
        setError('Location retry failed: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      setError('Location retry failed: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
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
    _isIndoorLocation = false;
    _isNetworkBased = false;
    notifyListeners();
  }

  String getStepDescription() {
    switch (_currentStep) {
      case VerificationStep.faceVerification:
        return 'Position your face in the circle and tap verify';
      case VerificationStep.locationCheck:
        if (requiresLocationCheck) {
          if (_isVerifying) {
            return 'Checking location inside building...';
          }
          return 'Verifying your location...';
        }
        return 'Location check skipped for online attendance';
      case VerificationStep.attendanceSubmission:
        return requiresLocationCheck
            ? 'Submitting in-person attendance...'
            : 'Submitting online attendance...';
      case VerificationStep.completed:
        String completionMessage = 'Verification completed successfully!';
        if (_isNetworkBased) {
          completionMessage += '\n(Network location used)';
        } else if (_isIndoorLocation) {
          completionMessage += '\n(Indoor GPS used)';
        }
        return completionMessage;
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

  // Show retry button for location failures
  bool shouldShowRetryButton() {
    return _currentStep == VerificationStep.locationCheck &&
        !_isVerifying &&
        _errorMessage != null &&
        requiresLocationCheck;
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

  // Get location info for display
  String getLocationInfo() {
    if (_currentPosition == null) return 'No location data';

    String info =
        'Distance: ${LocationService.formatDistance(_distanceFromCampus ?? 0)}';

    if (_isNetworkBased) {
      info += '\nMethod: Network location';
    } else if (_isIndoorLocation) {
      info +=
          '\nMethod: Indoor GPS (±${LocationService.formatDistance(_currentPosition!.accuracy)})';
    } else {
      info +=
          '\nMethod: GPS (±${LocationService.formatDistance(_currentPosition!.accuracy)})';
    }

    return info;
  }

  // Check if current error suggests user should try moving to a window
  bool shouldSuggestMovingToWindow() {
    return _errorMessage != null &&
        (_errorMessage!.toLowerCase().contains('accuracy') ||
            _errorMessage!.toLowerCase().contains('timeout') ||
            _errorMessage!.toLowerCase().contains('weak'));
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
