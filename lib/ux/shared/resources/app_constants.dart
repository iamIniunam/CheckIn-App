class AppConstants {
  AppConstants._();

  static const apiBaseUrl = 'http://192.168.100.14:8000/api';

  static const isLoggedInKey = 'is.logged.in';
  static const studentDataKey = 'student.data';
  static const levelKey = 'level';
  static const semesterKey = 'semester';
  static const passwordKey = 'password';
  static const userSchoolKey = 'user.school';
  static const appUserKey = 'app.user';

  static const similarittyThreshold = 0.70;
  static int embeddingSize = 128;

  static const double houseLat = 5.5328015;
  static const double houseLong = -0.3264844;

  static const double chisomLat = 5.5321914;
  static const double chisomLong = -0.3315539;

  static const double bmfLat = 5.5340481;
  static const double bmfLong = -0.3311139;

  static const double seaviewLat = 5.5374258;
  static const double seaviewLong = -0.3328109;
  // static const double seaviewLat = 5.5374063;
  // static const double seaviewLong = -0.3328215;

  static const double kccLat = 5.5334916; // replace with actual values
  static const double kccLong = -0.3258892; // replace with actual values
  static const double maxDistanceMeters = 50;

  static const double buildingGpsAccuracyThreshold = 50.0; // meters
  static const double networkLocationBuffer =
      200.0; // extra meters for network location

  static const int requiredCreditHours = 18;
  static const List<String> schools = [
    'Seaview (Day)',
    'KCC (Evening)',
    'Seaview (Weekend)',
    'KCC (Weekend)',
  ];

  static const List<int> levels = [100, 200, 300, 400];
  static const List<int> semesters = [1, 2];

  static const String selectedCoursesKey = 'selected.courses';
  static const String selectedSchoolsKey = 'selected.schools';

  static const List<String> programs = [
    'BSc. Information Technology', //id 1
    'BSc. Computer Science', //id 2
    'BSc. Business Administration (Accounting & Finance)', //id 3
    'BSc. Business Administration (E-Commerce)', //id 4
    'BSc. Business Administration (HRM & IT)', //id 5
    'BSc. Business Administration (Marketing & IT)', //id 6
    'BEng. Computer Engineering', //id 7
    'BEng. Electrical Electronics Engineering', //id 8
    'BEng. Civil Engineering', //id 9
  ];

  static const String programKey = 'selected.program';
  static const String programIdKey = 'selected.program.id';

  static int getProgramId(String program) {
    final index = programs.indexOf(program);
    return index != -1 ? index + 1 : 0;
  }

  static String getProgramName(int id) {
    final index = id - 1;
    return (index >= 0 && index < programs.length) ? programs[index] : '';
  }
}
