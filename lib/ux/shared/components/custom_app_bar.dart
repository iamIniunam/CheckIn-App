import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/views/home/notifications_page.dart';
import 'package:attendance_app/ux/views/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.defaultColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AppBarActionWidget(
              icon: Icons.notifications,
              onTap: () {
                Navigation.navigateToScreen(
                    context: context, screen: const NotificationsPage());
              }),
          const SizedBox(width: 10),
          AppBarActionWidget(
              icon: Iconsax.setting_45,
              onTap: () {
                Navigation.navigateToScreen(
                    context: context, screen: const SettingsPage());
              }),
        ],
      ),
    );
  }
}

class AppBarActionWidget extends StatelessWidget {
  const AppBarActionWidget({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppMaterial(
      color: AppColors.primaryTeal,
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      inkwellBorderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          color: AppColors.defaultColor,
        ),
      ),
    );
  }
}
