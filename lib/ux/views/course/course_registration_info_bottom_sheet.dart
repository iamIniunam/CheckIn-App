import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/views/attendance/components/padded_column.dart';
import 'package:flutter/material.dart';

class CourseRegistrationInfoBottomSheet extends StatelessWidget {
  const CourseRegistrationInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return PaddedColumn(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: const TextSpan(
              text: 'Please note that this process is ',
              style: TextStyle(
                color: AppColors.defaultColor,
                fontFamily: 'Nunito',
                height: 2,
              ),
              children: <TextSpan>[
                TextSpan(
                  text:
                      'only for confirming your registered courses for the semester',
                  style: TextStyle(
                    color: AppColors.defaultColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text:
                      ', not for official course registration. \nEnsure that the courses you select match your academic registration records before proceeding.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
