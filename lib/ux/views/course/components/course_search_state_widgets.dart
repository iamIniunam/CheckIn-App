import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/course_search_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/views/course/components/course_list_view.dart';
import 'package:flutter/material.dart';

class CourseListContent extends StatelessWidget {
  const CourseListContent(
      {super.key, required this.viewModel, required this.courseViewModel});

  final CourseSearchViewModel viewModel;
  final CourseViewModel courseViewModel;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (viewModel.isSearching || viewModel.hasActiveFilter)
                // CoursesFoundHeader(
                //     courseCount: viewModel.firstPageAllCourses.length),
                const SizedBox(width: 8),
              ValueListenableBuilder(
                valueListenable: courseViewModel.registeredCoursesResult,
                builder: (context, result, _) {
                  if (!result.isSuccess) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
                    child: Text(
                      'Total credits registered: ${courseViewModel.totalRegisteredCredits}',
                      style: const TextStyle(color: AppColors.defaultColor),
                    ),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: CourseListView(viewModel: viewModel),
          ),
        ],
      ),
    );
  }
}

class CoursesFoundHeader extends StatelessWidget {
  const CoursesFoundHeader({super.key, required this.courseCount});

  final int courseCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
      child: Row(
        children: [
          Text(
            '$courseCount course${courseCount == 1 ? '' : 's'} found',
            style: const TextStyle(
              color: AppColors.defaultColor,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
