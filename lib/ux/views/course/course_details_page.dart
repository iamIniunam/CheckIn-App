import 'package:attendance_app/platform/extensions/date_time_extensions.dart';
import 'package:attendance_app/platform/services/selected_courses_service.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/course/components/course_detail_item.dart';
import 'package:attendance_app/ux/views/course/components/session_history.dart';
import 'package:flutter/material.dart';

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage(
      {super.key, required this.courseCode, required this.courseTitle});

  final String courseCode;
  final String courseTitle;

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  List<Session> sessions = [
    Session(
        weekNumber: 1,
        date: DateTime.now().friendlySlashDate(),
        status: AppStrings.absent),
    Session(
        weekNumber: 2,
        date: DateTime.now().friendlySlashDate(),
        status: AppStrings.present),
    Session(
        weekNumber: 3,
        date: DateTime.now().friendlySlashDate(),
        status: AppStrings.present),
    Session(
        weekNumber: 4,
        date: DateTime.now().friendlySlashDate(),
        status: AppStrings.late),
    Session(
        weekNumber: 5,
        date: DateTime.now().friendlySlashDate(),
        status: AppStrings.present),
    Session(
        weekNumber: 6,
        date: DateTime.now().friendlySlashDate(),
        status: AppStrings.present),
    Session(
        weekNumber: 7,
        date: DateTime.now().friendlySlashDate(),
        status: AppStrings.present),
  ];

  String? get courseStream =>
      SelectedCoursesService().getStreamForCourse(widget.courseCode);

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      hasRefreshIndicator: true,
      title: AppStrings.courseDetails,
      showInformationBanner: true,
      informationBannerText: AppStrings.sampleEligibilityText,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.courseCode,
                                style: const TextStyle(
                                    color: AppColors.defaultColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.courseTitle,
                                style: const TextStyle(
                                    color: Colors.grey,
                                    // fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryTeal.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              courseStream ?? '',
                              style: const TextStyle(
                                color: AppColors.defaultColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding:
                            const EdgeInsets.only(left: 16, top: 12, right: 16),
                        decoration: BoxDecoration(
                          color: AppColors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.defaultColor),
                        ),
                        child: const Column(
                          children: [
                            CourseDetailItem(
                                title: AppStrings.attendanceThreshold,
                                value: '18/20'),
                            CourseDetailItem(
                                title: AppStrings.midSemester, value: '6/10'),
                            CourseDetailItem(
                                title: AppStrings.endOfSemester, value: '6/20'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        AppStrings.history,
                        style: TextStyle(
                          color: AppColors.defaultColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...sessions
                          .map((sessionData) =>
                              SessionHistory(session: sessionData))
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
