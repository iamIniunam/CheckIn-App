import 'package:attendance_app/ux/shared/enums.dart';
import 'package:geolocator/geolocator.dart';

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
