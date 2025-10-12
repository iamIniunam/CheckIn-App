import 'package:attendance_app/ux/shared/enums.dart';
import 'package:attendance_app/ux/shared/models/face_models.dart';

abstract class FaceMessageProvider {
  String getGuidanceMessage(FaceGuidanceMessage guidanceMessage);

  String getVerificationErrorMessage(FaceVerificationError error,
      {Map<String, dynamic>? context});

  String getRegistrationErrorMessage(FaceRegistrationError error,
      {Map<String, dynamic>? context});

  String getQualityIssueMessage(FaceQualityIssueType issueType);

  String getRegistrationProgressMessage(int currentStep, int totalSteps);

  String getRegistrationStepInstruction(int step);
}

class DefaultFaceMessageProvider implements FaceMessageProvider {
  @override
  String getGuidanceMessage(FaceGuidanceMessage guidanceMessage) {
    return guidanceMessage.displayText;
  }

  @override
  String getVerificationErrorMessage(FaceVerificationError error,
      {Map<String, dynamic>? context}) {
    switch (error) {
      case FaceVerificationError.noFaceDetected:
        return 'No face detected in frame.\n\nPlease ensure:\n• Your face is well-lit\n• You\'re looking at the camera\n• The camera is not blocked';

      case FaceVerificationError.multipleFaces:
        return 'Multiple faces detected.\n\nPlease ensure only one person is in front of the camera.';

      case FaceVerificationError.poorQuality:
        final qualityScore = context?['qualityScore'] as double?;
        String message = 'Image quality is too poor for verification.';
        if (qualityScore != null) {
          message +=
              '\n\nQuality score: ${(qualityScore * 100).toStringAsFixed(0)}%';
        }
        message +=
            '\n\nTips:\n• Ensure good lighting\n• Hold device steady\n• Clean camera lens';
        return message;

      case FaceVerificationError.noStoredFace:
        return 'No registered face found.\n\nPlease register your face first before attempting verification.';

      case FaceVerificationError.similarityTooLow:
        final confidence = context?['confidence'] as double?;
        String message = 'Face does not match registered face.';
        if (confidence != null) {
          message +=
              '\n\nSimilarity: ${(confidence * 100).toStringAsFixed(1)}%\n(Required: 70%+)';
        }
        message +=
            '\n\nThis could happen if:\n• Different person attempting verification\n• Significant appearance change\n• Poor lighting conditions';
        return message;

      case FaceVerificationError.processingFailed:
        final errorDetails = context?['error'] as String?;
        String message = 'Face verification processing failed.';
        if (errorDetails != null) {
          message += '\n\nError: $errorDetails';
        }
        message += '\n\nPlease try again. If issue persists, contact support.';
        return message;

      case FaceVerificationError.serviceNotInitialized:
        return 'Face recognition service is not ready.\n\nPlease restart the app and try again.';
    }
  }

  @override
  String getRegistrationErrorMessage(FaceRegistrationError error,
      {Map<String, dynamic>? context}) {
    switch (error) {
      case FaceRegistrationError.noFaceDetected:
        return 'No face detected in frame.\n\nPlease ensure:\n• Your face is clearly visible\n• Good lighting\n• Camera is not blocked';

      case FaceRegistrationError.multipleFaces:
        return 'Multiple faces detected.\n\nOnly one person should be in frame during registration.';

      case FaceRegistrationError.poorQuality:
        final issues = context?['issues'] as List<String>?;
        String message = 'Image quality needs improvement.';
        if (issues != null && issues.isNotEmpty) {
          message += '\n\nIssues found:\n';
          for (var issue in issues) {
            message += '• $issue\n';
          }
        }
        message += '\nPlease adjust and try again.';
        return message;

      case FaceRegistrationError.processingFailed:
        final errorDetails = context?['error'] as String?;
        String message = 'Failed to process face image.';
        if (errorDetails != null) {
          message += '\n\nDetails: $errorDetails';
        }
        return message;

      case FaceRegistrationError.alreadyRegistered:
        return 'Face already registered.\n\nIf you need to re-register, please delete your existing face data first from settings.';

      case FaceRegistrationError.serviceNotInitialized:
        return 'Face recognition service not ready.\n\nPlease restart the app.';
    }
  }

  @override
  String getQualityIssueMessage(FaceQualityIssueType issueType) {
    return issueType.message;
  }

  @override
  String getRegistrationProgressMessage(int currentStep, int totalSteps) {
    if (currentStep >= totalSteps) {
      return 'Registration complete!';
    }
    return 'Step $currentStep of $totalSteps';
  }

  @override
  String getRegistrationStepInstruction(int step) {
    switch (step) {
      case 1:
        return 'Position your face within the frame and look straight at the camera.';
      case 2:
        return 'Slowly turn your head to the left and right while keeping your face in the frame.';
      case 3:
        return 'Tilt your head up and down slowly while keeping your face in the frame.';
      case 4:
        return 'Smile gently while looking at the camera.';
      default:
        return 'Follow the on-screen instructions';
    }
  }
}

class DetailedFaceMessageProvider extends DefaultFaceMessageProvider {
  @override
  String getVerificationErrorMessage(
    FaceVerificationError error, {
    Map<String, dynamic>? context,
  }) {
    // Add timestamps and additional debugging info if needed
    // final timestamp = DateTime.now().toIso8601String();
    final baseMessage =
        super.getVerificationErrorMessage(error, context: context);

    // In debug mode, you could append technical details
    // return '$baseMessage\n\n[Debug: $timestamp]';

    return baseMessage;
  }

  /// Get troubleshooting tips based on error history
  String getTroubleshootingTips(FaceVerificationError error, int failureCount) {
    if (failureCount < 2) return '';

    String tips = '\n\n💡 Troubleshooting Tips:';

    switch (error) {
      case FaceVerificationError.similarityTooLow:
        tips +=
            '\n• Try different lighting\n• Remove glasses if wearing\n• Ensure camera is clean\n• Try from different angle';
        break;
      case FaceVerificationError.poorQuality:
        tips +=
            '\n• Move to brighter location\n• Hold device steady\n• Clean camera lens\n• Try portrait orientation';
        break;
      case FaceVerificationError.noFaceDetected:
        tips +=
            '\n• Check camera permissions\n• Ensure face is in frame\n• Remove any obstructions\n• Try re-focusing camera';
        break;
      default:
        tips +=
            '\n• Restart the app\n• Check internet connection\n• Contact support if issue persists';
    }

    return tips;
  }
}
