import 'package:attendance_app/ux/shared/models/ui_models.dart';

class CourseSearchHelper {
  static List<Course> searchCourses(List<Course> courses, String query) {
    if (query.isEmpty) return courses;

    final searchQuery = query.trim().toLowerCase();

    return courses.where((course) {
      return matchesCourse(course, searchQuery);
    }).toList();
  }

  static bool matchesCourse(Course course, String searchQuery) {
    final codeMatch = course.courseCode.toLowerCase();
    final nameMatch = (course.courseTitle ?? '').toLowerCase();
    final schoolMatch = (course.school ?? '').toLowerCase();

    return codeMatch.contains(searchQuery) ||
        nameMatch.contains(searchQuery) ||
        schoolMatch.contains(searchQuery);
  }

  static int getResultCount(List<Course> allCourses, String query) {
    return searchCourses(allCourses, query).length;
  }

  static bool hasResults(List<Course> allCourses, String query) {
    return getResultCount(allCourses, query) > 0;
  }
}
