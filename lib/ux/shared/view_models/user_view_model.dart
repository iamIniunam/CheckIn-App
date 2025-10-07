import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserViewModel extends ChangeNotifier {
  UserViewModel({required this.pref});

  final SharedPreferences pref;

  String get idNumber => pref.getString(AppConstants.idNumberKey) ?? '';
  String get level => pref.getString(AppConstants.levelKey) ?? '';
  String get program => pref.getString(AppConstants.programKey) ?? '';
  int get semester => pref.getInt(AppConstants.semesterKey) ?? 0;
  String get password => pref.getString(AppConstants.passwordKey) ?? '';

  String getUserPrimaryStream(Map<dynamic, String?> chosenStreams) {
    if (chosenStreams.isEmpty) return '';

    final Map<String, int> streamCounts = {};
    for (final stream in chosenStreams.values) {
      if (stream != null && stream.isNotEmpty) {
        streamCounts[stream] = (streamCounts[stream] ?? 0) + 1;
      }
    }

    if (streamCounts.isEmpty) return '';

    String primaryStream = '';
    int maxCount = 0;

    streamCounts.forEach((stream, count) {
      if (count > maxCount) {
        maxCount = count;
        primaryStream = stream;
      }
    });

    return primaryStream;
  }

  Future<void> savePrimaryStream(String stream) async {
    await pref.setString(AppConstants.userStreamKey, stream);
    notifyListeners();
  }

  String get savedPrimaryStream =>
      pref.getString(AppConstants.userStreamKey) ?? '';
}
