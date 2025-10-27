import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileDetailItem extends StatelessWidget {
  const ProfileDetailItem({
    super.key,
    required this.title,
    required this.value,
    this.textDirection,
  });

  final String title;
  final String value;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return Ink(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
      ),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
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
                textDirection: textDirection ?? TextDirection.ltr,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.defaultColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
