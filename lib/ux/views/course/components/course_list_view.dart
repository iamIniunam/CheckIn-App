import 'package:attendance_app/platform/data_source/api/course/models/course_response.dart';
import 'package:attendance_app/ux/shared/components/empty_state_widget.dart';
import 'package:attendance_app/ux/shared/components/page_state_indicator.dart';
import 'package:attendance_app/ux/shared/components/pagination/custom_lazy_paging_grid.dart';
import 'package:attendance_app/ux/shared/view_models/course_search_view_model.dart';
import 'package:attendance_app/ux/views/course/components/course_enrollment_card.dart';
import 'package:flutter/material.dart';

class CourseListView extends StatelessWidget {
  const CourseListView({super.key, required this.viewModel});

  final CourseSearchViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomLazyPagingGrid<int, Course>(
      pagingController: viewModel.coursesPagingController,
      padding: const EdgeInsets.only(left: 16, top: 12, right: 16),
      primary: false,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 72,
      ),
      itemBuilder: (context, item, index) {
        return CourseEnrollmentCard(
          course: item,
          isSelected: viewModel.isCourseSelected(item),
          onTap: () {
            viewModel.toggleCourseSelection(item);
          },
        );
      },
      errorPageWidget: const PageErrorIndicator(),
      emptyPageWidget: EmptyStateWidget(
        icon: viewModel.isSearching
            ? Icons.search_off_rounded
            : Icons.school_rounded,
        message: viewModel.isSearching
            ? 'No courses found'
            : 'No courses found for the selected filters:\n${viewModel.filterSummary}',
      ),
      errorText: 'Failed to load courses',
    );
  }
}
