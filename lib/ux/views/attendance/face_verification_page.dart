// import 'package:attendance_app/platform/utils/permission_utils.dart';
// import 'package:attendance_app/ux/navigation/navigation.dart';
// import 'package:attendance_app/ux/shared/components/app_page.dart';
// import 'package:attendance_app/ux/shared/enums.dart';
// import 'package:attendance_app/ux/views/attendance/components/face_verification_content.dart';
// import 'package:attendance_app/ux/views/attendance/verification_page.dart';
// import 'package:attendance_app/ux/views/course/course_enrollment_page.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';

// class FaceVerificationPage extends StatefulWidget {
//   const FaceVerificationPage({super.key, required this.mode});

//   final FaceVerificationMode mode;

//   @override
//   State<FaceVerificationPage> createState() => _FaceVerificationPageState();
// }

// class _FaceVerificationPageState extends State<FaceVerificationPage> {
//   CameraController? cameraController;
//   bool isCameraInitialized = false;
//   List<CameraDescription> cameras = [];

//   @override
//   void initState() {
//     super.initState();
//     initializeCamera();
//     verifyFace();
//   }

//   Future<void> initializeCamera() async {
//     try {
//       final permissionGranted = await PermissionUtils.requestCameraPermission(
//           showSettingsOption: true);

//       if (!permissionGranted) {
//         debugPrint("Camera permission not granted, stopping initialization.");
//         return;
//       }

//       cameras = await availableCameras();
//       cameraController = CameraController(
//         cameras.firstWhere(
//           (camera) => camera.lensDirection == CameraLensDirection.front,
//           orElse: () => cameras.first,
//         ),
//         ResolutionPreset.medium,
//         enableAudio: false,
//       );

//       await cameraController?.initialize();

//       if (mounted) {
//         setState(() {
//           isCameraInitialized = true;
//         });
//       }
//     } catch (e) {
//       debugPrint("Unexpected Camera Error: $e");
//     }
//   }

//   Future<void> verifyFace() async {
//     // Implement face verification logic here
//     Future.delayed(
//       const Duration(seconds: 3),
//       () {
//         Navigation.navigateToScreenAndClearOnePrevious(
//           context: context,
//           screen: navigateBasedOnMode(),
//         );
//       },
//     );
//   }

//   Widget navigateBasedOnMode() {
//     switch (widget.mode) {
//       case FaceVerificationMode.signUp:
//         return const CourseEnrollmentPage();
//       case FaceVerificationMode.attendanceInPerson:
//         return const VerificationPage(attendanceType: AttendanceType.inPerson);
//       case FaceVerificationMode.attendanceOnline:
//         return const VerificationPage(attendanceType: AttendanceType.online);
//     }
//   }

//   @override
//   void dispose() {
//     disposeCamera();
//     super.dispose();
//   }

//   Future<void> disposeCamera() async {
//     try {
//       await cameraController?.dispose();
//     } catch (e) {
//       debugPrint("Error disposing camera: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size.width * 0.93;
//     final previewSize = cameraController?.value.previewSize;

//     return AppPageScaffold(
//       title: widget.mode == FaceVerificationMode.signUp
//           ? 'Face Registration'
//           : 'Face Verification',
//       body: FaceVerificationContent(
//         size: size,
//         previewSize: previewSize,
//         cameraController: cameraController,
//         isCameraInitialized: isCameraInitialized,
//       ),
//     );
//   }
// }
