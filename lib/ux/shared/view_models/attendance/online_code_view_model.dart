import 'package:flutter/material.dart';

class OnlineCodeResult {
  final bool isValid;
  final String? code;
  final String? errorMessage;

  OnlineCodeResult({required this.isValid, this.code, this.errorMessage});

  factory OnlineCodeResult.success(String code) {
    return OnlineCodeResult(isValid: true, code: code);
  }

  factory OnlineCodeResult.failure(String errorMessage) {
    return OnlineCodeResult(isValid: false, errorMessage: errorMessage);
  }
}

class OnlineCodeViewModel extends ChangeNotifier {
  String _enteredCode = '';

  String? get enteredCode => _enteredCode;
  bool get hasCode => _enteredCode.isNotEmpty;

  void setCode(String code) {
    _enteredCode = code..trim().toUpperCase();
    notifyListeners();
  }

  void clearcode() {
    _enteredCode = '';
    notifyListeners();
  }

  void reset() {
    _enteredCode = '';
    notifyListeners();
  }
}
