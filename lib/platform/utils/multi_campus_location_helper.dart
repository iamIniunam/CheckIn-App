import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_location_view_model.dart';
import 'package:flutter/material.dart';

class MultiCampusLocationHelper {
  final AttendanceLocationViewModel locationViewModel;

  MultiCampusLocationHelper({required this.locationViewModel});

  Future<MultiCampusResult> checkMultipleCampuses({
    required List<String> campusIds,
    bool showSettingsOption = true,
  }) async {
    if (campusIds.isEmpty) {
      return MultiCampusResult(
        isWithinRange: false,
        nearestCampusId: null,
        nearestCampusDistance: null,
        checkedCampuses: [],
        matchedCampusId: null,
        error: 'No campus IDs provided',
      );
    }

    List<CampusCheckResult> allResults = [];

    for (var i = 0; i < campusIds.length; i++) {
      final campusId = campusIds[i];
      debugPrint(
          'MultiCampusHelper: checking campus [$i]: $campusId (showSettings=${showSettingsOption && i == 0})');

      await locationViewModel.checkAttendance(
          campusId: campusId, showSettingsOption: showSettingsOption && i == 0);

      final result = locationViewModel.checkAttendanceResult.value;
      debugPrint(
          'MultiCampusHelper: result for $campusId -> isSuccess=${result.isSuccess}, isError=${result.isError}, message=${result.message}');

      if (result.isSuccess && result.data != null) {
        final data = result.data as AttendanceResult;

        allResults.add(CampusCheckResult(
          campusId: campusId,
          distance: data.distance,
          canAttend: data.canAttend,
          method: data.method,
          formattedDistance: data.formattedDistance,
        ));

        if (data.canAttend == true) {
          debugPrint(
              'MultiCampusHelper: matched campus $campusId (canAttend=true)');
          return MultiCampusResult(
            isWithinRange: true,
            nearestCampusId: campusId,
            nearestCampusDistance: data.distance,
            checkedCampuses: allResults,
            matchedCampusId: campusId,
            error: null,
          );
        }
      } else if (result.isError) {
        // Distinguish between 'out of range' errors that include data
        // (we should record and continue) and fatal errors (no data)
        // where we should abort and return the error.
        final data = result.data;
        if (data != null) {
          // Non-fatal: out-of-range check with available distance info.
          debugPrint(
              'MultiCampusHelper: out-of-range for $campusId -> ${result.message} (continuing)');
          allResults.add(CampusCheckResult(
            campusId: campusId,
            distance: data.distance,
            canAttend: data.canAttend,
            method: data.method,
            formattedDistance: data.formattedDistance,
          ));
          // continue to next campus
        } else {
          // Fatal error (no data) - abort and return the error
          debugPrint(
              'MultiCampusHelper: fatal error while checking $campusId -> ${result.message}');
          return MultiCampusResult(
            isWithinRange: false,
            nearestCampusId: null,
            nearestCampusDistance: null,
            checkedCampuses: allResults,
            matchedCampusId: null,
            error: result.message ?? 'Location check failed',
          );
        }
      }
    }

    if (allResults.isNotEmpty) {
      allResults.sort((a, b) {
        final ad = a.distance ?? double.infinity;
        final bd = b.distance ?? double.infinity;
        return ad.compareTo(bd);
      });

      final nearest = allResults.first;

      return MultiCampusResult(
        isWithinRange: false,
        nearestCampusId: nearest.campusId,
        nearestCampusDistance: nearest.distance,
        checkedCampuses: allResults,
        matchedCampusId: null,
        error: null,
      );
    }

    return MultiCampusResult(
      isWithinRange: false,
      nearestCampusId: null,
      nearestCampusDistance: null,
      checkedCampuses: [],
      matchedCampusId: null,
      error: 'Unable to determine location',
    );
  }
}

class MultiCampusResult {
  final bool isWithinRange;
  final String? nearestCampusId;
  final double? nearestCampusDistance;
  final List<CampusCheckResult> checkedCampuses;
  final String? matchedCampusId;
  final String? error;

  MultiCampusResult({
    required this.isWithinRange,
    required this.nearestCampusId,
    required this.nearestCampusDistance,
    required this.checkedCampuses,
    this.matchedCampusId,
    this.error,
  });

  String getErrorMessage() {
    if (error != null) return error ?? 'Unknown error';

    if (!isWithinRange && nearestCampusDistance != null) {
      final formattedDistance = checkedCampuses
          .firstWhere((campus) => campus.campusId == nearestCampusId,
              orElse: () => CampusCheckResult(
                  campusId: nearestCampusId ?? '',
                  distance: null,
                  canAttend: false))
          .formattedDistance;
      return 'You are ${formattedDistance ?? 'far'} away from the nearest campus ($nearestCampusId).';
    }
    return 'Unable to verify location.';
  }
}

class CampusCheckResult {
  final String campusId;
  final double? distance;
  final bool canAttend;
  final String? method;
  final String? formattedDistance;

  CampusCheckResult({
    required this.campusId,
    required this.distance,
    required this.canAttend,
    this.method,
    this.formattedDistance,
  });
}
