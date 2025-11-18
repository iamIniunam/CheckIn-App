import 'package:attendance_app/ux/shared/resources/constants/attendance_constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:attendance_app/platform/utils/location_utils.dart';

class AttendanceValidator {
  bool isWithinRange({
    required Position position,
    required double campusLat,
    required double campusLong,
    required double maxDistanceMeters,
  }) {
    double distance = LocationUtils.calculateDistance(
      from: position,
      toLat: campusLat,
      toLong: campusLong,
    );

    double accuracyBuffer =
        position.accuracy > AttendanceConstants.maxAccuracyBuffer
            ? AttendanceConstants.maxAccuracyBuffer
            : position.accuracy;

    double effectiveDistance = distance - accuracyBuffer;

    return effectiveDistance <= maxDistanceMeters;
  }

  double getEffectiveDistance({
    required Position position,
    required double campusLat,
    required double campusLong,
  }) {
    double distance = LocationUtils.calculateDistance(
      from: position,
      toLat: campusLat,
      toLong: campusLong,
    );

    double accuracyBuffer =
        position.accuracy > AttendanceConstants.maxAccuracyBuffer
            ? AttendanceConstants.maxAccuracyBuffer
            : position.accuracy;

    return distance - accuracyBuffer;
  }

  bool isWithinNetworkRange({
    required Position position,
    required double campusLat,
    required double campusLong,
    required double maxDistanceMeters,
  }) {
    double distance = LocationUtils.calculateDistance(
      from: position,
      toLat: campusLat,
      toLong: campusLong,
    );

    return distance <=
        (maxDistanceMeters + AttendanceConstants.networkLocationBuffer);
  }
}
