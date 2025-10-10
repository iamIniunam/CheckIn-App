import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class PageLoadingIndicator extends StatelessWidget {
  const PageLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class PageErrorIndicator extends StatelessWidget {
  const PageErrorIndicator({super.key, this.text, this.useTopPadding = false});

  final String? text;
  final bool useTopPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: useTopPadding ? MediaQuery.sizeOf(context).height * 0.18 : 0,
      ),
      child: Column(
        mainAxisAlignment:
            useTopPadding ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.defaultColor,
            size: 30,
          ),
          const SizedBox(height: 6),
          Text(
            text ?? 'Failed to load data',
            style: const TextStyle(
              color: AppColors.defaultColor,
            ),
          ),
        ],
      ),
    );
  }
}
