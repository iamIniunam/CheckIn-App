import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';

class AppDropdownField extends StatelessWidget {
  final List<String>? items;
  final List<DropdownMenuItem<dynamic>>? dropdownItems;
  final bool stringItems;
  final void Function(dynamic)? onChanged;
  final String? Function(dynamic)? validator;
  final String? hintText;
  final String? labelText;
  final dynamic valueHolder;
  final Widget? prefixWidget;
  final Color? fillColor;
  final bool hasFill;
  final bool required;
  final Widget? itemsIcon;

  const AppDropdownField(
      {super.key,
      this.items,
      this.stringItems = true,
      this.dropdownItems,
      this.onChanged,
      this.hintText,
      this.prefixWidget,
      this.fillColor,
      this.hasFill = false,
      this.required = false,
      this.validator,
      this.valueHolder,
      this.labelText,
      this.itemsIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: labelText != null,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(
                    labelText ?? '',
                    style: const TextStyle(
                        color: AppColors.defaultColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  Visibility(
                    visible: required,
                    child: const Text(
                      '*',
                      style: TextStyle(
                          color: Color.fromRGBO(255, 54, 36, 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: DropdownButtonFormField<dynamic>(
              //menuMaxHeight: 100,
              isExpanded: true,
              validator: validator,
              value: valueHolder,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.defaultColor,
              ),
              style: const TextStyle(
                color: AppColors.defaultColor,
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                overflow:
                    TextOverflow.ellipsis, //TODO: check why this is not working
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color.fromRGBO(166, 164, 164, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.transparent),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 2.0),
                ),
              ),
              items: stringItems == true
                  ? (items ?? [])
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Row(
                              children: [
                                Visibility(
                                  visible: itemsIcon != null,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: itemsIcon,
                                  ),
                                ),
                                Text(
                                  item,
                                  style: const TextStyle(
                                      color: AppColors.defaultColor,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ))
                      .toList()
                  : (dropdownItems ?? []),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
