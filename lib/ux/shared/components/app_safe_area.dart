import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class AppSafeArea extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool hasBottomPadding;

  const AppSafeArea(
      {super.key,
      required this.child,
      this.backgroundColor,
      this.hasBottomPadding = true});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? AppColors.white,
      child: Padding(
        padding: EdgeInsets.only(bottom: hasBottomPadding ? 16 : 0),
        child: SafeArea(
          child: child,
        ),
      ),
    );
  }
}
