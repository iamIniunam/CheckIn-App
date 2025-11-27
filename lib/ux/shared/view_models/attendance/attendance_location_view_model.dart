import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/platform/utils/location_provider.dart';
import 'package:attendance_app/platform/utils/location_utils.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/constants/attendance_constants.dart';
import 'package:attendance_app/ux/shared/resources/constants/attendance_validator.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AttendanceLocationViewModel extends ChangeNotifier {
  final LocationProvider _locationProvider = AppDI.getIt<LocationProvider>();
  final AttendanceValidator _attendanceValidator =
      AppDI.getIt<AttendanceValidator>();

  ValueNotifier<UIResult<AttendanceResult>> checkAttendanceResult =
      ValueNotifier(UIResult.empty());

  Future<void> checkAttendance(
      {required String campusId, bool showSettingsOption = true}) async {
    checkAttendanceResult.value = UIResult.loading();

    try {
      final campus = CampusLocations.getCampus(campusId);
      if (campus == null) {
        checkAttendanceResult.value =
            UIResult.error(message: 'Invalid campus ID: $campusId');
        debugPrint('AttendanceLocation: Invalid campus id: $campusId');
        return;
      }

      Position? gpsPosition = await _locationProvider.getPosition(
          showSettingsOption: showSettingsOption);

      if (gpsPosition != null) {
        bool withinRange = _attendanceValidator.isWithinRange(
          position: gpsPosition,
          campusLat: campus.latitude,
          campusLong: campus.longitude,
          maxDistanceMeters: campus.maxDistanceMeters,
        );

        if (withinRange) {
          checkAttendanceResult.value = UIResult.success(
            data: AttendanceResult(
              canAttend: true,
              position: gpsPosition,
              distance: LocationUtils.calculateDistance(
                from: gpsPosition,
                toLat: campus.latitude,
                toLong: campus.longitude,
              ),
              method: 'GPS',
            ),
            message: 'Location verified',
          );
          debugPrint(
              'AttendanceLocation: withinRange=TRUE for $campusId (GPS)');
          return;
        }

        if (gpsPosition.accuracy >
            AttendanceConstants.poorGPSAccuracyThreshold) {
          Position? networkPosition =
              await _locationProvider.getNetworkPosition();

          if (networkPosition != null) {
            bool withinNetworkRange = _attendanceValidator.isWithinNetworkRange(
              position: networkPosition,
              campusLat: campus.latitude,
              campusLong: campus.longitude,
              maxDistanceMeters: campus.maxDistanceMeters,
            );

            if (withinNetworkRange) {
              checkAttendanceResult.value = UIResult.success(
                data: AttendanceResult(
                  canAttend: true,
                  position: networkPosition,
                  distance: LocationUtils.calculateDistance(
                    from: networkPosition,
                    toLat: campus.latitude,
                    toLong: campus.longitude,
                  ),
                  method: 'Network',
                ),
                message: 'Location verified via network (GPS signal poor)',
              );
              debugPrint(
                  'AttendanceLocation: withinRange=TRUE for $campusId (Network)');
              return;
            }
          }
        }

        double distance = LocationUtils.calculateDistance(
          from: gpsPosition,
          toLat: campus.latitude,
          toLong: campus.longitude,
        );

        checkAttendanceResult.value = UIResult.error(
          message:
              'You are ${LocationUtils.formatDistance(distance)} from ${campus.name}. '
              'GPS accuracy: ±${LocationUtils.formatDistance(gpsPosition.accuracy)}',
          data: AttendanceResult(
            canAttend: false,
            position: gpsPosition,
            distance: distance,
            method: 'GPS',
          ),
        );
        debugPrint(
            'AttendanceLocation: withinRange=FALSE for $campusId; distance=${distance}m, accuracy=${gpsPosition.accuracy}');
        return;
      }

      checkAttendanceResult.value = UIResult.error(
          message:
              'Unable to get your location. Please ensure location services are enabled.');
      debugPrint(
          'AttendanceLocation: Unable to obtain GPS position for $campusId');
    } catch (e) {
      checkAttendanceResult.value = UIResult.error(message: e.toString());
      debugPrint(
          'AttendanceLocation: exception for $campusId -> ${e.toString()}');
    }
  }

  void resetResult() {
    checkAttendanceResult.value = UIResult.empty();
  }

  @override
  void dispose() {
    checkAttendanceResult.dispose();
    super.dispose();
  }
}
