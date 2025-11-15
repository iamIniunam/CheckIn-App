import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class InformationBanner extends StatelessWidget {
  const InformationBanner({
    super.key,
    this.icon,
    required this.text,
    this.onTap,
    this.visible = true,
  });

  final VoidCallback? onTap;
  final Widget? icon;
  final String text;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: onTap,
            child: ColoredBox(
              color: AppColors.primaryTeal,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon ??
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.defaultColor,
                          size: 16,
                        ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        text,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.defaultColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
