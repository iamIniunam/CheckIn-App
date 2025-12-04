import 'package:attendance_app/platform/utils/course_search_helper.dart';
import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/course/models/course_request.dart';
import 'package:attendance_app/platform/data_source/api/course/models/course_response.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/platform/extensions/string_extensions.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:flutter/material.dart';

class CourseViewModel extends ChangeNotifier {
  final Api _api = AppDI.getIt<Api>();

  ValueNotifier<UIResult<List<Course>>> registeredCoursesResult =
      ValueNotifier(UIResult.empty());
  ValueNotifier<UIResult<RegisterCoursesProgress>> registerCoursesResult =
      ValueNotifier(UIResult.empty());
  ValueNotifier<UIResult<bool>> dropCourseResult =
      ValueNotifier(UIResult.empty());

  List<Course> _registeredCourses = [];
  String? _lastLoadedStudentId;
  String _searchQuery = '';

  // Getters
  List<Course> get registeredCourses => List.unmodifiable(_registeredCourses);
  String get searchQuery => _searchQuery;

  int get totalRegisteredCredits {
    return _registeredCourses.fold(
        0, (sum, course) => sum + (course.creditHours ?? 0));
  }

  int get remainingCredits {
    final remaining = AppConstants.requiredCreditHours - totalRegisteredCredits;
    return remaining > 0 ? remaining : 0;
  }

  List<Course> get displayedCourses {
    final courseToSearch = _registeredCourses;

    if (_searchQuery.isEmpty) {
      return List.unmodifiable(courseToSearch);
    }

    return CourseSearchHelper.searchCourses(courseToSearch, _searchQuery);
  }

  // Helper methods
  Course? findExistingById(int? id) {
    if (id == null) return null;
    for (final rc in _registeredCourses) {
      if (rc.id != null && rc.id == id) return rc;
    }
    return null;
  }

  Course? findExistingSameSchool(String courseCode, String school) {
    for (final rc in _registeredCourses) {
      if (rc.courseCode == courseCode && (rc.school ?? '').trim() == school) {
        return rc;
      }
    }
    return null;
  }

  Set<String> existingOtherSchoolsForCode(String courseCode) {
    return _registeredCourses
        .where((rc) => rc.courseCode == courseCode)
        .map((rc) => (rc.school ?? '').trim())
        .where((s) => s.isNotEmpty)
        .toSet();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<UIResult<List<Course>>> loadRegisteredCourses(String studentId,
      {bool forceRefresh = false}) async {
    final hasLoaded = registeredCoursesResult.value.state == UIState.success;
    if (hasLoaded && !forceRefresh && _lastLoadedStudentId == studentId) {
      return registeredCoursesResult.value;
    }

    if (studentId.trim().isEmpty) {
      registeredCoursesResult.value =
          UIResult.error(message: 'No student id provided');
      _registeredCourses = [];
      notifyListeners();
      return registeredCoursesResult.value;
    }

    registeredCoursesResult.value = UIResult.loading();

    try {
      final request = GetRegisteredCoursesRequest(studentId: studentId);
      final response = await _api.courseApi.getRegisteredCourses(request);

      if (response.status == ApiResponseStatus.Success &&
          response.response != null) {
        _registeredCourses = response.response as List<Course>;
        _lastLoadedStudentId = studentId;

        registeredCoursesResult.value = UIResult.success(
          data: _registeredCourses,
          message: response.message,
        );
        notifyListeners();
        return registeredCoursesResult.value;
      } else {
        _registeredCourses = [];
        _lastLoadedStudentId = studentId;

        registeredCoursesResult.value = UIResult.error(
          message: response.message ?? 'Failed to load registered courses',
        );
        notifyListeners();
        return registeredCoursesResult.value;
      }
    } catch (e) {
      _registeredCourses = [];
      _lastLoadedStudentId = studentId;

      registeredCoursesResult.value = UIResult.error(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
      notifyListeners();
      return registeredCoursesResult.value;
    }
  }

  Future<UIResult<RegisterCoursesProgress>> registerCourses({
    required String studentId,
    required List<Course> courses,
    bool isAdding = false,
  }) async {
    // Validate duplicates
    final duplicateDetails = _checkForDuplicates(courses);
    if (duplicateDetails.isNotEmpty) {
      final details = duplicateDetails.join('\n');
      final count = duplicateDetails.length;
      final errorMessage =
          'Duplicate ${'course'.pluralize(count)} found:\n$details\n\nRemove ${count == 1 ? 'it' : 'them'} to continue.';

      registerCoursesResult.value = UIResult.error(message: errorMessage);
      return registerCoursesResult.value;
    }

    // Validate credit hours
    final creditValidation = _validateCredits(courses, isAdding);
    if (creditValidation != null) {
      registerCoursesResult.value = UIResult.error(message: creditValidation);
      return registerCoursesResult.value;
    }

    // Validate course code conflicts
    final conflictValidation = _validateCourseCodeConflicts(courses);
    if (conflictValidation != null) {
      registerCoursesResult.value = UIResult.error(message: conflictValidation);
      return registerCoursesResult.value;
    }

    // Start registration
    final totalCourses = courses.length;
    int coursesRegistered = 0;
    List<String> failedCourses = [];

    registerCoursesResult.value = UIResult.loading(
      data: RegisterCoursesProgress(
        total: totalCourses,
        completed: coursesRegistered,
        failed: failedCourses,
      ),
    );

    try {
      for (final course in courses) {
        if (course.id == null) {
          debugPrint('Skipping ${course.courseCode} - no ID');
          failedCourses.add('${course.courseCode} (No ID)');
          continue;
        }

        try {
          final request = RegisterCourseRequest(
            courseId: course.id ?? 0,
            studentId: studentId,
          );

          final response = await _api.courseApi.registerCourse(request);

          if (response.status == ApiResponseStatus.Success) {
            coursesRegistered++;
            debugPrint('Successfully registered ${course.courseCode}');
          } else {
            failedCourses
                .add('${course.courseCode} (Error: ${response.message})');
            debugPrint(
                'Failed to register ${course.courseCode}: ${response.message}');
          }
        } catch (e) {
          failedCourses.add('${course.courseCode} (Error: $e)');
          debugPrint('Error registering ${course.courseCode}: $e');
        }

        // Update progress
        registerCoursesResult.value = UIResult.loading(
          data: RegisterCoursesProgress(
            total: totalCourses,
            completed: coursesRegistered,
            failed: failedCourses,
          ),
        );
      }

      final allSuccess = failedCourses.isEmpty;

      // Reload registered courses
      await loadRegisteredCourses(studentId, forceRefresh: true);

      if (allSuccess) {
        registerCoursesResult.value = UIResult.success(
          data: RegisterCoursesProgress(
            total: totalCourses,
            completed: coursesRegistered,
            failed: failedCourses,
          ),
          message: 'Successfully registered all courses',
        );
        return registerCoursesResult.value;
      } else {
        final message = failedCourses.length == totalCourses
            ? 'Failed to register all courses'
            : 'Successfully registered $coursesRegistered of $totalCourses courses';

        if (coursesRegistered > 0) {
          registerCoursesResult.value = UIResult.success(
            data: RegisterCoursesProgress(
              total: totalCourses,
              completed: coursesRegistered,
              failed: failedCourses,
            ),
            message: message,
          );
        } else {
          registerCoursesResult.value = UIResult.error(
            message: message,
            data: RegisterCoursesProgress(
              total: totalCourses,
              completed: coursesRegistered,
              failed: failedCourses,
            ),
          );
        }
        return registerCoursesResult.value;
      }
    } catch (e) {
      registerCoursesResult.value = UIResult.error(
        message: 'An unexpected error occurred: ${e.toString()}',
        data: RegisterCoursesProgress(
          total: totalCourses,
          completed: coursesRegistered,
          failed: failedCourses,
        ),
      );
      return registerCoursesResult.value;
    }
  }

  Future<UIResult<bool>> dropCourse({
    required String studentId,
    required int courseId,
  }) async {
    dropCourseResult.value = UIResult.loading();

    try {
      final request =
          DropCourseRequest(courseId: courseId, studentId: studentId);

      final response = await _api.courseApi.dropCourse(request);

      if (response.status == ApiResponseStatus.Success) {
        // Reload registered courses
        // await loadRegisteredCourses(studentId, forceRefresh: true);

        dropCourseResult.value = UIResult.success(
          data: true,
          message: 'Course dropped successfully',
        );
        return dropCourseResult.value;
      } else {
        dropCourseResult.value = UIResult.error(
          message: response.message ?? 'Failed to drop course',
        );
        return dropCourseResult.value;
      }

      // if (response.status == ApiResponseStatus.Success) {
      //   final isError = response.response?['error'] == true;

      //   if (isError) {
      //     dropCourseResult.value = UIResult.error(
      //       message: response.response?.message ?? 'Failed to drop course',
      //     );
      //     return dropCourseResult.value;
      //   }

      //   // Reload registered courses
      //   await loadRegisteredCourses(studentId, forceRefresh: true);

      //   dropCourseResult.value = UIResult.success(
      //     data: true,
      //     message: response.message ?? 'Course dropped successfully',
      //   );
      //   return dropCourseResult.value;
      // }

      // dropCourseResult.value = UIResult.error(
      //   message: response.message ?? 'Failed to drop course',
      // );
      // return dropCourseResult.value;
    } catch (e) {
      dropCourseResult.value = UIResult.error(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
      return dropCourseResult.value;
    }
  }

  List<String> _checkForDuplicates(List<Course> courses) {
    final List<String> duplicateDetails = [];
    final Set<String> seenCourseCodes = {};

    for (final course in courses) {
      final courseCode = course.courseCode;
      if (seenCourseCodes.contains(courseCode)) continue;

      final school = (course.school ?? '').trim();
      final existingById = findExistingById(course.id);

      if (existingById != null) {
        duplicateDetails.add(
            '$courseCode is already registered${existingById.school != null && (existingById.school ?? '').isNotEmpty ? ' under ${existingById.school}' : ''}');
        seenCourseCodes.add(courseCode ?? '');
        continue;
      }

      final existingSameSchool = findExistingSameSchool(courseCode ?? '', school);
      if (existingSameSchool != null) {
        duplicateDetails
            .add('$courseCode${school.isNotEmpty ? ' — $school' : ''}');
        seenCourseCodes.add(courseCode ?? '');
        continue;
      }

      final existingOtherSchools = existingOtherSchoolsForCode(courseCode ?? '');
      if (existingOtherSchools.isNotEmpty &&
          !(existingOtherSchools.length == 1 &&
              existingOtherSchools.contains(school))) {
        duplicateDetails.add(
            '$courseCode is already registered under ${existingOtherSchools.join(', ')}');
        seenCourseCodes.add(courseCode ?? '');
        continue;
      }
    }

    return duplicateDetails;
  }

  String? _validateCredits(List<Course> courses, bool isAdding) {
    final int newCredits =
        courses.fold(0, (sum, course) => sum + (course.creditHours ?? 0));

    int currentCredits = 0;
    if (isAdding) {
      currentCredits = _registeredCourses.fold(
          0, (sum, course) => sum + (course.creditHours ?? 0));
    }

    final int totalCredits = currentCredits + newCredits;

    if (totalCredits > AppConstants.requiredCreditHours) {
      return isAdding
          ? 'Cannot add $newCredits credits. You currently have $currentCredits, which would exceed the max of ${AppConstants.requiredCreditHours} (total $totalCredits).'
          : 'Total $totalCredits credits exceed the max of ${AppConstants.requiredCreditHours}. You currently have $currentCredits.';
    }

    return null;
  }

  String? _validateCourseCodeConflicts(List<Course> courses) {
    final Map<String, Set<String>> codeToSchools = {};
    for (final course in courses) {
      final code = course.courseCode;
      final school = (course.school ?? '').trim();
      codeToSchools.putIfAbsent(code ?? '', () => <String>{});
      codeToSchools[code]?.add(school);
    }

    final conflicts = codeToSchools.entries
        .where((e) => e.value.length > 1)
        .toList(growable: false);

    if (conflicts.isNotEmpty) {
      final details = conflicts
          .map((e) =>
              '${e.key} — ${e.value.where((s) => s.isNotEmpty).join(', ')}')
          .join('; ');
      return 'Duplicate course codes found in multiple schools: $details. \n\nPlease select only one.';
    }

    return null;
  }

  Future<Future<UIResult<List<Course>>>> reloadRegisteredCourses(
      String studentId) async {
    return loadRegisteredCourses(studentId, forceRefresh: true);
  }

  void clearRegisteredCoursesError() {
    if (registeredCoursesResult.value.state == UIState.error) {
      registeredCoursesResult.value = UIResult.empty();
    }
  }

  void clearRegistrationError() {
    if (registerCoursesResult.value.state == UIState.error) {
      registerCoursesResult.value = UIResult.empty();
    }
  }

  // Clear all in-memory course state (useful on logout)
  void clear() {
    _registeredCourses = [];
    _lastLoadedStudentId = null;
    _searchQuery = '';
    registeredCoursesResult.value = UIResult.empty();
    registerCoursesResult.value = UIResult.empty();
    notifyListeners();
  }
}

class RegisterCoursesProgress {
  final int total;
  final int completed;
  final List<String> failed;

  RegisterCoursesProgress({
    required this.total,
    required this.completed,
    required this.failed,
  });

  double get progress => total > 0 ? completed / total : 0.0;
  bool get hasFailures => failed.isNotEmpty;
  bool get isComplete => completed + failed.length >= total;
}
