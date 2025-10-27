// import 'package:attendance_app/ux/shared/resources/app_constants.dart';
// import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class UserViewModel extends ChangeNotifier {
//   UserViewModel({required this.pref, required this.authViewModel}) {
//     authViewModel.addListener(onAuthChanged);
//   }

//   final SharedPreferences pref;
//   final AuthViewModel authViewModel;

//   void onAuthChanged() {
//     notifyListeners();
//   }

//   String get idNumber => authViewModel.currentStudent?.idNumber ?? '';
//   String get level => authViewModel.currentStudent?.level ?? '';
//   String get program => authViewModel.currentStudent?.program ?? '';
//   int get semester => authViewModel.currentStudent?.semester ?? 0;
//   String get firstName => authViewModel.currentStudent?.firstName ?? '';
//   String get lastName => authViewModel.currentStudent?.lastName ?? '';

//   String get fullName => '$lastName, $firstName';

//   String getUserPrimarySchool(Map<dynamic, String?> chosenSchools) {
//     if (chosenSchools.isEmpty) return '';

//     final Map<String, int> schoolCounts = {};
//     for (final school in chosenSchools.values) {
//       if (school != null && school.isNotEmpty) {
//         schoolCounts[school] = (schoolCounts[school] ?? 0) + 1;
//       }
//     }

//     if (schoolCounts.isEmpty) return '';

//     String primarySchool = '';
//     int maxCount = 0;

//     schoolCounts.forEach((school, count) {
//       if (count > maxCount) {
//         maxCount = count;
//         primarySchool = school;
//       }
//     });

//     return primarySchool;
//   }

//   Future<void> savePrimarySchool(String school) async {
//     await pref.setString(AppConstants.userSchoolKey, school);
//     notifyListeners();
//   }

//   String get savedPrimarySchool =>
//       pref.getString(AppConstants.userSchoolKey) ?? '';
// }
