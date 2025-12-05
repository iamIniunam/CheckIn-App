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
  String? _lastError;

  static const String _validLetters = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const String _validNumbers = '23456789';
  static const String _validChars = _validLetters + _validNumbers;

  String? get enteredCode => _enteredCode;
  bool get hasCode => _enteredCode.isNotEmpty;
  String? get lastError => _lastError;

  OnlineCodeResult validateAndSetCode(String code) {
    _lastError = null;

    final validationResult = validateOnlineCode(code);

    if (validationResult.isValid) {
      setCode(code);
      return OnlineCodeResult.success(code);
    } else {
      _lastError = validationResult.errorMessage;
      notifyListeners();
      return OnlineCodeResult.failure(
          validationResult.errorMessage ?? 'Invalid online code');
    }
  }

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

  OnlineCodeResult validateOnlineCode(String code) {
    final trimmedCode = code.trim();

    if (trimmedCode.isEmpty) {
      return OnlineCodeResult.failure('Please enter the attendance code');
    }

    if (trimmedCode.length < 6) {
      return OnlineCodeResult.failure(
          'Attendance code must be 6 characters long');
    }

    if (trimmedCode.length > 6) {
      return OnlineCodeResult.failure(
        'The attendance code is too long. It should be 6 characters',
      );
    }

    for (int i = 0; i < trimmedCode.length; i++) {
      final char = trimmedCode[i];
      if (!_validChars.contains(char)) {
        // Provide helpful error for commonly confused characters
        if (char == 'I' || char == 'i') {
          return OnlineCodeResult.failure(
            'Invalid character "I" in code. Please check the code carefully',
          );
        }
        if (char == 'O' || char == 'o') {
          return OnlineCodeResult.failure(
            'Invalid character "O" in code. Please check the code carefully',
          );
        }
        if (char == '0') {
          return OnlineCodeResult.failure(
            'Invalid character "0" in code. Please check the code carefully',
          );
        }
        if (char == '1') {
          return OnlineCodeResult.failure(
            'Invalid character "1" in code. Please check the code carefully',
          );
        }
        // Generic error for other invalid characters
        return OnlineCodeResult.failure(
          'Invalid character "$char" in code. Only letters (A-Z except I, O) and numbers (2-9) are allowed',
        );
      }
    }

    if (trimmedCode.contains('@') ||
        trimmedCode.contains('.com') ||
        trimmedCode.contains('http')) {
      return OnlineCodeResult.failure(
        'Please enter only the 6-character attendance code',
      );
    }

    if (RegExp(r'^[\s\W]+$').hasMatch(trimmedCode)) {
      return OnlineCodeResult.failure(
        'Invalid code format. Please enter a valid attendance code',
      );
    }
    return OnlineCodeResult.success(trimmedCode.toUpperCase());
  }

  bool isValidCode(String code) {
    final result = validateOnlineCode(code);
    return result.isValid;
  }

  String? getValidationError(String code) {
    final result = validateOnlineCode(code);
    return result.isValid ? null : result.errorMessage;
  }

  static String getValidCharactersHelp() {
    return 'Valid characters:\n'
        '• Letters: A-Z (except I and O)\n'
        '• Numbers: 2-9 (no 0 or 1)';
  }
}
