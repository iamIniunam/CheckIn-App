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
  bool _isValidating = false;
  String? _errorMessage;

  String? get scannedCode => _scannedCode;
  bool get isValidating => _isValidating;
  String? get errorMessage => _errorMessage;

  Future<QrScanResult> validateQrCode(String code) async {
    _isValidating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call to validate QR code
      // For now, simulate validation
      await Future.delayed(const Duration(milliseconds: 500));

      // Demo: accept code 'res' as valid
      if (code == 'res') {
        _scannedCode = code;
        _isValidating = false;
        notifyListeners();
        return QrScanResult.success(code);
      } else {
        _errorMessage = 'Invalid QR code for this class session';
        _isValidating = false;
        notifyListeners();
        return QrScanResult.failure(_errorMessage ?? '');
      }
    } catch (e) {
      _errorMessage = 'Failed to validate QR code: ${e.toString()}';
      _isValidating = false;
      notifyListeners();
      return QrScanResult.failure(_errorMessage!);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _scannedCode = null;
    _isValidating = false;
    _errorMessage = null;
    notifyListeners();
  }
}
