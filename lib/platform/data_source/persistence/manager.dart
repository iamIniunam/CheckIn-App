import 'package:shared_preferences/shared_preferences.dart';

class PreferenceManager {
  final SharedPreferences _preference;

  PreferenceManager(this._preference);

  SharedPreferences get sharedPreference => _preference;

  void setBoolPreference({String? key, bool? value}) async {
    await _preference.setBool(key ?? "", value ?? false);
  }

  Future<bool?> getBoolPreference({String? key}) async {
    return _preference.getBool(key ?? "");
  }

  void setPreference({String? key, String? value}) async {
    await _preference.setString(key ?? "", value ?? "");
  }

  Future<String> getPreference({String? key}) async {
    return _preference.getString(key ?? "") ?? "";
  }

  Future<List<String>> getPreferenceList({String? key}) async {
    return _preference.getStringList(key ?? "") ?? [];
  }

  void setPreferenceList(
      {required String key, required List<String> value}) async {
    await _preference.setStringList(key, value);
  }
}
