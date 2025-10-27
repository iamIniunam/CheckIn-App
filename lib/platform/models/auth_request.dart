// sign_up_request.dart
class SignUpRequest {
  final String idNumber;
  final String firstName;
  final String lastName;
  final String program;
  final String password;

  SignUpRequest({
    required this.idNumber,
    required this.firstName,
    required this.lastName,
    required this.program,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'idnumber': idNumber,
      'first_name': firstName,
      'last_name': lastName,
      'program': program,
      'password': password,
    };
  }

  // Validation
  String? validate() {
    if (idNumber.trim().isEmpty) {
      return 'ID number is required';
    }
    if (firstName.trim().isEmpty) {
      return 'First name is required';
    }
    if (lastName.trim().isEmpty) {
      return 'Last name is required';
    }
    if (program.trim().isEmpty) {
      return 'Program is required';
    }
    if (password.trim().isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

// login_request.dart
class LoginRequest {
  final String idNumber;
  final String password;

  LoginRequest({
    required this.idNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'idnumber': idNumber,
      'password': password,
    };
  }

  String? validate() {
    if (idNumber.trim().isEmpty) {
      return 'ID number is required';
    }
    if (password.trim().isEmpty) {
      return 'Password is required';
    }
    return null;
  }
}
