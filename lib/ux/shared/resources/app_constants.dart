class AppConstants {
  AppConstants._();

  static const appUser = 'app.user';

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
