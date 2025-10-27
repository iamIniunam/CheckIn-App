import 'package:attendance_app/ux/shared/enums.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

abstract class AttendanceService {
  Future<bool> submitAttendance({
    required bool faceVerified,
    required AttendanceType attendanceType,
    Position? position,
    double? distanceFromCampus,
    String? locationMethod,
    bool? isIndoorLocation,
    LocationVerificationStatus? locationStatus,
  });

  Future<bool> submitOnlineAttendance(
      //   {
      //   required bool faceVerified,
      //   String? onlineCode,
      // }
      );
}

class MockAttendanceService implements AttendanceService {
  @override
  Future<bool> submitAttendance({
    required bool faceVerified,
    required AttendanceType attendanceType,
    Position? position,
    double? distanceFromCampus,
    String? locationMethod,
    bool? isIndoorLocation,
    LocationVerificationStatus? locationStatus,
  }) async {
    await Future.delayed(const Duration(seconds: 5));

    Map<String, dynamic> attendanceData = {
      'timestamp': DateTime.now().toIso8601String(),
      'faceVerified': faceVerified,
      'attendanceType': attendanceType.name,
    };

    if (attendanceType == AttendanceType.inPerson && position != null) {
      attendanceData.addAll({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'distanceFromCampus': distanceFromCampus,
        'locationMethod': locationMethod,
        'isIndoorLocation': isIndoorLocation,
        'locationVerificationStatus': locationStatus?.name,
      });
    }

    debugPrint('Attendance submitted: $attendanceData');
    return true;
  }

  @override
  Future<bool> submitOnlineAttendance(
      //   {
      //   // required bool faceVerified,
      //   // String? onlineCode,
      // }
      ) async {
    await Future.delayed(const Duration(seconds: 5));

    Map<String, dynamic> attendanceData = {
      'timestamp': DateTime.now().toIso8601String(),
      // 'faceVerified': faceVerified,
      'attendanceType': AttendanceType.online.name,
      // 'onlineCode': onlineCode,
    };

    debugPrint('Online attendance submitted: $attendanceData');
    return true;
  }
}
