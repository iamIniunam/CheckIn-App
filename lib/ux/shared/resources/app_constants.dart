class AppConstants {
  AppConstants._();

  // static const apiBaseUrl = 'http://10.36.218.84:8000/api';
  static const apiBaseUrl = 'http://192.168.100.5:8000/api';

  static const appUser = 'app.user';

  static const similarittyThreshold = 0.70;
  static int embeddingSize = 128;

  static const double houseLat = 5.5328015;
  static const double houseLong = -0.3264844;

  static const double chisomLat = 5.5321914;
  static const double chisomLong = -0.3315539;

  static const double bmfLat = 5.5340481;
  static const double bmfLong = -0.3311139;

  static const double seaviewLat = 5.5355513;
  static const double seaviewLong = -0.331639;
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

  static const List<String> programs = [
    'BSc. Information Technology',
    'BSc. Computer Science',
    'BSc. Business Administration (Accounting & Finance)',
    'BSc. Business Administration (E-Commerce)',
    'BSc. Business Administration (HRM & IT)',
    'BSc. Business Administration (Marketing & IT)',
    'BEng. Computer Engineering',
    'BEng. Electrical Electronics Engineering',
    'BEng. Civil Engineering',
  ];

  static int getProgramId(String program) {
    final index = programs.indexOf(program);
    return index != -1 ? index + 1 : 0;
  }

  static String getProgramName(int id) {
    final index = id - 1;
    return (index >= 0 && index < programs.length) ? programs[index] : '';
  }
}
