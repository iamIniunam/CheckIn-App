import 'package:attendance_app/ux/navigation/navigation.dart';
import 'package:attendance_app/ux/shared/components/app_buttons.dart';
import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:flutter/material.dart';

class EditPhoneNumberBottomSheet extends StatefulWidget {
  const EditPhoneNumberBottomSheet({super.key});

  @override
  State<EditPhoneNumberBottomSheet> createState() =>
      _EditPhoneNumberBottomSheetState();
}

class _EditPhoneNumberBottomSheetState
    extends State<EditPhoneNumberBottomSheet> {
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // const Text(
          //   'Current Phone Number: ${AppStrings.samplePhoneNumber}',
          //   style: TextStyle(
          //     color: AppColors.defaultColor,
          //     fontSize: 20,
          //   ),
          // ),
          // const SizedBox(height: 16),
          PrimaryTextFormField(
            hintText: AppStrings.changePhoneNumberHint,
            controller: phoneNumberController,
            keyboardType: TextInputType.phone,
            onChanged: (value) {},
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            onTap: () {
              Navigation.back(
                  context: context, result: phoneNumberController.text);
            },
            child: const Text(AppStrings.saveChanges),
          ),
        ],
      ),
    );
  }
}
