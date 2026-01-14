import 'package:attendance_app/platform/data_source/persistence/manager.dart';
import 'package:attendance_app/platform/data_source/persistence/models/remote_config_models.dart';
import 'package:attendance_app/platform/data_source/persistence/remote_config.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';

class RemoteConfigViewModel {
  final PreferenceManager manager = AppDI.getIt<PreferenceManager>();
  final AppRemoteConfig remoteConfig = AppRemoteConfig();

  double? _cachedMaxDistance;
  bool? _cachedShowLogoutButton;

  Future<void> initialize() async {
    await remoteConfig
        .fetchRemoteConfigNumericalData(RemoteConfigKeys.maxCheckInDistance);
    await AppRemoteConfig.fetchRemoteConfigBooleanData(
        RemoteConfigKeys.showLogoutButton);

    _cachedMaxDistance = await getMaxCheckInDistance();
    _cachedShowLogoutButton = await getShowLogoutButton();
  }

  Future<double> getMaxCheckInDistance() async {
    final cachedValueStr =
        await manager.getPreference(key: RemoteConfigKeys.maxCheckInDistance);
    final cachedValue = double.tryParse(cachedValueStr.toString());
    return cachedValue ?? 13.38;
  }

  double get maxCheckInDistance {
    return _cachedMaxDistance ?? 13.38;
  }

  Future<bool> getShowLogoutButton() async {
    final cachedValue = await manager.getBoolPreference(
      key: RemoteConfigKeys.showLogoutButton,
    );
    return cachedValue ?? true;
  }

  bool get showLogoutButton {
    return _cachedShowLogoutButton ?? true;
  }
}
