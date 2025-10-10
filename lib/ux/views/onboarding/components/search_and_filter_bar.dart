import 'package:attendance_app/ux/shared/components/app_form_fields.dart';
import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/course_search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchAndFilterBar extends StatelessWidget {
  const SearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.onClearSearch,
    required this.onChanged,
    required this.onSearchSubmitted,
    required this.onFilterTap,
  });

  final TextEditingController searchController;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SearchTextFormField(
              controller: searchController,
              onClear: onClearSearch,
              hintText: AppStrings.searchCourses,
              onSubmitted: onSearchSubmitted,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          FilterButton(onTap: onFilterTap),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  const FilterButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseSearchViewModel>(
      builder: (context, viewModel, _) {
        return AppMaterial(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(10),
          inkwellBorderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: viewModel.hasActiveFilter
                ? Badge(child: AppImages.svgFilterIcon)
                : AppImages.svgFilterIcon,
          ),
        );
      },
    );
  }
}
