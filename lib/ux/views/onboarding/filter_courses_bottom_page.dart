import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/components/back_and_next_button_row.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_constants.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:flutter/material.dart';

class FilterCoursesBottomSheet extends StatefulWidget {
  const FilterCoursesBottomSheet({
    super.key,
    this.initialLevel,
    this.initialSemester,
    required this.onApply,
    required this.onReset,
  });

  final int? initialLevel;
  final int? initialSemester;
  final Function(int? level, int? semester) onApply;
  final VoidCallback onReset;

  @override
  State<FilterCoursesBottomSheet> createState() =>
      _FilterCoursesBottomSheetState();
}

class _FilterCoursesBottomSheetState extends State<FilterCoursesBottomSheet> {
  int? selectedLevel;
  int? selectedSemester;

  @override
  void initState() {
    super.initState();
    selectedLevel = widget.initialLevel;
    selectedSemester = widget.initialSemester;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerText('Levels'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              singleCategory(
                category: 'All',
                selected: selectedLevel == null,
                onTap: () {
                  setState(() {
                    selectedLevel = null;
                  });
                },
              ),
              const SizedBox(width: 6),
              AppImages.svgLine,
              const SizedBox(width: 10),
              ...AppConstants.levels.map(
                (level) => singleCategory(
                  category: level.toString(),
                  selected: selectedLevel == level,
                  onTap: () {
                    setState(() {
                      selectedLevel = level;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        headerText('Semesters'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              singleCategory(
                category: 'All',
                selected: selectedSemester == null,
                onTap: () {
                  setState(() {
                    selectedSemester = null;
                  });
                },
              ),
              const SizedBox(width: 6),
              AppImages.svgLine,
              const SizedBox(width: 10),
              ...AppConstants.semesters.map(
                (semester) => singleCategory(
                  category: semester.toString(),
                  selected: selectedSemester == semester,
                  onTap: () {
                    setState(() {
                      selectedSemester = semester;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        BackAndNextButtonRow(
          enableNextButton: enableApplyButton(),
          firstText: 'Reset Filters',
          secondText: 'Apply',
          onTapFirstButton: widget.onReset,
          onTapNextButton: () {
            widget.onApply(selectedLevel, selectedSemester);
          },
        )
      ],
    );
  }

  bool enableApplyButton() {
    return selectedLevel != null && selectedSemester != null;
  }

  Widget headerText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.defaultColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget singleCategory(
      {required String category, required bool selected, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: AppMaterial(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: selected ? AppColors.primaryTeal : AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: selected ? AppColors.defaultColor : AppColors.grey)),
          child: Text(
            category,
            style: TextStyle(
              color: selected ? AppColors.defaultColor : AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
