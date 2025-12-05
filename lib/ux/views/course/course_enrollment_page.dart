import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/bottom_sheets/show_app_bottom_sheet.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_search_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/course/components/course_search_bottom_widgets.dart';
import 'package:attendance_app/ux/views/course/components/course_search_state_widgets.dart';
import 'package:attendance_app/ux/views/course/components/search_and_filter_bar.dart';
import 'package:attendance_app/ux/views/course/course_registration_info_bottom_sheet.dart';
import 'package:attendance_app/ux/views/course/filter_courses_bottom_page.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CourseEnrollmentPage extends StatefulWidget {
  const CourseEnrollmentPage({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  State<CourseEnrollmentPage> createState() => _CourseEnrollmentPageState();
}

class _CourseEnrollmentPageState extends State<CourseEnrollmentPage> {
  final AuthViewModel _authViewModel = AppDI.getIt<AuthViewModel>();

  late final TextEditingController searchController;
  late final CourseSearchViewModel searchViewModel;
  late final CourseViewModel courseViewModel;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    searchViewModel = context.read<CourseSearchViewModel>();
    courseViewModel = context.read<CourseViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchViewModel.clearSearch();
      searchViewModel.clearFilter();
      searchViewModel.clearSelectedCourses();
      searchViewModel.loadAllCourses();
    });
  }

  Future<void> refreshAllCourses() async {
    searchViewModel.reloadAllCourses();
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = null;
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      searchViewModel.searchCourses(value.trim());
    });
  }

  void clearSearch() {
    searchController.clear();
    searchViewModel.clearSearch();
  }

  Future<void> onConfirmPressed() async {
    final studentId = _authViewModel.appUser?.studentProfile?.idNumber;

    if (studentId == null) {
      AppDialogs.showErrorDialog(
        context: context,
        message: 'Student ID not found. Please log in again.',
      );
      return;
    }

    if (!validateCourseSelection()) return;

    AppDialogs.showLoadingDialog(context,
        loadingText: widget.isEdit ? null : 'Registering courses...');

    final success = await registerCourses(studentId);

    if (!mounted) return;
    Navigation.back(context: context);
    handleRegistrationResult(success);
  }

  bool validateCourseSelection() {
    if (searchViewModel.selectedCourses.isEmpty) {
      AppDialogs.showErrorDialog(
        context: context,
        message: 'Please select at least one course',
      );
      return false;
    }

    if (searchViewModel.totalCreditHours > AppConstants.requiredCreditHours) {
      AppDialogs.showErrorDialog(
        context: context,
        message: 'Total credit hours exceeds the maximum allowed',
      );
      return false;
    }

    return true;
  }

  Future<UIResult<RegisterCoursesProgress>> registerCourses(
      String studentId) async {
    return await courseViewModel.registerCourses(
      studentId: studentId,
      courses: searchViewModel.selectedCourses.toList(),
      isAdding: widget.isEdit,
    );
  }

  void handleRegistrationResult(UIResult<RegisterCoursesProgress> result) {
    if (result.state == UIState.success) {
      final progress = result.data;
      if (progress != null && progress.hasFailures) {
        showPartialSuccessDialog(progress);
      } else {
        widget.isEdit
            ? showSuccessDialog()
            : Navigation.navigateToHomePage(context: context);
      }
    } else if (result.state == UIState.error) {
      AppDialogs.showErrorDialog(
        context: context,
        message: result.message ?? 'Failed to register courses',
      );
    }
  }

  void showSuccessDialog() {
    const message = 'Courses updated successfully';

    AppDialogs.showSuccessDialog(
      context: context,
      message: message,
      action: () => Navigation.back(context: context),
    );
  }

  void showPartialSuccessDialog(RegisterCoursesProgress progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partial Success'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registered ${progress.completed} of ${progress.total} courses',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (progress.failed.isNotEmpty) ...[
              const Text('Failed courses:'),
              const SizedBox(height: 8),
              ...progress.failed.map(
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
            onPressed: () {
              Navigator.pop(context);
              if (!widget.isEdit) {
                Navigation.navigateToScreenAndClearOnePrevious(
                  context: context,
                  screen: const NavigationHostPage(),
                );
              }
            },
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
      showBackButton: widget.isEdit,
      title: AppStrings.courseEnrollment,
      actions: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: InkWell(
            onTap: () {
              showAppBottomSheet(
                  context: context,
                  title: 'Course Enrollment Notice',
                  showCloseButton: false,
                  child: const CourseRegistrationInfoBottomSheet());
            },
            child: const Icon(Icons.info_outline,
                color: AppColors.defaultColor, size: 20),
          ),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: refreshAllCourses,
        child: Column(
          children: [
            SearchAndFilterBar(
              searchController: searchController,
              onClearSearch: clearSearch,
              onChanged: onSearchChanged,
              onSearchSubmitted: (value) {
                if (value.trim().isEmpty) return;
                searchViewModel.searchCourses(value.trim());
                FocusScope.of(context).unfocus();
              },
              onFilterTap: () {
                showAppBottomSheet(
                  context: context,
                  title: 'Filter Courses',
                  child: FilterCoursesBottomSheet(
                    initialLevel: searchViewModel.selectedLevel,
                    initialSemester: searchViewModel.selectedSemester,
                    initialSchool: searchViewModel.selectedSchool,
                    onApply: (level, semester, school) {
                      searchViewModel.applyFilter(level, semester, school);
                      Navigation.back(context: context);
                    },
                    onReset: () {
                      searchViewModel.clearFilter();
                      Navigation.back(context: context);
                    },
                  ),
                );
              },
            ),
            Consumer<CourseSearchViewModel>(
              builder: (context, searchViewModel, _) {
                return Expanded(
                  child: Column(
                    children: [
                      CourseListContent(
                        viewModel: searchViewModel,
                        courseViewModel: courseViewModel,
                      ),
                      ConfirmationSection(
                        totalCreditHours: searchViewModel.totalCreditHours,
                        onConfirmPressed: onConfirmPressed,
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
