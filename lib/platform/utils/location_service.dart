import 'dart:async';

import 'package:attendance_app/platform/utils/permission_utils.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> getCurrentLocation(
      {bool showSettingsOption = true}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceException(
            'Location services are disabled. Please enable location services.');
      }

      bool permissionGranted = await PermissionUtils.requestLocationPermission(
          showSettingsOption: showSettingsOption);

      if (!permissionGranted) {
        throw LocationPermissionException(
            'Location permission is required to mark attendance');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        // timeLimit: const Duration(seconds: 10),
      );

      return position;
    } on LocationServiceDisabledException {
      throw LocationServiceException(
          'Location service are disabled. Please enable location services');
    } on TimeoutException {
      throw LocationTimeoutException(
          'Location request timed out. Please try again');
    } catch (e) {
      throw LocationException(
          'Failed to get current location: ${e.toString()}');
    }
  }

  static bool isWithinAttendanceRange({
    required Position currentPosition,
    required double campusLat,
    required double campusLong,
    required double maxDistanceMeters,
  }) {
    double distance = Geolocator.distanceBetween(currentPosition.latitude,
        currentPosition.longitude, campusLat, campusLong);

    return distance <= maxDistanceMeters;
  }

  static double calculateDistanceFromCampus({
    required Position currentPosition,
    required double campusLat,
    required double campusLong,
  }) {
    return Geolocator.distanceBetween(currentPosition.latitude,
        currentPosition.longitude, campusLat, campusLong);
  }

  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(2)}km';
    }
  }

  static Future<AttendanceLocationResult> canMarkAttendance({
    required double campusLat,
    required double campusLong,
    required double maxDistanceMeters,
    bool showSettingsOption = true,
  }) async {
    try {
      Position? position =
          await getCurrentLocation(showSettingsOption: showSettingsOption);

      // if (position == null) {
      //   return AttendanceLocationResult(
      //     canMarkAttendance: false,
      //     errorMessage: 'Unable to get current location',
      //   );
      // }

      debugPrint('latitude ---> ${position.latitude}');
      debugPrint('longitude ---> ${position.longitude}');

      double distance = calculateDistanceFromCampus(
          currentPosition: position,
          campusLat: campusLat,
          campusLong: campusLong);

      bool withinRange = isWithinAttendanceRange(
          currentPosition: position,
          campusLat: campusLat,
          campusLong: campusLong,
          maxDistanceMeters: maxDistanceMeters);

      return AttendanceLocationResult(
        canMarkAttendance: withinRange,
        currentPosition: position,
        distanceFromCampus: distance,
        formattedDistance: formatDistance(distance),
        errorMessage: withinRange
            ? null
            : 'You are ${formatDistance(distance)} away from campus. You must ve within ${formatDistance(maxDistanceMeters)} to mark attendance',
      );
    } catch (e) {
      return AttendanceLocationResult(
          canMarkAttendance: false, errorMessage: e.toString());
    }
  }
}

class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}

class LocationServiceException extends LocationException {
  LocationServiceException(String message) : super(message);
}

class LocationPermissionException extends LocationException {
  LocationPermissionException(String message) : super(message);
}

class LocationTimeoutException extends LocationException {
  LocationTimeoutException(String message) : super(message);
}

class AttendanceLocationResult {
  final bool canMarkAttendance;
  final Position? currentPosition;
  final double? distanceFromCampus;
  final String? formattedDistance;
  final String? errorMessage;

  AttendanceLocationResult({
    required this.canMarkAttendance,
    this.currentPosition,
    this.distanceFromCampus,
    this.formattedDistance,
    this.errorMessage,
  });
}

class CampusLocations {
  static const Map<String, Map<String, double>> campuses = {
    'main': {
      'lat': AppConstants.campusLat,
      'long': AppConstants.campusLong,
      'range': AppConstants.maxDistanceMeters,
    },
    'satellite': {
      'lat': 5.5334916,
      'long': -0.3258892,
      'range': 1000,
    },
  };
}
