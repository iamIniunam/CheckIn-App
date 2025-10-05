import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/views/attendance/components/padded_column.dart';
import 'package:flutter/material.dart';

class ConfirmCourseCard extends StatelessWidget {
  const ConfirmCourseCard(
      {super.key,
      required this.semesterCourse,
      required this.selectedStream,
      required this.onTapStream});

  final Course semesterCourse;
  final String? selectedStream;
  final ValueChanged<String> onTapStream;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: (selectedStream != null)
              ? AppColors.primaryTeal
              : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: (selectedStream != null)
                ? AppColors.defaultColor
                : AppColors.grey,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaddedColumn(
              padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
              children: [
                Text(
                  '${semesterCourse.courseCode} (${(semesterCourse.creditHours).toString()})',
                  style: const TextStyle(
                    color: AppColors.defaultColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  semesterCourse.courseTitle ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.defaultColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppConstants.streams
                    .map(
                      (stream) => SingleStream(
                        stream: stream,
                        selected: selectedStream == stream,
                        onTap: onTapStream,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SingleStream extends StatelessWidget {
  const SingleStream(
      {super.key,
      required this.stream,
      required this.selected,
      required this.onTap});

  final String stream;
  final bool selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return AppMaterial(
      inkwellBorderRadius: BorderRadius.circular(10),
      onTap: () {
        onTap(stream);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? AppColors.defaultColor : AppColors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              stream,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.defaultColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
