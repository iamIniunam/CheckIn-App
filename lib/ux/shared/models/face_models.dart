// import 'package:attendance_app/ux/shared/enums.dart';

// class FaceVerificationResult {
//   final bool success;
//   final double? confidence;
//   final String message;
//   final FaceVerificationError? error;
//   final Map<String, dynamic>? metadata;

//   FaceVerificationResult({
//     required this.success,
//     this.confidence,
//     required this.message,
//     this.error,
//     this.metadata,
//   });

//   factory FaceVerificationResult.success(
//       {required double confidence, String? message}) {
//     return FaceVerificationResult(
//       success: true,
//       confidence: confidence,
//       message: message ?? 'Face verification successful',
//     );
//   }

//   factory FaceVerificationResult.failure(
//       {required FaceVerificationError error,
//       String? message,
//       Map<String, dynamic>? metadata}) {
//     return FaceVerificationResult(
//       success: false,
//       error: error,
//       message: message ?? 'Face verification failed',
//       metadata: metadata,
//     );
//   }
// }

// class FaceRegistrationResult {
//   final bool success;
//   final List<double>? embedding;
//   final double? qualityScore;
//   final String message;
//   final FaceRegistrationError? error;

//   FaceRegistrationResult({
//     required this.success,
//     this.embedding,
//     this.qualityScore,
//     required this.message,
//     this.error,
//   });

//   factory FaceRegistrationResult.success({
//     required List<double> embedding,
//     required double qualityScore,
//     String? message,
//   }) {
//     return FaceRegistrationResult(
//       success: true,
//       embedding: embedding,
//       qualityScore: qualityScore,
//       message: message ?? 'Face registered successfully',
//     );
//   }

//   factory FaceRegistrationResult.failure({
//     required FaceRegistrationError error,
//     String? message,
//   }) {
//     return FaceRegistrationResult(
//       success: false,
//       message: message ?? error.defaultMessage,
//       error: error,
//     );
//   }
// }

// class FaceQualityResult {
//   final bool passed;
//   final double qualityScore;
//   final List<FaceQualityIssue> issues;
//   final Map<String, dynamic> details;

//   FaceQualityResult({
//     required this.passed,
//     required this.qualityScore,
//     required this.issues,
//     required this.details,
//   });

//   String get primaryIssue =>
//       issues.isNotEmpty ? issues.first.message : 'Unknown quality issue';
// }

// class FaceQualityIssue {
//   final FaceQualityIssueType type;
//   final String message;
//   final double severity;

//   FaceQualityIssue(
//       {required this.type, required this.message, required this.severity});
// }

// extension FaceQualityIssueTypeExtension on FaceQualityIssueType {
//   String get message {
//     switch (this) {
//       case FaceQualityIssueType.noFaceDetected:
//         return 'No face detected in frame';
//       case FaceQualityIssueType.multipleFaces:
//         return 'Multiple faces detected. Only one person should be in frame';
//       case FaceQualityIssueType.eyesClosed:
//         return 'Please keep your eyes open';
//       case FaceQualityIssueType.faceNotFrontal:
//         return 'Please face the camera directly';
//       case FaceQualityIssueType.headTilted:
//         return 'Please keep your head straight';
//       case FaceQualityIssueType.poorLighting:
//         return 'Poor lighting. Please move to a brighter area';
//       case FaceQualityIssueType.blurryImage:
//         return 'Image is blurry. Please hold still';
//       case FaceQualityIssueType.tooFarAway:
//         return 'Please move closer to the camera';
//       case FaceQualityIssueType.tooClose:
//         return 'Please move back a bit';
//     }
//   }
// }

// extension FaceVerificationErrorExtension on FaceVerificationError {
//   String get defaultMessage {
//     switch (this) {
//       case FaceVerificationError.noFaceDetected:
//         return 'No face detected. Please ensure your face is clearly visible';
//       case FaceVerificationError.multipleFaces:
//         return 'Multiple faces detected. Please ensure only one person is in frame';
//       case FaceVerificationError.poorQuality:
//         return 'Image quality too poor. Please improve lighting and hold still';
//       case FaceVerificationError.noStoredFace:
//         return 'No registered face found. Please register first';
//       case FaceVerificationError.similarityTooLow:
//         return 'Face does not match registered face';
//       case FaceVerificationError.processingFailed:
//         return 'Face verification failed. Please try again';
//       case FaceVerificationError.serviceNotInitialized:
//         return 'Face recognition service not ready';
//     }
//   }
// }

// extension FaceRegistrationErrorExtension on FaceRegistrationError {
//   String get defaultMessage {
//     switch (this) {
//       case FaceRegistrationError.noFaceDetected:
//         return 'No face detected. Please ensure your face is clearly visible';
//       case FaceRegistrationError.multipleFaces:
//         return 'Multiple faces detected. Please ensure only one person is in frame';
//       case FaceRegistrationError.poorQuality:
//         return 'Image quality too poor. Please improve lighting';
//       case FaceRegistrationError.processingFailed:
//         return 'Failed to process face image';
//       case FaceRegistrationError.alreadyRegistered:
//         return 'Face already registered for this user';
//       case FaceRegistrationError.serviceNotInitialized:
//         return 'Face recognition service not ready';
//     }
//   }
// }

// extension FaceGuidanceMessageExtension on FaceGuidanceMessage {
//   String get displayText {
//     switch (this) {
//       case FaceGuidanceMessage.lookStraight:
//         return 'Look straight at the camera';
//       case FaceGuidanceMessage.lookLeft:
//         return 'Turn your head slightly left';
//       case FaceGuidanceMessage.lookRight:
//         return 'Turn your head slightly right';
//       case FaceGuidanceMessage.lookUp:
//         return 'Tilt your head slightly up';
//       case FaceGuidanceMessage.lookDown:
//         return 'Tilt your head slightly down';
//       case FaceGuidanceMessage.smile:
//         return 'Please smile';
//       case FaceGuidanceMessage.openEyes:
//         return 'Open your eyes wide';
//       case FaceGuidanceMessage.moveCloser:
//         return 'Move closer to the camera';
//       case FaceGuidanceMessage.moveBack:
//         return 'Move back from the camera';
//       case FaceGuidanceMessage.holdStill:
//         return 'Hold still...';
//       case FaceGuidanceMessage.goodPosition:
//         return 'Perfect! Hold this position';
//       case FaceGuidanceMessage.processingComplete:
//         return 'Processing complete';
//     }
//   }

//   String? get icon {
//     switch (this) {
//       case FaceGuidanceMessage.lookStraight:
//         return '👁️';
//       case FaceGuidanceMessage.lookLeft:
//         return '◀️';
//       case FaceGuidanceMessage.lookRight:
//         return '▶️';
//       case FaceGuidanceMessage.lookUp:
//         return '🔼';
//       case FaceGuidanceMessage.lookDown:
//         return '🔽';
//       case FaceGuidanceMessage.smile:
//         return '😊';
//       case FaceGuidanceMessage.openEyes:
//         return '👀';
//       case FaceGuidanceMessage.moveCloser:
//         return '➕';
//       case FaceGuidanceMessage.moveBack:
//         return '➖';
//       case FaceGuidanceMessage.holdStill:
//         return '⏱️';
//       case FaceGuidanceMessage.goodPosition:
//         return '✅';
//       case FaceGuidanceMessage.processingComplete:
//         return '✨';
//     }
//   }
// }

// class FaceCaptureState {
//   final int currentStep;
//   final int totalSteps;
//   final FaceGuidanceMessage? currentGuidance;
//   final bool isCapturing;
//   final List<double>? capturedEmbedding;

//   FaceCaptureState({
//     required this.currentStep,
//     required this.totalSteps,
//     this.currentGuidance,
//     this.isCapturing = false,
//     this.capturedEmbedding,
//   });

//   FaceCaptureState copyWith({
//     int? currentStep,
//     int? totalSteps,
//     FaceGuidanceMessage? currentGuidance,
//     bool? isCapturing,
//     List<double>? capturedEmbedding,
//   }) {
//     return FaceCaptureState(
//       currentStep: currentStep ?? this.currentStep,
//       totalSteps: totalSteps ?? this.totalSteps,
//       currentGuidance: currentGuidance ?? this.currentGuidance,
//       isCapturing: isCapturing ?? this.isCapturing,
//       capturedEmbedding: capturedEmbedding ?? this.capturedEmbedding,
//     );
//   }

//   bool get isComplete => currentStep >= totalSteps;
//   double get progress => totalSteps > 0 ? currentStep / totalSteps : 0.0;
// }
