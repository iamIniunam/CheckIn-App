// import 'package:attendance_app/platform/services/location_service.dart';
// import 'package:attendance_app/ux/shared/resources/app_constants.dart';
// import 'package:attendance_app/ux/shared/view_models/user_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// class VerificationViewModel extends ChangeNotifier {
//   bool _isCheckingLocation = false;
//   String? _locationError;
//   String? _locationStatus;
//   late UserViewModel viewModel;

//   bool get isCheckingLocation => _isCheckingLocation;
//   String? get locationError => _locationError;
//   String? get locationStatus => _locationStatus;

//   Future<bool> markAttendance() async {
//     _isCheckingLocation = true;
//     _locationError = null;
//     _locationStatus = 'Checking location for building...';
//     notifyListeners();

//     try {
//       AttendanceLocationResult result =
//           await LocationService.canMarkAttendanceHybrid(
//               campusLat: AppConstants.chisomLat,
//               campusLong: AppConstants.chisomLong,
//               maxDistanceMeters: AppConstants.maxDistanceMeters,
//               showSettingsOption: true);

//       if (!result.canMarkAttendance) {
//         _locationError = result.errorMessage;
//         _locationStatus = 'Location check failed';
//         setLoadingState(false);
//         return false;
//       }

//       _locationStatus = 'Location verified! Submitting attendance...';
//       notifyListeners();

//       if (result.currentPosition == null) {
//         _locationError = 'Failed to get current position';
//         _locationStatus = 'Attendance failed';
//         setLoadingState(false);
//         return false;
//       }

//       await submitAttendance(result.currentPosition!); //TODO null check

//       _locationStatus = 'Attendance marked successfully!';
//       setLoadingState(false);
//       return true;
//     } catch (e) {
//       _locationError = 'Failed to mark attendance: ${e.toString()}';
//       _locationStatus = 'Attendance failed';
//       setLoadingState(false);
//       return false;
//     }
//   }

//   void setLoadingState(bool loading) {
//     _isCheckingLocation = loading;
//     if (!loading) {
//       Future.delayed(const Duration(seconds: 3), () {
//         _locationStatus = null;
//         notifyListeners();
//       });
//     }
//     notifyListeners();
//   }

//   Future<void> submitAttendance(Position position) async {
//     Map<String, dynamic> attendanceData = {
//       // 'studentId': viewModel.idNumber,
//       'timestamp': DateTime.now().toIso8601String(),
//       'latitude': position.latitude,
//       'longitude': position.longitude,
//       'accuracy': position.accuracy,
//       'locationMethod': position.accuracy > 50 ? 'indoor_gps' : 'gps',
//     };

//     debugPrint('Attendance submitted: $attendanceData');
//   }

//   Future<String> checkLocationStatus() async {
//     try {
//       _locationStatus = 'Checking your location...';
//       notifyListeners();

//       AttendanceLocationResult result =
//           await LocationService.canMarkAttendanceHybrid(
//         campusLat: AppConstants.chisomLat,
//         campusLong: AppConstants.chisomLong,
//         maxDistanceMeters: AppConstants.maxDistanceMeters,
//         showSettingsOption: false,
//       );

//       String status;
//       if (result.canMarkAttendance) {
//         if (result.isNetworkBased) {
//           status = 'You appear to be on campus (network location)';
//         } else if (result.isIndoorLocation) {
//           status =
//               'You are on campus (indoor GPS, accuracy: ±${LocationService.formatDistance(result.accuracy ?? 0)})';
//         } else {
//           status = 'You are on campus and can mark attendance';
//         }
//       } else {
//         status = result.errorMessage ??
//             'Cannot mark attendance from current location';
//       }

//       _locationStatus = status;
//       notifyListeners();

//       return status;
//     } catch (e) {
//       String errorMsg = 'Location check failed: ${e.toString()}';
//       _locationStatus = errorMsg;
//       notifyListeners();
//       return errorMsg;
//     }
//   }

//   Future<void> testLocationAccuracy() async {
//     _isCheckingLocation = true;
//     _locationStatus = 'Testing location accuracy...';
//     notifyListeners();

//     try {
//       Position position = await LocationService.getCurrentLocation();

//       double distance = LocationService.calculateDistanceFromCampus(
//         currentPosition: position,
//         campusLat: AppConstants.chisomLat,
//         campusLong: AppConstants.chisomLong,
//       );

//       _locationStatus = '''Location Test Results:
//         Your coordinates: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}
//         School coordinates: ${AppConstants.chisomLat}, ${AppConstants.chisomLong}
//         Distance: ${LocationService.formatDistance(distance)}
//         GPS Accuracy: ±${LocationService.formatDistance(position.accuracy)}
//         Max allowed: ${LocationService.formatDistance(AppConstants.maxDistanceMeters)}''';
//     } catch (e) {
//       _locationStatus = 'Location test failed: ${e.toString()}';
//     } finally {
//       _isCheckingLocation = false;
//       notifyListeners();
//     }
//   }

//   void clearLocationStatus() {
//     _locationStatus = null;
//     _locationError = null;
//     notifyListeners();
//   }
// }

import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/platform/services/message_providers/message_providers.dart';
import 'package:attendance_app/ux/shared/models/models.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/online_code_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/qr_scan_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/location_verification_view_model.dart';
import 'package:flutter/material.dart';

class AttendanceVerificationViewModel extends ChangeNotifier {
  VerificationState _verificationState = const VerificationState();

  final LocationVerificationViewModel _locationViewModel;
  final QrScanViewModel _qrScanViewModel;
  final OnlineCodeViewModel _onlineCodeViewModel;
  final AttendanceViewModel _attendanceViewModel;
  // final AttendanceService _attendanceService;
  final VerificationMessageProvider _messageProvider;
  // final FaceVerificationViewModel _faceViewModel; // Future

  String? _studentId;
  String? _userLocation;

  AttendanceVerificationViewModel({
    LocationVerificationViewModel? locationViewModel,
    QrScanViewModel? qrScanViewModel,
    OnlineCodeViewModel? onlineCodeViewModel,
    AttendanceViewModel? attendanceViewModel,
    VerificationMessageProvider? messageProvider,
  })  : _locationViewModel =
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

  void initialize({required String studentId, String? location}) {
    _studentId = studentId;
    _userLocation = location ?? 'Unknown';
  }

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

  Future<bool> validateQrCode(String code) async {
    updateState(_verificationState.copyWith(isLoading: true, clearError: true));

    final result = await _qrScanViewModel.validateQrCode(code);

    if (result.isValid) {
      updateState(_verificationState.copyWith(isLoading: false));
      return true;
    } else {
      updateState(_verificationState.copyWith(
        isLoading: false,
        errorMessage: result.errorMessage,
      ));
      return false;
    }
  }

  Future<bool> validateOnlineCode(String code) async {
    updateState(_verificationState.copyWith(isLoading: true, clearError: true));

    final result = await _onlineCodeViewModel.validateOnlineCode(code);

    if (result.isValid) {
      updateState(_verificationState.copyWith(isLoading: false));
      return true;
    } else {
      updateState(_verificationState.copyWith(
        isLoading: false,
        errorMessage: result.errorMessage,
      ));
      return false;
    }
  }

  Future<bool> checkLocation() async {
    if (!requiresLocationCheck) return true;

    updateState(_verificationState.copyWith(isLoading: true, clearError: true));

    try {
      bool success = await _locationViewModel.verifyLocation(
        campusLat: AppConstants.houseLat,
        campusLong: AppConstants.houseLong,
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
          campusLat: AppConstants.houseLat,
          campusLong: AppConstants.houseLong,
          maxDistanceMeters: AppConstants.maxDistanceMeters,
        );
      } else {
        success = await _locationViewModel.verifyLocation(
          campusLat: AppConstants.houseLat,
          campusLong: AppConstants.houseLong,
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
      updateState(_verificationState.copyWith(
        errorMessage: 'QR code not scanned',
      ));
      return false;
    }

    final locationStatus = _locationViewModel.state.verificationStatus;

    if (locationStatus == LocationVerificationStatus.successInRange) {
      final result = await _attendanceViewModel.markAttendanceAuthorized(
        code: qrCode,
        studentId: _studentId ?? '',
        location: _userLocation ?? 'Unknown',
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
      _attendanceViewModel.markAttendanceUnauthorized(
        code: qrCode,
        studentId: _studentId ?? '',
        location: _userLocation ?? 'Unknown',
      );

      // updateState(_verificationState.copyWith(
      //   errorMessage:
      //       'Cannot mark attendance: You are out of the allowed range.',
      // ));

      // Still return true to show success to user (for analytics purposes)
      //TODO: confirm this behavior
      return true;
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

    final result = await _attendanceViewModel.markOnlineAttendance(
      code: onlineCode,
      studentId: _studentId ?? '',
    );

    if (result.success) {
      return true;
    } else {
      updateState(_verificationState.copyWith(
        errorMessage: result.errorMessage,
      ));
      return false;
    }
  }

  void moveToNextStep() {
    VerificationStep nextStep;
    // AttendanceType? stepAttendanceType;

    switch (_verificationState.currentStep) {
      case VerificationStep.qrCodeScan:
        // stepAttendanceType = AttendanceType.inPerson;
        nextStep = VerificationStep.locationCheck;
        break;
      case VerificationStep.onlineCodeEntry:
        // stepAttendanceType = AttendanceType.online;
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
    // if (stepAttendanceType != null) {
    //   updateState(_verificationState.copyWith(
    //       currentStep: nextStep, attendanceType: stepAttendanceType));
    // } else {
    updateState(_verificationState.copyWith(currentStep: nextStep));
    // }
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

  // Future<bool> startVerificationFlow({AttendanceType? attendanceType}) async {
  //   if (attendanceType != null) {
  //     setAttendanceType(attendanceType);
  //   }

  //   if (_verificationState.currentStep == VerificationStep.qrCodeScan ||
  //       _verificationState.currentStep == VerificationStep.onlineCodeEntry) {
  //     // bool qrSuccess = await verifyQrCode();
  //     // if (!qrSuccess) return false;

  //     moveToNextStep();
  //     return await proceedWithAutomaticFlow();
  //   }
  //   return true;
  // }

  // Future<bool> verifyFace() async {
  //   updateState(_verificationState.copyWith(isLoading: true, clearError: true));

  //   try {
  //     bool success = await _faceService.verifyFace();
  //     if (success) {
  //       updateState(_verificationState.copyWith(faceVerificationPassed: true));
  //     } else {
  //       updateState(_verificationState.copyWith(
  //         errorMessage: _messageProvider
  //             .getErrorMessage(VerificationError.faceVerificationFailed),
  //       ));
  //     }
  //     return success;
  //   } finally {
  //     updateState(_verificationState.copyWith(isLoading: false));
  //   }
  // }

  // Future<bool> submitAttendance() async {
  //   updateState(_verificationState.copyWith(isLoading: true, clearError: true));

  //   try {
  //     if (requiresLocationCheck &&
  //         _locationViewModel.state.currentPosition == null) {
  //       throw Exception('Location data not available for in-person attendance');
  //     }

  //     // Only require face verification for in-person attendance. For online
  //     // attendance the demo should allow submission without a prior face
  //     // verification step (the face flow is currently commented out).
  //     // if (_verificationState.attendanceType == AttendanceType.inPerson &&
  //     //     !_verificationState.faceVerificationPassed) {
  //     //   throw Exception('Face verification not completed');
  //     // }

  //     if (requiresLocationCheck &&
  //         _locationViewModel.state.verificationStatus !=
  //             LocationVerificationStatus.successInRange) {
  //       throw Exception(
  //           'Location verification required for in-person attendance');
  //     }
  //     // Simulate submitting online attendance without validating an online code.
  //     if (_verificationState.attendanceType == AttendanceType.online) {
  //       bool success = await _attendanceService.submitOnlineAttendance();

  //       if (!success) {
  //         updateState(_verificationState.copyWith(
  //           errorMessage: _messageProvider
  //               .getErrorMessage(VerificationError.attendanceSubmissionFailed),
  //         ));
  //       }

  //       return success;
  //     }
  //     // (This path bypasses the in-person position requirement above.)
  //     // if (_verificationState.attendanceType == AttendanceType.online) {
  //     //   final String? code = _verificationState.currentStep == VerificationStep.onlineCodeEntry
  //     //       ? _verificationState.onlineCode
  //     //       : null;
  //     //   if (code == null || code.trim().isEmpty) {
  //     //     throw Exception('Online code is required for online attendance');
  //     //   }

  //     //   bool success = await _attendanceService.submitAttendance(
  //     //     faceVerified: _verificationState.faceVerificationPassed,
  //     //     attendanceType: AttendanceType.online,
  //     //     position: _locationViewModel.state.currentPosition,
  //     //     distanceFromCampus: _locationViewModel.state.distanceFromCampus,
  //     //     locationMethod: getLocationMethod(),
  //     //     isIndoorLocation: _locationViewModel.state.isIndoorLocation,
  //     //     locationStatus: _locationViewModel.state.verificationStatus,
  //     //     onlineCode: code,
  //     //   );

  //     //   if (!success) {
  //     //     updateState(_verificationState.copyWith(
  //     //       errorMessage: _messageProvider
  //     //           .getErrorMessage(VerificationError.attendanceSubmissionFailed),
  //     //     ));
  //     //   }

  //     //   return success;
  //     // }

  //     bool success = await _attendanceService.submitAttendance(
  //       faceVerified: _verificationState.faceVerificationPassed,
  //       attendanceType: _verificationState.attendanceType ??
  //           AttendanceType.inPerson, //TODO: check if this is safe and wise
  //       position: _locationViewModel.state.currentPosition,
  //       distanceFromCampus: _locationViewModel.state.distanceFromCampus,
  //       locationMethod: getLocationMethod(),
  //       isIndoorLocation: _locationViewModel.state.isIndoorLocation,
  //       locationStatus: _locationViewModel.state.verificationStatus,
  //     );

  //     if (!success) {
  //       updateState(_verificationState.copyWith(
  //         errorMessage: _messageProvider
  //             .getErrorMessage(VerificationError.attendanceSubmissionFailed),
  //       ));
  //     }

  //     return success;
  //   } catch (e) {
  //     updateState(_verificationState.copyWith(
  //       errorMessage: _messageProvider.getErrorMessage(
  //         VerificationError.attendanceSubmissionFailed,
  //         context: {'details': e.toString()},
  //       ),
  //     ));
  //     return false;
  //   } finally {
  //     updateState(_verificationState.copyWith(isLoading: false));
  //   }
  // }

  // String getLocationMethod() {
  //   final locationState = _locationViewModel.state;
  //   if (locationState.isNetworkBased) return 'network';
  //   if (locationState.isIndoorLocation) return 'indoor_gps';
  //   return 'gps';
  // }
}
