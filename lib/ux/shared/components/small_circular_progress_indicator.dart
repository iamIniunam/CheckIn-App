import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class SmallCircularProgressIndicator extends StatelessWidget {
  const SmallCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      child: CircleAvatar(
        radius: 8,
        backgroundColor: AppColors.transparent,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}
