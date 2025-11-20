import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final canUseBiometrics = await _auth.canCheckBiometrics;
      final availableBiometrics = await _auth.getAvailableBiometrics();
      final hasStrongBiometrics = availableBiometrics.isNotEmpty;

      if (hasStrongBiometrics && canUseBiometrics) {
        return await _auth.authenticate(
          localizedReason: 'Authenticate to continue',
          options: const AuthenticationOptions(biometricOnly: true),
        );
      }

      return await _auth.authenticate(
        localizedReason: 'Enter device password to continue',
        options: const AuthenticationOptions(biometricOnly: false),
      );
    } catch (e) {
      debugPrint('Authentication error: $e');
      return false;
    }
  }
}
