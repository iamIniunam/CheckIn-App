import 'package:attendance_app/platform/data_source/api/api_base_models.dart';
import 'package:attendance_app/platform/data_source/api/auth/models/auth_response.dart';

class AppUser extends Serializable {
  StudentProfile? studentProfile;

  AppUser({this.studentProfile});

  factory AppUser.fromJson(Map<dynamic, dynamic>? json) {
    return AppUser(
      studentProfile: json?['student_profile'] != null
          ? StudentProfile.fromJson(json?['student_profile'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'student_profile': studentProfile?.toMap(),
    };
  }
}
