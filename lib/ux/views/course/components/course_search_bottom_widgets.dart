import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/views/attendance/components/padded_column.dart';
import 'package:flutter/material.dart';

class ConfirmationSection extends StatelessWidget {
  const ConfirmationSection({
    super.key,
    required this.totalCreditHours,
    required this.onConfirmPressed,
    this.isSelected = false,
  });

  final int totalCreditHours;
  final VoidCallback onConfirmPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return PaddedColumn(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
      children: [
        CreditHoursDisplay(
            isSelected: isSelected, totalCreditHours: totalCreditHours),
        const SizedBox(height: 10),
        PrimaryButton(
          onTap: onConfirmPressed,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

class CreditHoursDisplay extends StatelessWidget {
  const CreditHoursDisplay(
      {super.key, this.isSelected = false, required this.totalCreditHours});

  final bool isSelected;
  final int totalCreditHours;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: isSelected ? 'Remaining credits: ' : 'Total credit hours: ',
          style: const TextStyle(
            color: AppColors.defaultColor,
            fontFamily: 'Nunito',
          ),
          children: [
            TextSpan(
              text: '$totalCreditHours/${AppConstants.requiredCreditHours}',
              style: const TextStyle(
                color: AppColors.defaultColor,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
