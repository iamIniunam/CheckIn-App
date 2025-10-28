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
  String? _enteredCode;
  bool _isValidating = false;
  String? _errorMessage;

  String? get enteredCode => _enteredCode;
  bool get isValidating => _isValidating;
  String? get errorMessage => _errorMessage;

  Future<OnlineCodeResult> validateOnlineCode(String code) async {
    _isValidating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call to validate online code
      // For now, simulate validation
      await Future.delayed(const Duration(milliseconds: 500));

      // Demo: accept any 6-character alphanumeric code
      if (code.length == 6 && RegExp(r'^[A-Z0-9]{6}$').hasMatch(code)) {
        _enteredCode = code;
        _isValidating = false;
        notifyListeners();
        return OnlineCodeResult.success(code);
      } else {
        _errorMessage =
            'Invalid code format. Code must be 6 alphanumeric characters';
        _isValidating = false;
        notifyListeners();
        return OnlineCodeResult.failure(_errorMessage!);
      }
    } catch (e) {
      _errorMessage = 'Failed to validate code: ${e.toString()}';
      _isValidating = false;
      notifyListeners();
      return OnlineCodeResult.failure(_errorMessage!);
    }
  }

  void setCode(String code) {
    _enteredCode = code.toUpperCase();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _enteredCode = null;
    _isValidating = false;
    _errorMessage = null;
    notifyListeners();
  }
}
