// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:attendance_app/platform/utils/permission_utils.dart';
// import 'package:flutter/foundation.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';

// class ImageUtils {
//   ImageUtils._();

//   static ImagePicker imagePicker = ImagePicker();
//   static ImageCropper imageCropper = ImageCropper();

//   static Future<XFile?> pickImage({
//     required ImageSource imageSource,
//     int imageQuality = 100,
//   }) async {
//     try {
//       bool permissionGranted = false;
//       if (imageSource == ImageSource.camera) {
//         permissionGranted = await PermissionUtils.requestCameraPermission(
//             showSettingsOption: true);
//       } else if (imageSource == ImageSource.gallery) {
//         permissionGranted = await PermissionUtils.requestGalleryPermission(
//             showSettingsOption: true);
//       }

//       if (!permissionGranted) {
//         return null;
//       }

//       return await imagePicker.pickImage(
//           source: imageSource, imageQuality: imageQuality);
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//       return null;
//     }
//   }

//   static Future<List<XFile>?> pickMultipleImagesFromGallery({
//     int imageQuality = 100,
//   }) async {
//     try {
//       bool permissionGranted = await PermissionUtils.requestGalleryPermission(
//           showSettingsOption: true);
//       if (!permissionGranted) {
//         return null;
//       }

//       return await imagePicker.pickMultiImage(imageQuality: imageQuality);
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//       return null;
//     }
//   }

//   static Future<CroppedFile?> cropSelectedImage({
//     required XFile imageFile,
//     CropStyle cropStyle = CropStyle.circle,
//   }) async {
//     return await imageCropper.cropImage(
//       sourcePath: imageFile.path,
//       cropStyle: cropStyle,
//       compressQuality: 10,
//     );
//   }

//   static Future<File?> selectAndCropImageFromSource(
//       {required ImageSource source}) async {
//     final imageFile = await pickImage(imageSource: source);
//     if (imageFile == null) return null;

//     final croppedFile = await cropSelectedImage(imageFile: imageFile);
//     if (croppedFile == null) return null;

//     return File(croppedFile.path);
//   }

//   static Future<File?> selectAndCropImageFromGallery() async {
//     try {
//       final imageFile = await pickImage(imageSource: ImageSource.gallery);
//       if (imageFile == null) return null;

//       final croppedFile = await cropSelectedImage(imageFile: imageFile);
//       if (croppedFile == null) return null;

//       return File(croppedFile.path);
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//       return null;
//     }
//   }

//   static Future<List<File>?> selectAndCropMultipleImagesFromGallery(
//       {int? max}) async {
//     try {
//       List<File> result = [];

//       var images = await pickMultipleImagesFromGallery();
//       if (images == null || images.isEmpty) return null;

//       if (max != null && images.length > max) {
//         images = images.sublist(0, max);
//       }

//       for (var image in images) {
//         final croppedFile = await cropSelectedImage(imageFile: image);
//         if (croppedFile != null) {
//           result.add(File(croppedFile.path));
//         }
//       }
//       return result;
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//       return null;
//     }
//   }

//   static Future<String?> selectAndConvertImageFromGallery() async {
//     final imageFile = await pickImage(imageSource: ImageSource.gallery);
//     if (imageFile == null) return null;

//     final croppedFile = await cropSelectedImage(imageFile: imageFile);
//     if (croppedFile == null) return null;

//     return convertImageToBase64String(File(croppedFile.path));
//   }

//   static Future<File?> selectAndCropImageFromCamera() async {
//     final imageFile = await pickImage(imageSource: ImageSource.camera);
//     if (imageFile == null) return null;

//     final croppedFile = await cropSelectedImage(imageFile: imageFile);
//     if (croppedFile == null) return null;

//     return File(croppedFile.path);
//   }

//   static String getFileExtension(String fileName) {
//     return fileName.split('.').last;
//   }

//   static Future<String> convertImageToBase64String(File? file) async {
//     if (file == null) return "";

//     final bytes = await file.readAsBytes();
//     String base64Image = base64Encode(bytes);

//     return base64Image;
//   }
// }
