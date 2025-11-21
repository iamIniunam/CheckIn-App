import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/view_models/attendance_verification_view_model.dart';
import 'package:attendance_app/ux/shared/models/ui_models.dart';
import 'package:attendance_app/ux/views/attendance/components/error_message.dart';
import 'package:flutter/material.dart';

class LocationCheckContent extends StatelessWidget {
  const LocationCheckContent({super.key, required this.viewModel});

  final AttendanceVerificationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_searching_rounded,
              size: 80,
              color: AppColors.defaultColor,
            ),
            const SizedBox(height: 24),
            Text(
              viewModel.locationStatusHeaderMessage(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.defaultColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.locationStatusMessage(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            // Real-time location updates using ValueListenableBuilder
            ValueListenableBuilder<UIResult<AttendanceResult>>(
              valueListenable: viewModel.locationCheckResult,
              builder: (context, result, child) {
                // Show loading spinner
                if (result.isLoading || viewModel.isLocationChecking) {
                  return const Column(
                    children: [
                      SizedBox(height: 24),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.defaultColor),
                      ),
                    ],
                  );
                }

                // Show distance if available
                if (result.isSuccess && result.data != null) {
                  final data =
                      result.data ?? AttendanceResult(canAttend: false);
                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: data.canAttend
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: data.canAttend
                                ? Colors.green.shade300
                                : Colors.orange.shade300,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: data.canAttend
                                      ? Colors.green.shade600
                                      : Colors.orange.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Distance: ${data.formattedDistance}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: data.canAttend
                                        ? Colors.green.shade600
                                        : Colors.orange.shade600,
                                  ),
                                ),
                              ],
                            ),
                            if (data.accuracy != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Accuracy: ±${data.accuracy?.toStringAsFixed(0)}m',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            // Show error message if exists
            if (viewModel.verificationState.errorMessage != null)
              ErrorMessage(
                message: viewModel.verificationState.errorMessage ?? '',
              ),
          ],
        ),
      ),
    );
  }
}
