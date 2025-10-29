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

  String? get scannedCode => _scannedCode;
  bool get isScanning => _isScanning;

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
}
