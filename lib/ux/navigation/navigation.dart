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
}
