import 'package:attendance_app/ux/shared/view_models.dart/face_verification_view_model.dart';
import 'package:attendance_app/ux/views/attendance/face_verification_page.dart';
import 'package:attendance_app/ux/views/home/home_page.dart';
import 'package:flutter/material.dart';

class Navigation {
  Navigation._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void back({required BuildContext context, dynamic result}) {
    Navigator.pop(context, result);
  }

  static Future navigateToScreen(
      {required BuildContext context, required screen}) async {
    return Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) => screen));
  }

  static Future navigateToScreenAndClearOnePrevious(
      {required BuildContext context, required screen}) async {
    return Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => screen));
  }

  static Future navigateToScreenAndClearAllPrevious(
      {required BuildContext context, required screen}) async {
    return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => screen),
        (route) => false);
  }

  static Future navigateToHomePage({required BuildContext context}) {
    return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
        (route) => false);
  }

  static void navigateToFaceVerification({
    required BuildContext context,
    FaceVerificationMode mode = FaceVerificationMode.signUp,
    AttendanceType? attendanceType,
    void Function()? onExit,
  }) {
    Navigation.navigateToScreen(
      context: context,
      screen: FaceVerificationPage(
        mode: mode,
        attendanceType: attendanceType,
        onExit: onExit,
      ),
    );
  }

  static void navigateToInPersonAttendance({
    required BuildContext context,
    void Function()? onExit,
  }) {
    navigateToFaceVerification(
      context: context,
      mode: FaceVerificationMode.attendanceInPerson,
      attendanceType: AttendanceType.inPerson,
      onExit: onExit,
    );
  }

  static void navigateToOnlineAttendance({
    required BuildContext context,
    void Function()? onExit,
  }) {
    navigateToFaceVerification(
      context: context,
      mode: FaceVerificationMode.attendanceOnline,
      attendanceType: AttendanceType.online,
      onExit: onExit,
    );
  }
}
