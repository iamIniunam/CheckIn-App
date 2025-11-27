enum VerificationStep {
  qrCodeScan,
  onlineCodeEntry,
  locationCheck,
  attendanceSubmission,
  completed
}

// enum FaceVerificationMode { signUp, attendanceInPerson, attendanceOnline }

enum AttendanceType { inPerson, online }

enum LocationVerificationStatus { successInRange, outOfRange, failed }

enum AutoFlowResult { success, unauthorized, failed }

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

// enum FaceQualityIssueType {
//   noFaceDetected,
//   multipleFaces,
//   eyesClosed,
//   faceNotFrontal,
//   headTilted,
//   poorLighting,
//   blurryImage,
//   tooFarAway,
//   tooClose,
// }

// enum FaceQualityIssueType {
//   lowBrightness,
//   highBrightness,
//   lowSharpness,
//   highSharpness,
//   lowContrast,
//   highContrast,
//   faceNotCentered,
//   faceNotFrontal,
//   eyesNotOpen,
//   mouthNotClosed,
//   multipleFaces,
//   faceNotDetected,
// }

// enum FaceVerificationError {
//   noFaceDetected,
//   multipleFaces,
//   poorQuality,
//   noStoredFace,
//   similarityTooLow,
//   processingFailed,
//   serviceNotInitialized,
// }

// enum FaceRegistrationError {
//   noFaceDetected,
//   multipleFaces,
//   poorQuality,
//   processingFailed,
//   alreadyRegistered,
//   serviceNotInitialized,
// }

// enum FaceGuidanceMessage {
//   lookStraight,
//   lookLeft,
//   lookRight,
//   lookUp,
//   lookDown,
//   smile,
//   openEyes,
//   moveCloser,
//   moveBack,
//   holdStill,
//   goodPosition,
//   processingComplete
// }
