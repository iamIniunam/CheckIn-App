import 'package:attendance_app/platform/data_source/api/api_base_models.dart';

class StudentProfile extends Serializable {
  String? idNumber;
  String? firstName;
  String? lastName;
  String? program;

  StudentProfile({
    this.idNumber,
    this.firstName,
    this.lastName,
    this.program,
  });

  String fullName() {
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      idNumber: json['idnumber']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      program: json['program']?.toString() ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'idnumber': idNumber,
      'first_name': firstName,
      'last_name': lastName,
      'program': program,
    };
  }
}
