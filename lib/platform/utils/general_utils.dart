import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Utils {
  Utils._();

  static hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
  
  static printInDebugMode(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
