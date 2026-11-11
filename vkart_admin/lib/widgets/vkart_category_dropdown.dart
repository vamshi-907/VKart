import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_shared/vkart_shared.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/admin_category_provider.dart';
import 'package:vkart_admin/widgets/vkart_button.dart';
import 'package:vkart_admin/widgets/vkart_searchable_dropdown.dart';

/// A category dropdown widget that reads from the [AdminCategoryProvider].
///
/// Displays active categories from Firestore, supports searching, and shows a
/// "No Categories Found" empty state with a "Create Category" action when there
/// are no categories available.
class VKartCategoryDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  final VoidCallback? onCreateCategory;
  final String? errorText;

  const VKartCategoryDropdown({
    super.key,
    this.value,
    this.onChanged,
    this.onCreateCategory,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AdminCategoryProvider>().categories;

    CategoryModel? selected;
    if (value != null) {
      selected = categories.where((c) => c.id == value).firstOrNull;
    }

    return VKartSearchableDropdown<CategoryModel>(
      label: 'Category *',
      hint: 'Select category',
      errorText: errorText,
      prefixIcon: Icons.category_rounded,
      itemIcon: Icons.category_rounded,
      value: selected,
      items: categories,
      itemLabel: (c) => c.name,
      searchText: (c) => '${c.name} ${c.nameTelugu}',
      onChanged: (cat) => onChanged?.call(cat?.id),
      emptyState: _buildEmptyState(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.category_rounded,
            size: 48,
            color: VKartColors.secondaryText,
          ),
          const SizedBox(height: 12),
          const Text(
            'No Categories Found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: VKartColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Create a category to continue.',
            style: TextStyle(
              fontSize: 13,
              color: VKartColors.secondaryText,
            ),
          ),
          if (onCreateCategory != null) ...[
            const SizedBox(height: 16),
            VKartButton(
              text: 'Create Category',
              prefixIcon: Icons.add_box_rounded,
              onPressed: onCreateCategory!,
            ),
          ],
        ],
      ),
    );
  }
}
