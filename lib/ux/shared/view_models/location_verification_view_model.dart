import 'package:attendance_app/platform/services/location_service.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/message_providers.dart';
import 'package:attendance_app/ux/shared/models/models.dart';
import 'package:flutter/material.dart';

class LocationVerificationViewModel extends ChangeNotifier {
  LocationState _state = const LocationState();
  final VerificationMessageProvider _messageProvider;

  LocationVerificationViewModel({
    VerificationMessageProvider? messageProvider,
  }) : _messageProvider =
            messageProvider ?? DefaultVerificationMessageProvider();

  LocationState get state => _state;
  bool get isLoading => false;

  Future<bool> verifyLocation({
    required double campusLat,
    required double campusLong,
    required double maxDistanceMeters,
    bool showSettingsOption = true,
  }) async {
    updateState(_state.copyWith(clearStatus: true));

    try {
      AttendanceLocationResult result =
          await LocationService.canMarkAttendanceHybrid(
              campusLat: campusLat,
              campusLong: campusLong,
              maxDistanceMeters: maxDistanceMeters,
              showSettingsOption: showSettingsOption);

      updateState(_state.copyWith(
          currentPosition: result.currentPosition,
          distanceFromCampus: result.distanceFromCampus,
          isIndoorLocation: result.isIndoorLocation,
          isNetworkBased: result.isNetworkBased));

      if (result.canMarkAttendance) {
        updateState(_state.copyWith(
            verificationStatus: LocationVerificationStatus.successInRange));
        return true;
      } else {
        return handleVerificationFailure(result, maxDistanceMeters);
      }
    } catch (e) {
      handleError(e);
      return false;
    }
  }

  Future<bool> retyrWithNetworkOnly({
    required double campusLat,
    required double campusLong,
    required double maxDistanceMeters,
  }) async {
    try {
      AttendanceLocationResult result =
          await LocationService.canMarkAttendanceNetworkBased(
        campusLat: campusLat,
        campusLong: campusLong,
        maxDistanceMeters: maxDistanceMeters,
      );

      updateState(_state.copyWith(
        currentPosition: result.currentPosition,
        distanceFromCampus: result.distanceFromCampus,
        isIndoorLocation: result.isIndoorLocation,
        isNetworkBased: result.isNetworkBased,
      ));

      if (result.canMarkAttendance) {
        updateState(_state.copyWith(
            verificationStatus: LocationVerificationStatus.successInRange));
        return true;
      } else {
        return handleVerificationFailure(result, maxDistanceMeters);
      }
    } catch (e) {
      handleError(e);
      return false;
    }
  }

  bool handleVerificationFailure(
      AttendanceLocationResult result, double maxDistanceMeters) {
    if (result.currentPosition != null && result.distanceFromCampus != null) {
      updateState(_state.copyWith(
        verificationStatus: LocationVerificationStatus.outOfRange,
        errorMessage: _messageProvider
            .getErrorMessage(VerificationError.locationOutOfRange, context: {
          'distance': result.distanceFromCampus,
          'maxDistance': maxDistanceMeters
        }),
      ));
    } else {
      updateState(
        _state.copyWith(
          verificationStatus: LocationVerificationStatus.failed,
          errorMessage:
              result.errorMessage ?? 'Unable to determine your location',
        ),
      );
    }
    return false;
  }

  void handleError(dynamic e) {
    VerificationError errorType;
    if (e.toString().toLowerCase().contains('timeout') ||
        e.toString().toLowerCase().contains('accuracy')) {
      errorType = VerificationError.locationAccuracyPoor;
    } else {
      errorType = VerificationError.locationServiceFailed;
    }

    updateState(_state.copyWith(
      verificationStatus: LocationVerificationStatus.failed,
      errorMessage: _messageProvider.getErrorMessage(errorType),
    ));
  }

  void updateState(LocationState newState) {
    _state = newState;
    notifyListeners();
  }

  void reset() {
    _state = const LocationState();
    notifyListeners();
  }
}
