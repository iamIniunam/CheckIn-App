import 'dart:convert';

import 'package:flutter/material.dart';

class QrScanResult {
  final bool isValid;
  final String? code;
  final String? errorMessage;

  QrScanResult({required this.isValid, this.code, this.errorMessage});

  factory QrScanResult.success(String code) {
    return QrScanResult(isValid: true, code: code);
  }

  factory QrScanResult.failure(String errorMessage) {
    return QrScanResult(isValid: false, errorMessage: errorMessage);
  }
}

class QrScanViewModel extends ChangeNotifier {
  String? _scannedCode;
  bool _isScanning = false;
  String? _lastError;

  String? get scannedCode => _scannedCode;
  bool get isScanning => _isScanning;
  String? get lastError => _lastError;

  QrScanResult validateAndSetCode(String code) {
    _lastError = null;

    final validationResult = validateQrCode(code);

    if (validationResult.isValid) {
      setScannedCode(code);
      return QrScanResult.success(code);
    } else {
      _lastError = validationResult.errorMessage;
      notifyListeners();
      return QrScanResult.failure(
          validationResult.errorMessage ?? 'Invalid QR code');
    }
  }

  void setScannedCode(String code) {
    _scannedCode = code;
    notifyListeners();
  }

  void setIsScanning(bool scanning) {
    _isScanning = scanning;
    notifyListeners();
  }

  void reset() {
    _scannedCode = null;
    _isScanning = false;
    notifyListeners();
  }

  QrScanResult validateQrCode(String code) {
    if (code.trim().isEmpty) {
      return QrScanResult.failure('QR code is empty');
    }

    String codetoValidate = code.trim();

    try {
      final decoded = code.contains('%') ? Uri.decodeFull(code) : code;
      try {
        final json = jsonDecode(decoded);
        if (json is Map<String, dynamic>) {
          if (json.containsKey('sessionId')) {
            codetoValidate = json['sessionId'].toString();
          } else if (json.containsKey('session_id')) {
            codetoValidate = json['session_id'].toString();
          } else if (json.containsKey('id')) {
            codetoValidate = json['id'].toString();
          } else if (json.containsKey('code')) {
            codetoValidate = json['code'].toString();
          } else {
            return QrScanResult.failure('QR code does not contain a valid ID');
          }
        }
      } catch (_) {
        codetoValidate = decoded;
      }
    } catch (_) {}

    final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

    if (!uuidRegex.hasMatch(codetoValidate)) {
      return QrScanResult.failure(
          'Invalid attendance QR code.\n\nPlease scan the attendance QR code displayed by your lecturer.');
    }

    if (codetoValidate.replaceAll('-', '').replaceAll('0', '').isEmpty) {
      return QrScanResult.failure('Invalid attendance code format.');
    }

    return QrScanResult.success(code);
  }

  bool isValidCode(String code) {
    final result = validateQrCode(code);
    return result.isValid;
  }

  String? getValidationError(String code) {
    final result = validateQrCode(code);
    return result.isValid ? null : result.errorMessage;
  }

  String? extractUuid(String code) {
    try {
      final decoded = code.contains('%') ? Uri.decodeFull(code) : code;
      try {
        final json = jsonDecode(decoded);
        if (json is Map<String, dynamic>) {
          if (json.containsKey('sessionId')) {
            return json['sessionId'].toString();
          }
          if (json.containsKey('session_id')) {
            return json['session_id'].toString();
          }
          if (json.containsKey('id')) return json['id'].toString();
          if (json.containsKey('code')) return json['code'].toString();
        }
      } catch (_) {}

      final uuidRegex = RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

      if (uuidRegex.hasMatch(decoded.trim())) {
        return decoded.trim();
      }
    } catch (_) {}

    return null;
  }
}
