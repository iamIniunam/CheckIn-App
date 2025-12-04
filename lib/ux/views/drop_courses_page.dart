import 'dart:async';

import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/platform/utils/general_utils.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/course/components/course_search_bottom_widgets.dart';
import 'package:attendance_app/ux/views/drop_courses_search_state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DropCoursesPage extends StatefulWidget {
  const DropCoursesPage({super.key});

  @override
  State<DropCoursesPage> createState() => _DropCoursesPageState();
}

class _DropCoursesPageState extends State<DropCoursesPage> {
  final AuthViewModel _authViewModel = AppDI.getIt<AuthViewModel>();
  final TextEditingController searchController = TextEditingController();
  final Set<int> _selectedCourseIds = {};
  Timer? _searchDebounce;

  late final CourseViewModel courseViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadRegisteredCourses();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    courseViewModel = context.read<CourseViewModel>();
  }

  Future<void> loadRegisteredCourses() async {
    final studentId = _authViewModel.appUser?.studentProfile?.idNumber;
    if (studentId != null) {
      await courseViewModel.loadRegisteredCourses(studentId);
    }
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      courseViewModel.updateSearchQuery(value.trim());
    });
  }

  void clearSearch() {
    searchController.clear();
    courseViewModel.clearSearch();
  }

  void toggleCourseSelection(int courseId) {
    setState(() {
      if (_selectedCourseIds.contains(courseId)) {
        _selectedCourseIds.remove(courseId);
      } else {
        _selectedCourseIds.add(courseId);
      }
    });
  }

  bool isCourseSelected(int courseId) {
    return _selectedCourseIds.contains(courseId);
  }

  int getRemainingCredits() {
    final allCourses = courseViewModel.registeredCourses;
    final total = allCourses.fold<int>(
      0,
      (sum, course) => sum + (course.creditHours ?? 0),
    );
    final selectedTotal = allCourses
        .where((c) => _selectedCourseIds.contains(c.id))
        .fold<int>(0, (sum, course) => sum + (course.creditHours ?? 0));
    final remaining = total - selectedTotal;
    return remaining < 0 ? 0 : remaining;
  }

  Future<void> onDropPressed() async {
    if (_selectedCourseIds.isEmpty) {
      AppDialogs.showErrorDialog(
        context: context,
        message: 'Please select at least one course to drop',
      );
      return;
    }

    final confirmed = await AppDialogs.showWarningDialog(
      context: context,
      title: 'Confirm Drop',
      message:
          'Are you sure you want to drop ${_selectedCourseIds.length} course${_selectedCourseIds.length == 1 ? '' : 's'}?',
      secondOption: 'Yes, drop',
      onSecondOptionTap: () {
        Navigation.back(context: context, result: true);
      },
    );
    if (!confirmed) return;

    final studentId = _authViewModel.appUser?.studentProfile?.idNumber;
    if (studentId == null && mounted) {
      AppDialogs.showErrorDialog(
        context: context,
        message: 'Student ID not found. Please log in again.',
      );
      return;
    }
    await dropSelectedCourses(studentId ?? '');
  }

  Future<void> dropSelectedCourses(String studentId) async {
    int successCount = 0;
    int failCount = 0;
    final List<String> failedCourses = [];

    AppDialogs.showLoadingDialog(context);

    for (final courseId in _selectedCourseIds) {
      try {
        final result = await courseViewModel.dropCourse(
          studentId: studentId,
          courseId: courseId,
        );

        if (result.state == UIState.success) {
          successCount++;
        } else {
          failCount++;
          final course = courseViewModel.registeredCourses.firstWhere(
              (c) => c.id == courseId,
              orElse: () => null as dynamic);
          failedCourses.add(course.courseCode);
        }
      } catch (e) {
        failCount++;
        failedCourses.add('Course $courseId');
      }
    }

    if (!mounted) return;
    Navigation.back(context: context);

    // Clear selection after dropping
    setState(() {
      _selectedCourseIds.clear();
    });

    // Show result
    if (failCount == 0) {
      AppDialogs.showSuccessDialog(
        context: context,
        message:
            'Successfully dropped $successCount course${successCount == 1 ? '' : 's'}',
      );
    } else if (successCount > 0) {
      showPartialSuccessDialog(successCount, failedCourses);
    } else {
      AppDialogs.showErrorDialog(
        context: context,
        message: 'Failed to drop courses',
      );
    }
  }

  void showPartialSuccessDialog(int successCount, List<String> failedCourses) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partial Success'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Successfully dropped $successCount course${successCount == 1 ? '' : 's'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (failedCourses.isNotEmpty) ...[
              const Text('Failed to drop:'),
              const SizedBox(height: 8),
              ...failedCourses.map(
                (course) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text('• $course'),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Drop Courses',
      body: RefreshIndicator(
        onRefresh: loadRegisteredCourses,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchTextFormField(
                controller: searchController,
                onClear: clearSearch,
                hintText: AppStrings.searchByCourseCodeOrTitle,
                onSubmitted: (value) {
                  if (value.trim().isEmpty) return;
                  courseViewModel.updateSearchQuery(value.trim());
                  Utils.hideKeyboard();
                },
                onChanged: onSearchChanged,
              ),
            ),
            Consumer<CourseViewModel>(
              builder: (context, viewModel, _) {
                return Expanded(
                  child: Column(
                    children: [
                      RegisteredCourseListContent(
                        viewModel: viewModel,
                        selectedCourseIds: _selectedCourseIds,
                        onCourseToggle: toggleCourseSelection,
                        isCourseSelected: isCourseSelected,
                      ),
                      ConfirmationSection(
                        isSelected: _selectedCourseIds.isNotEmpty,
                        totalCreditHours: getRemainingCredits(),
                        onConfirmPressed: onDropPressed,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
