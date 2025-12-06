import 'package:attendance_app/platform/data_source/api/api_base_models.dart';

class SignUpRequest extends Serializable {
  final String? idNumber;
  final String? firstName;
  final String? lastName;
  final String? program;
  final String? password;

  SignUpRequest({
    this.idNumber,
    this.firstName,
    this.lastName,
    this.program,
    this.password,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'idnumber': idNumber,
      'first_name': firstName,
      'last_name': lastName,
      'program': program,
      'password': password,
    };
  }

  String? validate() {
    if ((idNumber ?? '').trim().isEmpty) {
      return 'ID number is required';
    }
    if ((firstName ?? '').trim().isEmpty) {
      return 'First name is required';
    }
    if ((lastName ?? '').trim().isEmpty) {
      return 'Last name is required';
    }
    if ((program ?? '').trim().isEmpty) {
      return 'Program is required';
    }
    if ((password ?? '').trim().isEmpty) {
      return 'Password is required';
    }
    if ((password ?? '').length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

class LoginRequest extends Serializable {
  final String? idNumber;
  final String? password;

  LoginRequest({
    this.idNumber,
    this.password,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'idnumber': idNumber,
      'password': password,
    };
  }

  String? validate() {
    if ((idNumber ?? '').trim().isEmpty) {
      return 'ID number is required';
    }
    if ((password ?? '').trim().isEmpty) {
      return 'Password is required';
    }
    return null;
  }
}
