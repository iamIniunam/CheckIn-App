import 'package:attendance_app/platform/utils/general_utils.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/bottom_sheets/app_confirmation_bottom_sheets.dart';
import 'package:attendance_app/ux/shared/bottom_sheets/show_app_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionUtils {
  PermissionUtils._();

  static Future<bool> requestCameraPermission(
      {bool showSettingsOption = false}) async {
    final status = await Permission.camera.request();
    Utils.printInDebugMode('Camera permission status: $status');

    if (status.isGranted) {
      return true;
    } else {
      if (showSettingsOption) {
        await showSettingsBottomSheet(access: 'camera');
      }
      return false;
    }
  }

  static Future<bool> requestGalleryPermission(
      {bool showSettingsOption = false}) async {
    final status = await Permission.photos.request();
    Utils.printInDebugMode('Gallery permission status: $status');

    if (status.isGranted || status.isLimited) {
      return true;
    } else {
      if (showSettingsOption) {
        await showSettingsBottomSheet(access: 'photos');
      }
      return false;
    }
  }

  static Future<bool> requestLocationPermission(
      {bool showSettingsOption = false}) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Utils.printInDebugMode('Location permission status: $permission');
      return true;
    } else {
      if (showSettingsOption) {
        await showSettingsBottomSheet(access: 'location');
      }
      return false;
    }
  }

  static Future showSettingsBottomSheet({required String access}) async {
    var res = await showAppBottomSheet(
      context: Navigation.navigatorKey.currentContext,
      child: AppConfirmationBottomSheet(
          text:
              'You need to allow acess to your device $access to continue. Proceed to settings?'),
    );
    if (res == true) {
      await openAppSettings();
    }
  }
}
