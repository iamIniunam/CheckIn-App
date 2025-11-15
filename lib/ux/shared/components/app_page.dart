import 'package:attendance_app/ux/shared/components/information_banner.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/components/custom_app_bar.dart';
import 'package:flutter/material.dart';

typedef OnBackPressed = Function();

class AppPageScaffold extends StatelessWidget {
  final Widget body;
  final bool hideAppBar;
  final String? title;
  final String? headerTitle;
  final String? headerSubtitle;
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
  final bool showInformationBanner;
  final bool showDivider;
  final String? informationBannerText;

  const AppPageScaffold({
    super.key,
    required this.body,
    this.hideAppBar = false,
    this.title,
    this.headerTitle,
    this.headerSubtitle,
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
    this.showInformationBanner = false,
    this.showDivider = false,
    this.informationBannerText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: AbsorbPointer(
        absorbing: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: backgroundColor,
          appBar: hideAppBar
              ? null
              : AppBar(
                  backgroundColor: appBarColor,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    title ?? '',
                    style: TextStyle(
                        color: titleTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  automaticallyImplyLeading: false,
                  leading: showBackButton
                      ? Padding(
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
                        )
                      : null,
                  actions: actions,
                  bottom: appBarBottom,
                ),
          body: useSafeArea
              ? SafeArea(
                  child: Column(
                    children: [
                      if (hideAppBar &&
                          headerTitle != null &&
                          headerSubtitle != null)
                        CustomAppBar(
                          title: headerTitle ?? '',
                          subtitle: headerSubtitle ?? '',
                        ),
                      if (showInformationBanner == true)
                        InformationBanner(
                          text: informationBannerText ?? '',
                        ),
                      // else if (hideAppBar == false && showDivider == true)
                      //   const AppDivider(),
                      Expanded(
                        child: body,
                      ),
                    ],
                  ),
                )
              : body,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          bottomNavigationBar: bottomNavigationBar,
        ),
      ),
    );
  }
}
