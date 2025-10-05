// import 'package:attendance_app/ux/navigation/navigation.dart';
// import 'package:attendance_app/ux/shared/components/app_dialogs.dart';
// import 'package:attendance_app/ux/shared/resources/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// class PermissionAlertDialog {
//   static Future<void> show({
//     required BuildContext context,
//     required String access,
//   }) async {
//     final result = await showAdaptiveDialog(
//         context: context,
//         builder: (context) {
//           return AppAlertDialog(
//             title: 'Permission Required',
//             backgroundColor: AppColors.defaultColor,
//             desc:
//                 'You need to allow access to your device $access to continue. Proceed to settings?',
//             secondOption: 'Yes',
//             firstOption: 'Cancel',
//             onFirstOptionTap: () {
//               Navigation.back(context: context, result: false);
//             },
//             onSecondOptionTap: () {
//               Navigation.back(context: context, result: true);
//             },
//           );
//         });
//     if (result == true) {
//       await openAppSettings();
//     }
//   }
// }
