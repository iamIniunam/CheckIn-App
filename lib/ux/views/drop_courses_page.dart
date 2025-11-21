import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/course/components/course_search_bottom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DropCoursesPage extends StatefulWidget {
  const DropCoursesPage({super.key});

  @override
  State<DropCoursesPage> createState() => _DropCoursesPageState();
}

class _DropCoursesPageState extends State<DropCoursesPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Drop Courses',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchTextFormField(
              controller: searchController,
              onClear: () {},
              hintText: AppStrings.searchByCourseCodeOrTitle,
              onSubmitted: (v) {},
              onChanged: (v) {},
            ),
          ),
          Consumer<CourseViewModel>(
            builder: (context, viewModel, _) {
              return Expanded(
                child: Column(
                  children: [
                    // RegisteredCourseListContent(viewModel: viewModel),
                    ConfirmationSection(
                      totalCreditHours: 12,
                      onConfirmPressed: () {},
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
