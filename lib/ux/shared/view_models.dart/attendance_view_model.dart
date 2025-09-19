import 'package:attendance_app/platform/utils/location_service.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/view_models.dart/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AttendanceViewModel extends ChangeNotifier {
  bool _isCheckingLocation = false;
  String? _locationError;
  late UserViewModel viewModel;

  bool get isCheckingLocation => _isCheckingLocation;
  String? get locationError => _locationError;

  Future<bool> markAttendance() async {
    _isCheckingLocation = true;
    _locationError = null;
    notifyListeners();

    try {
      AttendanceLocationResult result = await LocationService.canMarkAttendance(
          campusLat: AppConstants.campusLat,
          campusLong: AppConstants.campusLong,
          maxDistanceMeters: AppConstants.maxDistanceMeters,
          showSettingsOption: true);

      if (!result.canMarkAttendance) {
        _locationError = result.errorMessage;
        setLoadingState(false);
        return false;
      }

      await submitAttendance(result.currentPosition!);

      setLoadingState(false);
      return true;
    } catch (e) {
      _locationError = 'Failed to marl attendace ${e.toString()}';
      setLoadingState(false);
      return false;
    }
  }

  void setLoadingState(bool loading) {
    _isCheckingLocation = loading;
    notifyListeners();
  }

  Future<void> submitAttendance(Position position) async {
    // Map<String, dynamic> attendaceData = {
    //   'studentId': viewModel.idNumber,
    //   'timestamp': DateTime.now().toIso8601String(),
    //   'latitude': position.latitude,
    //   'longtitude': position.longitude,
    //   'accuracy': position.accuracy,
    // };
  }

  Future<String> checkLocationStatus() async {
    try {
      AttendanceLocationResult result = await LocationService.canMarkAttendance(
        campusLat: AppConstants.campusLat,
        campusLong: AppConstants.campusLong,
        maxDistanceMeters: AppConstants.maxDistanceMeters,
        showSettingsOption: false,
      );

      if (result.canMarkAttendance) {
        return 'You are on campus and can mark attendance';
      } else {
        return result.errorMessage ?? 'Cannot mark attendance';
      }
    } catch (e) {
      return 'Location check failed: ${e.toString()}';
    }
  }
}
