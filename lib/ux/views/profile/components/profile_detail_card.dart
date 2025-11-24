import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileDetailCard extends StatelessWidget {
  const ProfileDetailCard({
    super.key,
    required this.title,
    required this.value,
    this.showDivider = true,
  });

  final String title;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 12),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 50),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    maxLines: 2,
                    textDirection: TextDirection.rtl,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.defaultColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(),
      ],
    );
  }
}
