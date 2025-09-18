import 'package:attendance_app/platform/extensions/date_time_extensions.dart';
import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/views/home/components/notifications_page_empty_state.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> notifications = [
    {
      'icon': Icons.check_circle_rounded,
      'title': 'Attendance Marked Successfully',
      'body': 'You’ve been marked present for CS103.',
    },
    {
      'icon': Icons.warning_amber_rounded,
      'title': 'Low Attendance Warning',
      'body': 'Your ENG204 attendance is below 75%.',
    },
    {
      'icon': Icons.event_busy_rounded,
      'title': 'Missed Class',
      'body': 'You missed today’s PHY101 session.',
    },
    {
      'icon': Icons.face_rounded,
      'title': 'Face Verification Passed',
      'body': 'Your face scan was successful for 9AM class.',
    },
    {
      'icon': Icons.qr_code_2_rounded,
      'title': 'QR Code Expired',
      'body': 'Today’s QR code for CS102 has expired.',
    },
    {
      'icon': Icons.cancel_rounded,
      'title': 'Class Cancelled',
      'body': 'MATH201 was cancelled today. No attendance needed.',
    },
  ];

  final time = DateTime.now().subtract(const Duration(hours: 1));

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: AppStrings.notifications,
      hasRefreshIndicator: true,
      body: notifications.isEmpty
          ? const NotificationsPageEmptyState()
          : ListView(
              children: [
                ...notifications
                    .map(
                      (notif) => singleNotification(
                        icon: notif['icon'],
                        title: notif['title'],
                        body: notif['body'],
                      ),
                    )
                    .toList(),
              ],
            ),
    );
  }

  Widget singleNotification(
      {required IconData icon, required String title, required String body}) {
    return AppMaterial(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12.5),
              decoration: BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(
                icon,
                color: AppColors.defaultColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        color: AppColors.defaultColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    body,
                    style: const TextStyle(
                      color: AppColors.defaultColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time.smartTimeAgo(),
                    style: const TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
