import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/bottom_sheets/show_app_bottom_sheet.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/components/empty_state_widget.dart';
import 'package:attendance_app/ux/shared/components/page_loading_indicator.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/components/course_enrollment_card.dart';
import 'package:attendance_app/ux/views/onboarding/course_registration_info_bottom_sheet.dart';
import 'package:attendance_app/ux/views/onboarding/filter_courses_bottom_page.dart';
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
  TextEditingController searchController = TextEditingController();
  late CourseViewModel viewModel;
  Timer? _searchDebounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewModel = context.read<CourseViewModel>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.loadAllCourses();
    });
  }

  void onSearchChanged(String value) {
    final query = value.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      viewModel.searchCourses(query);
    });
  }

  void clearSearch() {
    searchController.clear();
    viewModel.clearSearch();
  }

  Future<void> onConfirmPressed(CourseViewModel viewModel) async {
    AppDialogs.showLoadingDialog(context);
    bool success = false;
    try {
      success = await viewModel.confirmCourses();
    } finally {
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
      }
    }

    if (!mounted) return;

    if (success) {
      widget.isEdit
          ? AppDialogs.showSuccessDialog(
              context: context,
              message: 'Courses updated successfully',
              action: () {
                Navigation.back(context: context);
              },
            )
          : Navigation.navigateToScreenAndClearOnePrevious(
              context: context,
              screen: const NavigationHostPage(),
            );
    } else if (!success && viewModel.errorMessage != null) {
      AppDialogs.showErrorDialog(
          context: context, message: viewModel.errorMessage ?? '');
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SearchTextFormField(
                    controller: searchController,
                    onClear: clearSearch,
                    hintText: AppStrings.searchCourses,
                    onSubmitted: (value) {
                      viewModel.searchCourses(value.trim());
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (value) => onSearchChanged(value),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<CourseViewModel>(
                  builder: (context, courseViewModel, _) {
                    return AppMaterial(
                      color: AppColors.field,
                      borderRadius: BorderRadius.circular(10),
                      inkwellBorderRadius: BorderRadius.circular(10),
                      onTap: () {
                        showAppBottomSheet(
                          context: context,
                          title: 'Filter Courses',
                          child: FilterCoursesBottomSheet(
                            initialLevel: courseViewModel.selectedLevel,
                            initialSemester: courseViewModel.selectedSemester,
                            onApply: (level, semester) {
                              courseViewModel.applyFilter(level, semester);
                              Navigation.back(context: context);
                            },
                            onReset: () {
                              courseViewModel.clearFilter();
                              Navigation.back(context: context);
                            },
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(9),
                        child: courseViewModel.hasActiveFilter
                            ? Badge(child: AppImages.svgFilterIcon)
                            : AppImages.svgFilterIcon,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Consumer<CourseViewModel>(
            builder: (context, courseViewModel, _) {
              if (courseViewModel.isLoadingCourses) {
                return const PageLoadingIndicator();
              }

              final courses = courseViewModel.displayedCourses;

              if (courses.isEmpty) {
                EmptyStateWidget(
                  icon: courseViewModel.isSearching
                      ? Icons.search_off_rounded
                      : Icons.school_rounded,
                  message: courseViewModel.isSearching
                      ? 'No courses found'
                      : 'No courses available',
                );
              }

              return Expanded(
                child: Column(
                  children: [
                    if (courseViewModel.isSearching ||
                        courseViewModel.hasActiveFilter)
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 16, top: 8, right: 16),
                        child: Row(
                          children: [
                            Text(
                              '${courses.length} course${courses.length == 1 ? '' : 's'} found',
                              style: const TextStyle(
                                color: AppColors.defaultColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          final selectedSchool =
                              courseViewModel.getCourseSchool(course);

                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: CourseEnrollmentCard(
                              semesterCourse: course,
                              selectedSchool: selectedSchool,
                              onTapSchool: (school) {
                                courseViewModel.updateCourseSchool(
                                    course, school);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, top: 8, right: 16, bottom: 16),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                text: 'Total credit hours: ',
                                style: const TextStyle(
                                  color: AppColors.defaultColor,
                                  fontFamily: 'Nunito',
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        '${courseViewModel.totalCreditHours}/${AppConstants.requiredCreditHours}',
                                    style: const TextStyle(
                                      color: AppColors.defaultColor,
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          PrimaryButton(
                            enabled: courseViewModel.canConfirm,
                            onTap: () {
                              onConfirmPressed(courseViewModel);
                            },
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
