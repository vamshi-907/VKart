import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_shared/vkart_shared.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/admin_brand_provider.dart';
import 'package:vkart_admin/widgets/vkart_button.dart';
import 'package:vkart_admin/widgets/vkart_searchable_dropdown.dart';

/// A brand dropdown widget that reads from the [AdminBrandProvider].
///
/// Displays active brands from the Firestore `brands` collection, supports
/// searching, and shows a "No Brands Found" empty state with a "Create Brand"
/// action when there are no brands available.
class VKartBrandDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  final VoidCallback? onCreateBrand;
  final String? errorText;

  const VKartBrandDropdown({
    super.key,
    this.value,
    this.onChanged,
    this.onCreateBrand,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final brands = context.watch<AdminBrandProvider>().brands;

    BrandModel? selected;
    if (value != null) {
      selected = brands.where((b) => b.id == value).firstOrNull;
    }

    return VKartSearchableDropdown<BrandModel>(
      label: 'Brand',
      hint: 'Select brand',
      errorText: errorText,
      prefixIcon: Icons.branding_watermark_rounded,
      itemIcon: Icons.branding_watermark_rounded,
      value: selected,
      items: brands,
      itemLabel: (b) => b.name,
      searchText: (b) => '${b.name} ${b.nameTelugu}',
      onChanged: (brand) => onChanged?.call(brand?.id),
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
            Icons.branding_watermark_rounded,
            size: 48,
            color: VKartColors.secondaryText,
          ),
          const SizedBox(height: 12),
          const Text(
            'No Brands Found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: VKartColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Create a brand to continue.',
            style: TextStyle(
              fontSize: 13,
              color: VKartColors.secondaryText,
            ),
          ),
          if (onCreateBrand != null) ...[
            const SizedBox(height: 16),
            VKartButton(
              text: 'Create Brand',
              prefixIcon: Icons.add_box_rounded,
              onPressed: onCreateBrand!,
            ),
          ],
        ],
      ),
    );
  }
}
