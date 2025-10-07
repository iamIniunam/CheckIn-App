import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/components/back_and_next_button_row.dart';
import 'package:attendance_app/ux/shared/components/global_functions.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/resources/app_dialogs.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/user_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/add_course_page.dart';
import 'package:attendance_app/ux/views/onboarding/confirm_course_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfirmCoursesPage extends StatefulWidget {
  const ConfirmCoursesPage({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  State<ConfirmCoursesPage> createState() => _ConfirmCoursesPageState();
}

class _ConfirmCoursesPageState extends State<ConfirmCoursesPage> {
  late UserViewModel userViewModel;

  @override
  void initState() {
    super.initState();
    userViewModel = context.read<UserViewModel>();
  }

  // String get semesterText {
  //   final semester = userViewModel.semester;
  //   switch (semester) {
  //     case '1':
  //       return '1st';
  //     case '2':
  //       return '2nd';
  //     default:
  //       return 'Unknown';
  //   }
  // }

  Future<void> onConfirmPressed(CourseViewModel viewModel) async {
    final success = await viewModel.confirmCourses();

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
    } else if (viewModel.errorMessage != null) {
      //TODO: complete this flow
      showAlert(
          context: context, title: 'title', desc: viewModel.errorMessage ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseViewModel>(
      builder: (context, viewModel, _) {
        return AppPageScaffold(
          hideAppBar: false,
          showBackButton: widget.isEdit,
          title: AppStrings.confirmSemeterCourses,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 8, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // '${userViewModel.level} Level, $semesterText Semester',
                      '',
                      style: const TextStyle(
                        color: AppColors.defaultColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: viewModel.availableCourses.length,
                  itemBuilder: (context, index) {
                    final course = viewModel.availableCourses[index];
                    final selectedStream = viewModel.getCourseStream(course);

                    return ConfirmCourseCard(
                      semesterCourse: course,
                      selectedStream: selectedStream,
                      onTapStream: (stream) {
                        viewModel.updateCourseStream(course, stream);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, top: 8, right: 16),
                      child: Align(
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
                                    '${viewModel.totalCreditHours}/${AppConstants.requiredCreditHours}',
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
                    ),
                    BackAndNextButtonRow(
                      enableBackButton: viewModel.canAddCourse,
                      enableNextButton: viewModel.canConfirm,
                      firstText: AppStrings.addCourse,
                      secondText: AppStrings.confirm,
                      onTapFirstButton: () {
                        Navigation.navigateToScreen(
                            context: context, screen: const AddCoursePage());
                      },
                      onTapNextButton: () {
                        onConfirmPressed(viewModel);
                      },
                      nextWidget: viewModel.isConfirming
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.white,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
