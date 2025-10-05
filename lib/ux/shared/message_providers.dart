import 'package:attendance_app/platform/services/location_service.dart';
import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/models/models.dart';

abstract class VerificationMessageProvider {
  String getStepDescription(
      VerificationStep step, AttendanceType? attendanceType, bool isLoading);
  String getButtonText(FaceVerificationMode mode, VerificationStep step,
      {LocationVerificationStatus? locationStatus});
  String getLocationStatusHeaderMessage(LocationVerificationStatus status);
  String getLocationStatusMessage(LocationVerificationStatus status);
  String getErrorMessage(VerificationError error,
      {Map<String, dynamic>? context});
  String getAttendanceTypeDisplayName(AttendanceType? type);
  String getLocationInfo(LocationState locationState);
  String getCompletionMessage(LocationState locationState);
}

class DefaultVerificationMessageProvider
    implements VerificationMessageProvider {
  @override
  String getStepDescription(
      VerificationStep step, AttendanceType? attendanceType, bool isLoading) {
    switch (step) {
      case VerificationStep.faceVerification:
        return 'Position your face in the circle and tap verify';
      case VerificationStep.locationCheck:
        if (attendanceType == AttendanceType.inPerson) {
          return isLoading
              ? 'Checking location inside building...'
              : 'Verifying your location...';
        }
        return 'Location check skipped for online attendance';
      case VerificationStep.attendanceSubmission:
        return attendanceType == AttendanceType.inPerson
            ? 'Submitting in-person attendance...'
            : 'Submitting online attendance...';
      case VerificationStep.completed:
        return 'Verification completed successfully!';
    }
  }

  @override
  String getButtonText(FaceVerificationMode mode, VerificationStep step,
      {LocationVerificationStatus? locationStatus}) {
    if (step == VerificationStep.locationCheck) {
      switch (locationStatus) {
        case LocationVerificationStatus.outOfRange:
          return 'Return Home';
        case LocationVerificationStatus.failed:
          return 'Try Again';
        default:
          break;
      }
    }
    if (step == VerificationStep.completed) {
      return 'Done';
    }
    switch (mode) {
      case FaceVerificationMode.signUp:
        return 'Register Face';
      case FaceVerificationMode.attendanceInPerson:
      case FaceVerificationMode.attendanceOnline:
        return step == VerificationStep.faceVerification
            ? 'Verify Face'
            : 'Processing...';
    }
  }

  @override
  String getLocationStatusHeaderMessage(LocationVerificationStatus status) {
    switch (status) {
      case LocationVerificationStatus.successInRange:
      case LocationVerificationStatus.outOfRange:
        return 'Location verified';
      case LocationVerificationStatus.failed:
        return 'Verification failed';
    }
  }

  @override
  String getLocationStatusMessage(LocationVerificationStatus status) {
    switch (status) {
      case LocationVerificationStatus.successInRange:
        return 'Great! You’re at the right location.';
      case LocationVerificationStatus.outOfRange:
        return 'Out of range. Attendance not possible here.';
      case LocationVerificationStatus.failed:
        return 'Couldn’t verify your location.';
    }
  }

  @override
  String getErrorMessage(VerificationError error,
      {Map<String, dynamic>? context}) {
    switch (error) {
      case VerificationError.faceVerificationFailed:
        return 'Face verification failed. Please try again';
      case VerificationError.locationTimeout:
      case VerificationError.locationAccuracyPoor:
        return '''Location verification failed - GPS signal weak inside building.

Try:
• Moving closer to a window
• Ensuring WiFi is enabled
• Going outside briefly to get location''';
      case VerificationError.locationOutOfRange:
        final distance = context?['distance'] as double?;
        final maxDistance = context?['maxDistance'] as double?;
        if (distance != null && maxDistance != null) {
          return 'You are ${LocationService.formatDistance(distance)} from campus. '
              'You need to be within ${LocationService.formatDistance(maxDistance)} to mark attendance.';
        }
        return 'You are outside the allowed range for attendance';
      case VerificationError.locationServiceFailed:
        return context?['message'] as String? ?? 'Location service unavailable';
      case VerificationError.attendanceSubmissionFailed:
        return 'Failed to submit attendance. Please try again';
      case VerificationError.networkError:
        return 'Network connection error. Please check your connection';
      case VerificationError.permissionDenied:
        return 'Location permission is required for in-person attendance';
    }
  }

  @override
  String getAttendanceTypeDisplayName(AttendanceType? type) {
    switch (type) {
      case AttendanceType.inPerson:
        return 'In-Person';
      case AttendanceType.online:
        return 'Online';
      case null:
        return 'Not Set';
    }
  }

  @override
  String getLocationInfo(LocationState locationState) {
    if (locationState.currentPosition == null) return 'No location data';

    String info =
        'Distance: ${LocationService.formatDistance(locationState.distanceFromCampus ?? 0)}';

    if (locationState.isNetworkBased) {
      info += '\nMethod: Network location';
    } else if (locationState.isIndoorLocation) {
      info +=
          '\nMethod: Indoor GPS (±${LocationService.formatDistance(locationState.currentPosition?.accuracy ?? 0)})';
    } else {
      info +=
          '\nMethod: GPS (±${LocationService.formatDistance(locationState.currentPosition?.accuracy ?? 0)})';
    }

    final verificationStatus = locationState.verificationStatus;
    if (verificationStatus != null) {
      info += '\nStatus: ${getLocationStatusMessage(verificationStatus)}';
    }

    return info;
  }

  @override
  String getCompletionMessage(LocationState locationState) {
    String message = 'Verification completed successfully!';
    if (locationState.isNetworkBased) {
      message += '\n(Network location used)';
    } else if (locationState.isIndoorLocation) {
      message += '\n(Indoor GPS used)';
    }
    return message;
  }
}
