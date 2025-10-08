import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/confirm_course_card.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
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
    // viewModel is read in didChangeDependencies to avoid calling
    // context.read in initState synchronously.
    // Defer loading until after the first frame so ChangeNotifier
    // does not call notifyListeners during the widget build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.loadAllCourses();
    });

    // Update the UI when the search text changes.
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Debounce user input to avoid rebuilding on every keystroke.
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      hideAppBar: false,
      title: AppStrings.addCourseCaps,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchTextFormField(
              controller: searchController,
              onClear: () {
                searchController.clear();
                FocusScope.of(context).unfocus();
              },
              hintText: AppStrings.searchCourses,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<CourseViewModel>(
            builder: (context, courseViewModel, _) {
              // Filter courses based on search text (case-insensitive)
              final query = searchController.text.trim().toLowerCase();
              final all = courseViewModel.allCourses;
              final courses = query.isEmpty
                  ? all
                  : all.where((c) {
                      final title = (c.courseTitle ?? '').toLowerCase();
                      final code = (c.courseCode).toLowerCase();
                      return title.contains(query) || code.contains(query);
                    }).toList();

              return Expanded(
                child: courses.isEmpty
                    ? Center(
                        child: courseViewModel.isLoadingCourses
                            ? const CircularProgressIndicator()
                            : const Text('No courses match your search'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          final selectedSchool =
                              courseViewModel.getCourseSchool(course);

                          return ConfirmCourseCard(
                            semesterCourse: course,
                            selectedSchool: selectedSchool,
                            onTapSchool: (school) {
                              courseViewModel.updateCourseSchool(
                                  course, school);
                            },
                          );
                        },
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
