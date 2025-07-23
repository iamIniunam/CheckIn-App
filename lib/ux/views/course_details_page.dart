import 'package:attendance_app/platform/extensions/date_time_extensions.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:flutter/material.dart';

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage(
      {super.key, required this.courseCode, required this.lecturer});

  final String courseCode;
  final String lecturer;

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
                      Text(
                        widget.courseCode,
                        style: const TextStyle(
                            color: AppColors.defaultColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.lecturer,
                        style: const TextStyle(
                            color: Colors.grey,
                            // fontSize: 16,
                            fontWeight: FontWeight.bold),
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
                        child: Column(
                          children: [
                            courseDetailItem(
                                title: AppStrings.attendanceThreshold,
                                value: '18/20'),
                            courseDetailItem(
                                title: AppStrings.midSemester, value: '6/10'),
                            courseDetailItem(
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
                              sessionHistory(session: sessionData))
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

  Widget courseDetailItem({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        color: AppColors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: const TextStyle(
                color: AppColors.defaultColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget sessionHistory({required Session session}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.session,
                style: const TextStyle(
                    color: AppColors.defaultColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                session.date,
                style: TextStyle(
                    color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: AppColors.primaryTeal,
                borderRadius: BorderRadius.circular(8)),
            child: Text(
              session.status,
              style: TextStyle(
                  color: session.getStatusColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
