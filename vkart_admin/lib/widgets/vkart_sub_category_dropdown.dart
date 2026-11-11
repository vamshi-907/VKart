import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_shared/vkart_shared.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/admin_sub_category_provider.dart';
import 'package:vkart_admin/widgets/vkart_searchable_dropdown.dart';

/// A sub-category dropdown widget that reads from the
/// [AdminSubCategoryProvider].
///
/// Filters sub-categories by the selected [categoryId]. When no category is
/// selected, or there are no sub-categories for the selected category, the
/// dropdown is disabled and shows a "No Sub Categories" hint.
class VKartSubCategoryDropdown extends StatelessWidget {
  final String? value;
  final String? categoryId;
  final ValueChanged<String?>? onChanged;
  final String? errorText;

  const VKartSubCategoryDropdown({
    super.key,
    this.value,
    this.categoryId,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final allSubCategories =
        context.watch<AdminSubCategoryProvider>().subCategories;

    final enabled = categoryId != null;
    final filtered = categoryId == null
        ? <SubCategoryModel>[]
        : allSubCategories
            .where((s) => s.categoryId == categoryId)
            .toList();

    SubCategoryModel? selected;
    if (value != null) {
      selected = allSubCategories.where((s) => s.id == value).firstOrNull;
    }

    return VKartSearchableDropdown<SubCategoryModel>(
      label: 'Sub Category',
      hint: enabled
          ? (filtered.isEmpty ? 'No Sub Categories' : 'Select sub category')
          : 'Select category first',
      errorText: errorText,
      prefixIcon: Icons.account_tree_rounded,
      itemIcon: Icons.account_tree_rounded,
      itemIconColor: VKartColors.accent,
      value: selected,
      items: filtered,
      enabled: enabled && filtered.isNotEmpty,
      itemLabel: (s) => s.name,
      searchText: (s) => '${s.name} ${s.nameTelugu}',
      onChanged: (sub) => onChanged?.call(sub?.id),
      emptyState: _buildEmptyState(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_tree_rounded,
            size: 48,
            color: VKartColors.secondaryText,
          ),
          SizedBox(height: 12),
          Text(
            'No Sub Categories',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: VKartColors.primaryText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'No sub categories available for this category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: VKartColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
