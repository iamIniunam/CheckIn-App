import 'dart:ui';

import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class BlurredLoadingOverlay extends StatelessWidget {
  final bool showLoader;

  const BlurredLoadingOverlay({super.key, required this.showLoader});

  @override
  Widget build(BuildContext context) {
    if (!showLoader) return const SizedBox.shrink();

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: ColoredBox(
          color: AppColors.black.withOpacity(0.2),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.white,
              strokeWidth: 3,
            ),
          ),
        ),
      ),
    );
  }
}
