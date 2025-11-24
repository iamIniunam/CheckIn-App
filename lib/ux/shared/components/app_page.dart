import 'dart:io';

import 'package:attendance_app/platform/utils/general_utils.dart';
import 'package:attendance_app/ux/shared/components/app_safe_area.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

typedef OnBackPressed = Function();

class AppPage extends StatelessWidget {
  final Widget body;
  final bool hideAppBar;
  final String? title;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color appBarColor;
  final Color titleTextColor;
  final Color leadingIconColor;
  final PreferredSizeWidget? appBarBottom;
  final FloatingActionButton? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final OnBackPressed? onBackPressed;
  final bool useSafeArea;
  final bool showBackButton;
  final Widget? appBarLeadingIcon;
  final bool canSwipeBackToPreviousScreen;
  final bool? enableHorizontalDragUpdate;
  final bool hasBottomPadding;

  const AppPage({
    super.key,
    required this.body,
    this.hideAppBar = false,
    this.title,
    this.actions,
    this.backgroundColor = AppColors.white,
    this.appBarColor = AppColors.white,
    this.titleTextColor = AppColors.defaultColor,
    this.leadingIconColor = AppColors.defaultColor,
    this.appBarBottom,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.onBackPressed,
    this.useSafeArea = true,
    this.showBackButton = true,
    this.appBarLeadingIcon,
    this.canSwipeBackToPreviousScreen = true,
    this.enableHorizontalDragUpdate = true,
    this.hasBottomPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    if (enableHorizontalDragUpdate == false) {
      return GestureDetector(
        onTap: () {
          Utils.hideKeyboard();
        },
        child: AbsorbPointer(
          absorbing: false,
          child: scaffold(context),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        Utils.hideKeyboard();
      },
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        int sensitivity = 28;
        if (details.delta.dx > sensitivity) {
          // Right Swipe
          if (Platform.isIOS &&
              Navigator.of(context).canPop() &&
              canSwipeBackToPreviousScreen) {
            Navigator.of(context).pop();
          }
        } else if (details.delta.dx < -sensitivity) {
          //Left Swipe
        }
      },
      child: scaffold(context),
    );
  }

  Scaffold scaffold(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      appBar: hideAppBar ? null : appBar(context),
      body: useSafeArea
          ? AppSafeArea(
              hasBottomPadding:
                  (hasBottomPadding && bottomNavigationBar == null),
              child: body,
            )
          : body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: appBarColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title ?? '',
        style: TextStyle(
            color: titleTextColor, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      automaticallyImplyLeading: false,
      shadowColor: const Color.fromRGBO(246, 246, 246, 1),
      leading: showBackButton ? backButton(context) : null,
      actions: actions,
      bottom: appBarBottom,
    );
  }

  Padding backButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkResponse(
        radius: 28,
        onTap: () {
          if (onBackPressed != null) {
            onBackPressed?.call();
          } else {
            Navigator.pop(context);
          }
        },
        child: appBarLeadingIcon ??
            Icon(Icons.arrow_back, color: leadingIconColor),
      ),
    );
  }
}
