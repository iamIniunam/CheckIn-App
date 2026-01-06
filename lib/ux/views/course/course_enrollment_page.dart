import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/course/models/course_request.dart';
import 'package:attendance_app/platform/di/dependency_injection.dart';
import 'package:attendance_app/platform/utils/general_utils.dart';
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
import 'package:flutter/foundation.dart';
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
  final CourseSearchViewModel _courseSearchViewModel =
      AppDI.getIt<CourseSearchViewModel>();
  final CourseViewModel _courseViewModel = AppDI.getIt<CourseViewModel>();

  late TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _courseSearchViewModel.coursesPagingController
        .addPageRequestListener((pageKey) {
      _courseSearchViewModel.currentPageForCourses = pageKey;
      if (searchController.text.isEmpty || pageKey != 1) {
        loadNextPageForCourses();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearSearch();
      _courseSearchViewModel.clearFilter();
      _courseSearchViewModel.clearSelectedCourses();
    });
  }

  Future<void> refreshCourses() async {
    _courseSearchViewModel.currentPageForCourses = 1;
    var response = await _courseSearchViewModel.getPagedCourses(
        getAllCoursesRequest: getAllCoursesRequest());
    if (response.status == ApiResponseStatus.Success) {
      final data = response.response?.data ?? [];
      final isLastPage = response.response?.isLastPage() ?? true;

      if (searchController.text.isEmpty &&
          !_courseSearchViewModel.hasActiveFilter &&
          data.isNotEmpty) {
        _courseSearchViewModel.firstPageAllCourses = data;
      }
      _courseSearchViewModel.coursesPagingController.itemList
          ?.clear(); //TODO: ask Chisom why he did this
      _courseSearchViewModel.coursesPagingController.itemList = [];
      if (isLastPage) {
        _courseSearchViewModel.coursesPagingController.appendLastPage(data);
      } else {
        _courseSearchViewModel.coursesPagingController.appendPage(
          data,
          _courseSearchViewModel.currentPageForCourses + 1,
        );
      }
    }
  }

  Future<void> loadNextPageForCourses() async {
    var response = await _courseSearchViewModel.getPagedCourses(
        getAllCoursesRequest: getAllCoursesRequest());
    if (response.status == ApiResponseStatus.Success) {
      final data = response.response?.data ?? [];
      final isLastPage = response.response?.isLastPage() ?? true;

      try {
        if (_courseSearchViewModel.currentPageForCourses == 1) {
          _courseSearchViewModel.coursesPagingController.itemList?.clear();
          _courseSearchViewModel.coursesPagingController.itemList = [];

          if (_courseSearchViewModel.firstPageAllCourses.isEmpty &&
              searchController.text.isEmpty &&
              !_courseSearchViewModel.hasActiveFilter) {
            _courseSearchViewModel.firstPageAllCourses = data;
          }
        }
        if (isLastPage || data.isEmpty) {
          _courseSearchViewModel.coursesPagingController.appendLastPage(data);
        } else {
          _courseSearchViewModel.coursesPagingController.appendPage(
            data,
            _courseSearchViewModel.currentPageForCourses + 1,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      _courseSearchViewModel.coursesPagingController.error =
          response.response?.message ?? AppStrings.somethingWentWrong;
    }
  }

  GetAllCoursesRequest getAllCoursesRequest() {
    return GetAllCoursesRequest(
      pageIndex: _courseSearchViewModel.currentPageForCourses,
      pageSize: AppConstants.defaultPageSize,
      searchQuery: searchController.text.trim(),
      level: _courseSearchViewModel.selectedLevel,
      semester: _courseSearchViewModel.selectedSemester,
      school: _courseSearchViewModel.selectedSchool,
    );
  }

  bool isSearching = false;

  Future<void> searchCourses() async {
    if (isSearching) return;
    isSearching = true;
    await refreshCourses();
    setState(() {});
    isSearching = false;
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      clearSearch();
      return;
    }
    if (trimmedValue.length < AppConstants.defaultMinCharactersToSearch) {
      return;
    }
    _searchDebounce = Timer(
      const Duration(
          milliseconds: AppConstants.defaultSearchDebounceTimeInMilliSeconds),
      () async {
        if (!mounted) return;
        searchCourses();
      },
    );
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    searchController.clear();
    resetCourses();
    if (mounted) setState(() {});
  }

  void resetCourses() {
    _courseSearchViewModel.currentPageForCourses = 1;
    _courseSearchViewModel.coursesPagingController.refresh();
    setState(() {});
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
    if (_courseSearchViewModel.selectedCourses.isEmpty) {
      AppDialogs.showErrorDialog(
        context: context,
        message: 'Please select at least one course',
      );
      return false;
    }

    if (_courseSearchViewModel.totalCreditHours >
        AppConstants.requiredCreditHours) {
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
    return await _courseViewModel.registerCourses(
      studentId: studentId,
      courses: _courseSearchViewModel.selectedCourses.toList(),
      isAdding: widget.isEdit,
    );
  }

  void handleRegistrationResult(UIResult<RegisterCoursesProgress> result) {
    if (result.isSuccess) {
      final progress = result.data;
      if (progress != null && progress.hasFailures) {
        showPartialSuccessDialog(progress);
      } else {
        widget.isEdit
            ? showSuccessDialog()
            : Navigation.navigateToHomePage(context: context);
      }
    } else if (result.isError) {
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
        onRefresh: () async {
          _courseSearchViewModel.currentPageForCourses = 1;
          _courseSearchViewModel.coursesPagingController.refresh();
        },
        // onRefresh: refreshCourses,
        child: Column(
          children: [
            SearchAndFilterBar(
              onClearSearch: clearSearch,
              searchController: searchController,
              onChanged: onSearchChanged,
              onSearchSubmitted: (value) {
                _searchDebounce?.cancel();
                if (value.trim().isNotEmpty) {
                  searchCourses();
                }
                Utils.hideKeyboard();
              },
              onFilterTap: () {
                showAppBottomSheet(
                  context: context,
                  title: 'Filter Courses',
                  child: FilterCoursesBottomSheet(
                    initialLevel: _courseSearchViewModel.selectedLevel,
                    initialSemester: _courseSearchViewModel.selectedSemester,
                    initialSchool: _courseSearchViewModel.selectedSchool,
                    onApply: (level, semester, school) {
                      _courseSearchViewModel.applyFilter(
                          level, semester, school);
                      _courseSearchViewModel.currentPageForCourses = 1;
                      _courseSearchViewModel.coursesPagingController.refresh();
                      Navigation.back(context: context);
                    },
                    onReset: () {
                      _courseSearchViewModel.clearFilter();
                      Navigation.back(context: context);
                      _courseSearchViewModel.currentPageForCourses = 1;
                      _courseSearchViewModel.coursesPagingController.refresh();
                    },
                  ),
                );
              },
            ),
            Consumer<CourseSearchViewModel>(
              builder: (context, courseSearchViewModel, _) {
                return Expanded(
                  child: Column(
                    children: [
                      CourseListContent(
                        viewModel: courseSearchViewModel,
                        courseViewModel: _courseViewModel,
                      ),
                      ConfirmationSection(
                        totalCreditHours:
                            courseSearchViewModel.totalCreditHours,
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
