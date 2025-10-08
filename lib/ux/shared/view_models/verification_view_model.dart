import 'package:attendance_app/platform/services/location_service.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/view_models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class VerificationViewModel extends ChangeNotifier {
  bool _isCheckingLocation = false;
  String? _locationError;
  String? _locationStatus;
  late UserViewModel viewModel;

  bool get isCheckingLocation => _isCheckingLocation;
  String? get locationError => _locationError;
  String? get locationStatus => _locationStatus;

  Future<bool> markAttendance() async {
    _isCheckingLocation = true;
    _locationError = null;
    _locationStatus = 'Checking location for building...';
    notifyListeners();

    try {
      AttendanceLocationResult result =
          await LocationService.canMarkAttendanceHybrid(
              campusLat: AppConstants.chisomLat,
              campusLong: AppConstants.chisomLong,
              maxDistanceMeters: AppConstants.maxDistanceMeters,
              showSettingsOption: true);

      if (!result.canMarkAttendance) {
        _locationError = result.errorMessage;
        _locationStatus = 'Location check failed';
        setLoadingState(false);
        return false;
      }

      _locationStatus = 'Location verified! Submitting attendance...';
      notifyListeners();

      if (result.currentPosition == null) {
        _locationError = 'Failed to get current position';
        _locationStatus = 'Attendance failed';
        setLoadingState(false);
        return false;
      }

      await submitAttendance(result.currentPosition!); //TODO null check

      _locationStatus = 'Attendance marked successfully!';
      setLoadingState(false);
      return true;
    } catch (e) {
      _locationError = 'Failed to mark attendance: ${e.toString()}';
      _locationStatus = 'Attendance failed';
      setLoadingState(false);
      return false;
    }
  }

  void setLoadingState(bool loading) {
    _isCheckingLocation = loading;
    if (!loading) {
      Future.delayed(const Duration(seconds: 3), () {
        _locationStatus = null;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  Future<void> submitAttendance(Position position) async {
    Map<String, dynamic> attendanceData = {
      // 'studentId': viewModel.idNumber,
      'timestamp': DateTime.now().toIso8601String(),
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'locationMethod': position.accuracy > 50 ? 'indoor_gps' : 'gps',
    };

    debugPrint('Attendance submitted: $attendanceData');
  }

  Future<String> checkLocationStatus() async {
    try {
      _locationStatus = 'Checking your location...';
      notifyListeners();

      AttendanceLocationResult result =
          await LocationService.canMarkAttendanceHybrid(
        campusLat: AppConstants.chisomLat,
        campusLong: AppConstants.chisomLong,
        maxDistanceMeters: AppConstants.maxDistanceMeters,
        showSettingsOption: false,
      );

      String status;
      if (result.canMarkAttendance) {
        if (result.isNetworkBased) {
          status = 'You appear to be on campus (network location)';
        } else if (result.isIndoorLocation) {
          status =
              'You are on campus (indoor GPS, accuracy: ±${LocationService.formatDistance(result.accuracy ?? 0)})';
        } else {
          status = 'You are on campus and can mark attendance';
        }
      } else {
        status = result.errorMessage ??
            'Cannot mark attendance from current location';
      }

      _locationStatus = status;
      notifyListeners();

      return status;
    } catch (e) {
      String errorMsg = 'Location check failed: ${e.toString()}';
      _locationStatus = errorMsg;
      notifyListeners();
      return errorMsg;
    }
  }

  Future<void> testLocationAccuracy() async {
    _isCheckingLocation = true;
    _locationStatus = 'Testing location accuracy...';
    notifyListeners();

    try {
      Position position = await LocationService.getCurrentLocation();

      double distance = LocationService.calculateDistanceFromCampus(
        currentPosition: position,
        campusLat: AppConstants.chisomLat,
        campusLong: AppConstants.chisomLong,
      );

      _locationStatus = '''Location Test Results:
        Your coordinates: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}
        School coordinates: ${AppConstants.chisomLat}, ${AppConstants.chisomLong}
        Distance: ${LocationService.formatDistance(distance)}
        GPS Accuracy: ±${LocationService.formatDistance(position.accuracy)}
        Max allowed: ${LocationService.formatDistance(AppConstants.maxDistanceMeters)}''';
    } catch (e) {
      _locationStatus = 'Location test failed: ${e.toString()}';
    } finally {
      _isCheckingLocation = false;
      notifyListeners();
    }
  }

  void clearLocationStatus() {
    _locationStatus = null;
    _locationError = null;
    notifyListeners();
  }
}
