enum VerificationStep {
  faceVerification,
  locationCheck,
  attendanceSubmission,
  completed
}

enum FaceVerificationMode { signUp, attendanceInPerson, attendanceOnline }

enum AttendanceType { inPerson, online }

enum LocationVerificationStatus { successInRange, outOfRange, failed }

enum VerificationError {
  faceVerificationFailed,
  locationTimeout,
  locationAccuracyPoor,
  locationOutOfRange,
  locationServiceFailed,
  attendanceSubmissionFailed,
  networkError,
  permissionDenied,
}
