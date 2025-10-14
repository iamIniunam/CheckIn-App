// import 'package:attendance_app/ux/shared/components/app_material.dart';
// import 'package:attendance_app/ux/shared/resources/app_colors.dart';
// import 'package:attendance_app/ux/shared/resources/app_strings.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class ChoosePhotoBottomSheet extends StatelessWidget {
//   const ChoosePhotoBottomSheet({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         singleOption(
//             icon: Icons.file_upload_outlined,
//             title: AppStrings.uploadFromGallery,
//             onTap: () {
//               Navigator.pop(context, ImageSource.gallery);
//             }),
//         singleOption(
//             icon: Icons.camera_alt_outlined,
//             title: AppStrings.takePicture,
//             onTap: () {
//               Navigator.pop(context, ImageSource.camera);
//             }),
//       ],
//     );
//   }

//   Widget singleOption(
//       {required IconData icon,
//       required String title,
//       required VoidCallback onTap}) {
//     return AppMaterial(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: AppColors.defaultColor,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               title,
//               style: const TextStyle(
//                 color: AppColors.defaultColor,
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
