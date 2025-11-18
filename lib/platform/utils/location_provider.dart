import 'dart:async';
import 'package:attendance_app/ux/shared/resources/constants/attendance_constants.dart';
import 'package:attendance_app/ux/shared/resources/constants/location_exceptions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:attendance_app/platform/utils/permission_utils.dart';

class LocationProvider {
  Future<Position?> getPosition({
    int maxAttempts = AttendanceConstants.maxLocationAttempts,
    Duration timeoutPerAttempt = AttendanceConstants.locationTimeout,
    bool showSettingsOption = true,
  }) async {
    Position? bestPosition;
    double bestAccuracy = double.infinity;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw LocationServiceException(
            'Location services are disabled. Please enable location services.',
          );
        }

        bool permissionGranted =
            await PermissionUtils.requestLocationPermission(
          showSettingsOption: showSettingsOption,
        );
        if (!permissionGranted) {
          throw LocationPermissionException(
            'Location permission is required to mark attendance',
          );
        }

        LocationAccuracy accuracy =
            attempt < 1 ? LocationAccuracy.best : LocationAccuracy.high;

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: accuracy,
          timeLimit: timeoutPerAttempt,
        );

        if (position.accuracy < bestAccuracy) {
          bestPosition = position;
          bestAccuracy = position.accuracy;
        }

        if (position.accuracy <= AttendanceConstants.acceptableGPSAccuracy) {
          break;
        }

        if (attempt < maxAttempts - 1) {
          await Future.delayed(AttendanceConstants.retryDelay);
        }
      } on LocationServiceDisabledException {
        throw LocationServiceException(
          'Location services are disabled. Please enable location services.',
        );
      } on TimeoutException {
        // If we have a position and tried at least 3 times, use it
        if (bestPosition != null && attempt >= 2) {
          break;
        }
      } catch (e) {
        // On last attempt, use best available position
        if (attempt == maxAttempts - 1 && bestPosition != null) {
          break;
        }
        // Otherwise rethrow
        if (e is LocationException) rethrow;
      }
    }

    return bestPosition;
  }

  Future<Position?> getNetworkPosition({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: timeout,
      );
    } catch (e) {
      return null;
    }
  }
}
