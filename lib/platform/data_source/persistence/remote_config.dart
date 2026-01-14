import 'package:attendance_app/platform/data_source/persistence/manager.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class AppRemoteConfig {
  static FirebaseRemoteConfig? _firebaseRemoteConfig;
  static PreferenceManager manager = AppDI.getIt<PreferenceManager>();

  static Future init() async {
    _firebaseRemoteConfig ??= FirebaseRemoteConfig.instance;

    await _firebaseRemoteConfig?.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        // minimumFetchInterval: const Duration(minutes: 1),
        minimumFetchInterval: Duration.zero,
      ),
    );

    await _firebaseRemoteConfig?.fetchAndActivate();
  }


  static Future fetchRemoteConfigBooleanData(String remoteKey) async {
    try {
      var remoteConfigData = _firebaseRemoteConfig?.getBool(remoteKey);
      if (remoteConfigData != null) {
        manager.setBoolPreference(key: remoteKey, value: remoteConfigData);
      }
    } catch (e) {
      if (kDebugMode) {
        print("fetchRemoteConfig $remoteKey $e");
      }
    }
    return manager.getBoolPreference(key: remoteKey);
  }
  
  Future<void> fetchRemoteConfigNumericalData(String remoteKey) async {
    try {
      var remoteConfigData = _firebaseRemoteConfig?.getDouble(remoteKey) ?? 0.0;
      if (remoteConfigData != 0.0) {
        await manager.setPreference(
            key: remoteKey, value: remoteConfigData.toString());
        if (kDebugMode) {
          print("Saved $remoteKey to preferences: $remoteConfigData");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("fetchRemoteConfig $remoteKey $e");
      }
    }
  }
}
