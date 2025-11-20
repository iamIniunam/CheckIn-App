// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';

// class FaceVerificationContent extends StatelessWidget {
//   const FaceVerificationContent({
//     super.key,
//     required this.size,
//     required this.previewSize,
//     required this.cameraController,
//     required this.isCameraInitialized,
//   });

//   final double size;
//   final Size? previewSize;
//   final CameraController? cameraController;
//   final bool isCameraInitialized;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: (isCameraInitialized &&
//               previewSize != null &&
//               cameraController != null)
//           ? ClipOval(
//               child: SizedBox(
//                 height: size,
//                 width: size,
//                 child: FittedBox(
//                   fit: BoxFit.cover,
//                   child: SizedBox(
//                     height: previewSize?.width,
//                     width: previewSize?.height,
//                     // cameraController is non-null here because of the guard above
//                     child: CameraPreview(cameraController!),
//                   ),
//                 ),
//               ),
//             )
//           : const CircularProgressIndicator(),
//     );
//   }
// }
