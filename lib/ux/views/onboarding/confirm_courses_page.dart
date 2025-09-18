import 'package:attendance_app/platform/providers/course_provider.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/navigation/navigation_host_page.dart';
import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/components/back_and_next_button_row.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models.dart/user_view_model.dart';
import 'package:attendance_app/ux/views/onboarding/add_course_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfirmCoursesPage extends StatefulWidget {
  const ConfirmCoursesPage({super.key});

  @override
  State<ConfirmCoursesPage> createState() => _ConfirmCoursesPageState();
}

class _ConfirmCoursesPageState extends State<ConfirmCoursesPage> {
  bool isConfirming = false;
  late UserViewModel viewModel;

  List<Course> courses = [
    Course(
        courseCode: 'CS306',
        creditHours: 1,
        courseTitle: 'Computer Architecture Lab'),
    Course(
        courseCode: 'CS311', creditHours: 3, courseTitle: 'Datebase system 1'),
    Course(
        courseCode: 'CE301/CE302',
        creditHours: 3,
        courseTitle: 'Electronic Device & Circuits Electronics Lab'),
    Course(
        courseCode: 'CE303',
        creditHours: 1,
        courseTitle: 'Embedded Microprocessor Systems'),
    Course(
        courseCode: 'EEE303',
        creditHours: 1,
        courseTitle: 'Communication Systems 1'),
    Course(
        courseCode: 'CE304',
        creditHours: 3,
        courseTitle: 'Systems and Signals'),
    Course(
        courseCode: 'CS208',
        creditHours: 3,
        courseTitle: 'Data Communications & Computer Networks 1'),
    Course(
        courseCode: 'ENG307',
        creditHours: 1,
        courseTitle: 'Eng Lab 4 - Microcomputer Tech Lab'),
    Course(
        courseCode: 'ENG306',
        creditHours: 2,
        courseTitle: 'Research Methodology'),
    Course(
        courseCode: 'FAB301',
        creditHours: 0,
        courseTitle: 'Digital Fabrication for Product Development'),
  ];

  List<Course> selectedCourses = [];

  @override
  void initState() {
    super.initState();
    selectedCourses = List.from(courses);
    viewModel = context.read<UserViewModel>();
  }

  bool get allSelected => selectedCourses.length == courses.length;

  void toggleSelectAll() {
    setState(() {
      if (allSelected) {
        selectedCourses.clear();
      } else {
        selectedCourses = List.from(courses);
      }
    });
  }

  int get totalCreditHours =>
      selectedCourses.fold(0, (sum, course) => sum + (course.creditHours ?? 0));

  void confirmCourses() async {
    setState(() {
      isConfirming = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      isConfirming = false;
    });

    context.read<CourseProvider>().setCourses(selectedCourses);
    Navigation.navigateToScreenAndClearOnePrevious(
        context: context, screen: const NavigationHostPage());
  }

  @override
  Widget build(BuildContext context) {
    final semester = viewModel.semester;

    String semesterText;
    if (semester == '1') {
      semesterText = '1st';
    } else if (semester == '2') {
      semesterText = '2nd';
    } else {
      semesterText = 'Unknown';
    }

    return AppPageScaffold(
      hideAppBar: false,
      showBackButton: false,
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
                  '${viewModel.level} Level, $semesterText Semester',
                  style: const TextStyle(
                      color: AppColors.defaultColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                AppMaterial(
                  inkwellBorderRadius: BorderRadius.circular(8),
                  onTap: toggleSelectAll,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        const Text(
                          AppStrings.selectAll,
                          style: TextStyle(
                            color: AppColors.defaultColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          allSelected
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: allSelected
                              ? AppColors.defaultColor
                              : AppColors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: courses
                  .map(
                    (semesterCourses) => courseCard(
                      semesterCourse: semesterCourses,
                      selected: selectedCourses.contains(semesterCourses),
                      onTap: () {
                        setState(() {
                          if (selectedCourses.contains(semesterCourses)) {
                            selectedCourses.remove(semesterCourses);
                          } else {
                            selectedCourses.add(semesterCourses);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        text: 'Total credit hours: ',
                        style: const TextStyle(
                            color: AppColors.defaultColor,
                            fontFamily: 'Nunito'),
                        children: <TextSpan>[
                          TextSpan(
                            text: totalCreditHours.toString(),
                            style: const TextStyle(
                                color: AppColors.defaultColor,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                BackAndNextButtonRow(
                  enableBackButton: totalCreditHours != 18,
                  enableNextButton: totalCreditHours == 18,
                  firstText: AppStrings.addCourse,
                  secondText: AppStrings.confirm,
                  onTapFirstButton: () {
                    Navigation.navigateToScreen(
                        context: context, screen: const AddCoursePage());
                  },
                  onTapNextButton: isConfirming ? () {} : confirmCourses,
                  nextWidget: isConfirming
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: AppColors.white),
                        )
                      : null,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget courseCard(
      {required Course semesterCourse,
      required bool selected,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppMaterial(
        color: selected ? AppColors.primaryTeal : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        inkwellBorderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.defaultColor : AppColors.grey,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${semesterCourse.courseCode} (${(semesterCourse.creditHours).toString()})',
                      style: const TextStyle(
                          color: AppColors.defaultColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      semesterCourse.courseTitle ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.defaultColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? AppColors.defaultColor : AppColors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
