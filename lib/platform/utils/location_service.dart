import 'dart:async';

import 'package:attendance_app/platform/utils/permission_utils.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> getCurrentLocation({
    bool showSettingsOption = true,
    int maxAttempts = 3,
    Duration timeoutPerAttempt = const Duration(seconds: 20),
  }) async {
    Position? bestPosition;
    double bestAccuracy = double.infinity;
    List<Position> allReadings = [];

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        debugPrint('Location attempt ${attempt + 1}/$maxAttempts');

        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw LocationServiceException(
              'Location services are disabled. Please enable location services.');
        }

        bool permissionGranted =
            await PermissionUtils.requestLocationPermission(
                showSettingsOption: showSettingsOption);

        if (!permissionGranted) {
          throw LocationPermissionException(
              'Location permission is required to mark attendance');
        }

        LocationAccuracy accuracy =
            attempt < 1 ? LocationAccuracy.best : LocationAccuracy.high;

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: accuracy,
          timeLimit: timeoutPerAttempt,
        );

        allReadings.add(position);

        debugPrint(
            'Attempt ${attempt + 1}: Lat=${position.latitude}, Lng=${position.longitude}, Accuracy=${position.accuracy}m');

        if (position.accuracy < bestAccuracy) {
          bestPosition = position;
          bestAccuracy = position.accuracy;
        }

        if (position.accuracy <= 50.0) {
          debugPrint('Acceptable accuracy for building: ${position.accuracy}m');
          break;
        }

        if (attempt < maxAttempts - 1) {
          await Future.delayed(const Duration(seconds: 3));
        }
      } on LocationServiceDisabledException {
        throw LocationServiceException(
            'Location service are disabled. Please enable location services');
      } on TimeoutException {
        debugPrint('Timeout on attempt ${attempt + 1}');
        if (bestPosition != null && attempt >= 2) {
          debugPrint(
              'Using best position due to timeout: accuracy=${bestPosition.accuracy}m');
          break;
        }
      } catch (e) {
        debugPrint('Error on attempt ${attempt + 1}: $e');
        if (attempt == maxAttempts - 1 && bestPosition != null) {
          debugPrint(
              'Using best available position: accuracy=${bestPosition.accuracy}m');
          break;
        }
      }
    }

    if (bestPosition != null) {
      debugPrint(
          'Final position: Lat=${bestPosition.latitude}, Lng=${bestPosition.longitude}, Accuracy=${bestPosition.accuracy}m');
      debugPrint('Total readings collected: ${allReadings.length}');
      return bestPosition;
    }

    throw LocationException(
        'Failed to get location after $maxAttempts attempts. This might be due to being inside a building.');
  }

  static bool isWithinAttendanceRange({
    required Position currentPosition,
    required double campusLat,
    required double campusLong,
    required double maxDistanceMeters,
  }) {
    double distance = Geolocator.distanceBetween(currentPosition.latitude,
        currentPosition.longitude, campusLat, campusLong);

    debugPrint('=== LOCATION DEBUG INFO ===');
    debugPrint(
        'Your location: ${currentPosition.latitude}, ${currentPosition.longitude}');
    debugPrint('School location: $campusLat, $campusLong');
    debugPrint('Distance calculated: ${distance.toStringAsFixed(2)}m');
    debugPrint('GPS accuracy: ${currentPosition.accuracy.toStringAsFixed(2)}m');
    debugPrint('Max allowed distance: ${maxDistanceMeters}m');

    double accuracyBuffer = currentPosition.accuracy;

    if (accuracyBuffer > 100) {
      accuracyBuffer = 100;
      debugPrint('GPS accuracy very poor, using 100m buffer');
    }

    double effectiveDistance = distance - accuracyBuffer;
    debugPrint(
        'Effective distance (considering accuracy): ${effectiveDistance.toStringAsFixed(2)}m');

    bool withinRange = effectiveDistance <= maxDistanceMeters;
    debugPrint('Within range: $withinRange');
    debugPrint('=========================');

    return withinRange;
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

  static Future<AttendanceLocationResult> canMarkAttendanceinBuilding({
    required double campusLat,
    required double campusLong,
    required double maxDistanceMeters,
    bool showSettingsOption = true,
  }) async {
    try {
      Position? position =
          await getCurrentLocation(showSettingsOption: showSettingsOption);

      double distance = calculateDistanceFromCampus(
          currentPosition: position,
          campusLat: campusLat,
          campusLong: campusLong);

      bool withinRange = isWithinAttendanceRange(
          currentPosition: position,
          campusLat: campusLat,
          campusLong: campusLong,
          maxDistanceMeters: maxDistanceMeters);

      // if (position == null) {
      //   return AttendanceLocationResult(
      //     canMarkAttendance: false,
      //     errorMessage: 'Unable to get current location',
      //   );
      // }

      String statusMessage;
      if (withinRange) {
        if (position.accuracy > 50) {
          statusMessage =
              'Location verified (indoor GPS: ${formatDistance(distance)} from campus, ±${formatDistance(position.accuracy)} accuracy)';
        } else {
          statusMessage =
              'Location verified - ${formatDistance(distance)} from campus';
        }
      } else {
        statusMessage =
            '''You appear to be ${formatDistance(distance)} away from campus.
            GPS accuracy: ±${formatDistance(position.accuracy)}
            Required range: within ${formatDistance(maxDistanceMeters)}

            Note: If you're inside the building, GPS may be less accurate. Try moving closer to a window or outside.''';
      }

      return AttendanceLocationResult(
        canMarkAttendance: withinRange,
        currentPosition: position,
        distanceFromCampus: distance,
        formattedDistance: formatDistance(distance),
        errorMessage: withinRange ? null : statusMessage,
        accuracy: position.accuracy,
        isIndoorLocation: position.accuracy > 50,
      );
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('building')) {
        errorMsg =
            'Unable to get precise location inside building. Please try:\n• Moving to a window\n• Going outside briefly\n• Ensuring location services are enabled';
      }
      return AttendanceLocationResult(
          canMarkAttendance: false, errorMessage: errorMsg);
    }
  }

  static Future<AttendanceLocationResult> canMarkAttendanceNetworkBased(
      {required double campusLat,
      required double campusLong,
      required double maxDistanceMeters}) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 30),
      );

      double distance = calculateDistanceFromCampus(
          currentPosition: position,
          campusLat: campusLat,
          campusLong: campusLong);

      bool withinRange = distance <= (maxDistanceMeters + 200);

      return AttendanceLocationResult(
        canMarkAttendance: withinRange,
        currentPosition: position,
        distanceFromCampus: distance,
        formattedDistance: formatDistance(distance),
        errorMessage: withinRange
            ? null
            : 'Network location indicates you may not be on campus',
        accuracy: position.accuracy,
        isNetworkBased: true,
      );
    } catch (e) {
      return AttendanceLocationResult(
          canMarkAttendance: false,
          errorMessage: 'Network location failed: ${e.toString()}');
    }
  }

  static Future<AttendanceLocationResult> canMarkAttendanceHybrid({
    required double campusLat,
    required double campusLong,
    required double maxDistanceMeters,
    bool showSettingsOption = true,
  }) async {
    debugPrint('Attempting Hybrind location check...');

    try {
      AttendanceLocationResult gpsResult = await canMarkAttendanceinBuilding(
        campusLat: campusLat,
        campusLong: campusLong,
        maxDistanceMeters: maxDistanceMeters,
        showSettingsOption: showSettingsOption,
      );

      if (gpsResult.canMarkAttendance) {
        return gpsResult;
      }

      if (gpsResult.accuracy != null && (gpsResult.accuracy ?? 0) > 100) {
        debugPrint(
            'GPS accuracy poor (${gpsResult.accuracy}m), trying network location...');
      }

      AttendanceLocationResult networkResult =
          await canMarkAttendanceNetworkBased(
        campusLat: campusLat,
        campusLong: campusLong,
        maxDistanceMeters: maxDistanceMeters,
      );

      if (networkResult.canMarkAttendance) {
        networkResult.errorMessage =
            'Location verified using network (GPS signal weak indoors)';
        return networkResult;
      }

      return AttendanceLocationResult(
        canMarkAttendance: false,
        currentPosition: gpsResult.currentPosition,
        distanceFromCampus: gpsResult.distanceFromCampus,
        formattedDistance: gpsResult.formattedDistance,
        accuracy: gpsResult.accuracy,
        errorMessage: '''Location check failed.
        
        Distance from campus: ${gpsResult.formattedDistance ?? 'Unknown'}
        GPS accuracy: ±${formatDistance(gpsResult.accuracy ?? 0)}

        If you're inside the building:
        • Try moving to a window
        • Ensure WiFi is enabled
        • Contact support if problem persists''',
      );
    } catch (e) {
      return AttendanceLocationResult(
        canMarkAttendance: false,
        errorMessage: 'Location services failed: ${e.toString()}',
      );
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
  String? errorMessage;
  final double? accuracy;
  final bool isIndoorLocation;
  final bool isNetworkBased;

  AttendanceLocationResult({
    required this.canMarkAttendance,
    this.currentPosition,
    this.distanceFromCampus,
    this.formattedDistance,
    this.errorMessage,
    this.accuracy,
    this.isIndoorLocation = false,
    this.isNetworkBased = false,
  });
}

class CampusLocations {
  static const Map<String, Map<String, double>> campuses = {
    'house': {
      'lat': AppConstants.houseLat,
      'long': AppConstants.houseLong,
      'range': AppConstants.maxDistanceMeters,
    },
    'seaview': {
      'lat': AppConstants.seaviewLat,
      'long': AppConstants.seaviewLong,
      'range': AppConstants.maxDistanceMeters,
    },
    'kcc': {
      'lat': AppConstants.kccLat,
      'long': AppConstants.kccLong,
      'range': AppConstants.maxDistanceMeters,
    },
  };
}
