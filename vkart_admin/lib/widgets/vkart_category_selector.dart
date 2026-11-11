import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/widgets/vkart_searchable_dropdown.dart';

/// A searchable category selector that derives options from distinct
/// `categoryName` values (provided as a `List<String>`).
///
/// The special option `Other (+ Add New Category)` is always shown last.
/// Selecting it swaps the dropdown for a "New Category" text field. The
/// effective chosen category name is surfaced via [onChanged].
class VKartCategorySelector extends StatefulWidget {
  final List<String> categories;
  final String? initialValue;
  final ValueChanged<String?>? onChanged;
  final String? errorText;

  const VKartCategorySelector({
    super.key,
    required this.categories,
    this.initialValue,
    this.onChanged,
    this.errorText,
  });

  @override
  State<VKartCategorySelector> createState() => _VKartCategorySelectorState();
}

class _VKartCategorySelectorState extends State<VKartCategorySelector> {
  static const String _otherKey = '__other__';

  final TextEditingController _newCategoryController = TextEditingController();

  String? _selected;
  bool _isAddingNew = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
    _newCategoryController.addListener(_onNewCategoryChanged);
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _onNewCategoryChanged() {
    // Re-evaluate form validity whenever the new-category text changes so the
    // Save button stays in sync with the validation rules below.
    if (mounted) {
      setState(() {});
      widget.onChanged?.call(_newCategoryController.text.trim());
    }
  }

  bool get isAddingNew => _isAddingNew;

  void _selectOther() {
    setState(() {
      _isAddingNew = true;
      _selected = null;
    });
    widget.onChanged?.call(_newCategoryController.text.trim());
  }

  void _selectCategory(String? name) {
    setState(() {
      _isAddingNew = false;
      _selected = name;
    });
    widget.onChanged?.call(name);
  }

  @override
  Widget build(BuildContext context) {
    final items = <_CategoryOption>[
      for (final c in widget.categories) _CategoryOption(c),
      const _CategoryOption(_otherKey, label: 'Other (+ Add New Category)'),
    ];

    final selectedItem = _isAddingNew
        ? null
        : items.where((o) => o.name == _selected).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isAddingNew)
          _buildNewCategoryField()
        else
          VKartSearchableDropdown<_CategoryOption>(
            label: 'Category *',
            hint: 'Select category',
            errorText: widget.errorText,
            prefixIcon: Icons.category_rounded,
            itemIcon: Icons.category_rounded,
            value: selectedItem,
            items: items,
            itemLabel: (o) => o.label,
            searchText: (o) => o.label,
            onChanged: (option) {
              final selected = option?.name;
              if (selected == _otherKey) {
                _selectOther();
              } else {
                _selectCategory(selected);
              }
            },
          ),
      ],
    );
  }

  Widget _buildNewCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'New Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: VKartColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _newCategoryController,
          autofocus: true,
          maxLength: 40,
          inputFormatters: [
            LengthLimitingTextInputFormatter(40),
          ],
          validator: (v) {
            final val = (v ?? '').trim();
            if (val.isEmpty) return 'Category is required';
            if (val.length < 2) return 'Minimum 2 characters';
            if (val.length > 40) return 'Maximum 40 characters';
            return null;
          },
          style: const TextStyle(fontSize: 16, color: VKartColors.primaryText),
          decoration: InputDecoration(
            hintText: 'Enter New Category',
            prefixIcon: const Icon(
              Icons.category_rounded,
              color: VKartColors.secondaryText,
              size: 22,
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: VKartColors.secondaryText,
                size: 20,
              ),
              onPressed: _cancelNewCategory,
              tooltip: 'Back to category list',
            ),
            filled: true,
            fillColor: VKartColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: VKartColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: VKartColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  void _cancelNewCategory() {
    setState(() {
      _isAddingNew = false;
      _selected = null;
      _newCategoryController.clear();
    });
    widget.onChanged?.call(null);
  }
}

class _CategoryOption {
  final String name;
  final String label;
  const _CategoryOption(this.name, {String? label}) : label = label ?? name;
}
