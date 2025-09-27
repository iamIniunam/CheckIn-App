import 'package:attendance_app/ux/shared/enums.dart';
import 'package:geolocator/geolocator.dart';

class VerificationState {
  final VerificationStep currentStep;
  final bool isLoading;
  final String? errorMessage;
  final bool faceVerificationPassed;
  final AttendanceType? attendanceType;

  const VerificationState({
    this.currentStep = VerificationStep.faceVerification,
    this.isLoading = false,
    this.errorMessage,
    this.faceVerificationPassed = false,
    this.attendanceType,
  });

  VerificationState copyWith({
    VerificationStep? currentStep,
    bool? isLoading,
    String? errorMessage,
    bool? faceVerificationPassed,
    AttendanceType? attendanceType,
    bool clearError = false,
  }) {
    return VerificationState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      faceVerificationPassed:
          faceVerificationPassed ?? this.faceVerificationPassed,
      attendanceType: attendanceType ?? this.attendanceType,
    );
  }
}

class LocationState {
  final Position? currentPosition;
  final double? distanceFromCampus;
  final bool isIndoorLocation;
  final bool isNetworkBased;
  final LocationVerificationStatus? verificationStatus;
  final String? errorMessage;

  const LocationState({
    this.currentPosition,
    this.distanceFromCampus,
    this.isIndoorLocation = false,
    this.isNetworkBased = false,
    this.verificationStatus,
    this.errorMessage,
  });

  LocationState copyWith({
    Position? currentPosition,
    double? distanceFromCampus,
    bool? isIndoorLocation,
    bool? isNetworkBased,
    LocationVerificationStatus? verificationStatus,
    String? errorMessage,
    bool clearStatus = false,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      distanceFromCampus: distanceFromCampus ?? this.distanceFromCampus,
      isIndoorLocation: isIndoorLocation ?? this.isIndoorLocation,
      isNetworkBased: isNetworkBased ?? this.isNetworkBased,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      errorMessage: clearStatus ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
