import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:searchfield/searchfield.dart';

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
                overflow: TextOverflow.ellipsis,
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

class CustomSearchTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final void Function(SearchFieldListItem<dynamic>)? onSuggestionTap;
  final void Function(String)? onSubmit;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final bool? obscureText;
  final bool autofocus;
  final bool enabled;
  final List<SearchFieldListItem<dynamic>> suggestions;
  final void Function(String)? onSuggestionSelected;
  final SearchFieldListItem<dynamic>? initialValue;
  final bool required;

  const CustomSearchTextFormField(
      {super.key,
      this.controller,
      this.labelText = '',
      this.hintText = '',
      this.prefixWidget,
      this.suffixWidget,
      this.onSuggestionTap,
      this.validator,
      this.inputFormatters,
      this.keyboardType,
      this.maxLines = 1,
      this.autofocus = false,
      this.maxLength,
      this.obscureText,
      this.onTap,
      this.onSubmit,
      this.enabled = true,
      required this.suggestions,
      this.onSuggestionSelected,
      this.initialValue,
      this.required = false});

  @override
  State<CustomSearchTextFormField> createState() =>
      _CustomSearchTextFormFieldState();
}

class _CustomSearchTextFormFieldState extends State<CustomSearchTextFormField> {
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = focusNode.hasFocus;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: widget.labelText != null,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(
                    widget.labelText ?? '',
                    style: const TextStyle(
                        color: AppColors.defaultColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  Visibility(
                    visible: widget.required,
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
          SearchField(
            initialValue: widget.initialValue,
            focusNode: focusNode,
            suggestions: widget.suggestions,
            onSuggestionTap: (suggestion) {
              widget.onSuggestionTap?.call(suggestion);
              focusNode.unfocus();
            },
            autofocus: widget.autofocus,
            suggestionsDecoration: SuggestionDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            onSubmit: widget.onSubmit,
            searchStyle: const TextStyle(
              fontFamily: 'Nunito',
              color: AppColors.defaultColor,
            ),
            searchInputDecoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                color: Color.fromRGBO(166, 164, 164, 1),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: isFocused
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      )
                    : BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: isFocused
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      )
                    : BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.transparent),
              ),
              border: OutlineInputBorder(
                borderRadius: isFocused
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      )
                    : BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.transparent),
              ),
              prefixIconConstraints:
                  const BoxConstraints(maxHeight: 36, maxWidth: 36),
              suffixIconConstraints:
                  const BoxConstraints(maxHeight: 36, maxWidth: 36),
            ),
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: widget.inputFormatters,
            controller: widget.controller,
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }
}
