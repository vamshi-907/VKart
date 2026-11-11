import 'package:flutter/material.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';

/// A searchable dropdown field with VKart theming.
///
/// Displays a text-like field that, when tapped, opens a modal bottom sheet
/// containing a search input and a scrollable list of options. Supports
/// live filtering, custom empty states, and a disabled state.
class VKartSearchableDropdown<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final String Function(T item)? searchText;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final IconData? prefixIcon;
  final IconData? itemIcon;
  final Color? itemIconColor;

  /// Widget to show when [items] is empty. If null, a default
  /// "No items found" empty state is shown.
  final Widget? emptyState;

  /// Widget to show when the search query yields no matches.
  final Widget? noSearchResults;

  const VKartSearchableDropdown({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.value,
    required this.items,
    required this.itemLabel,
    this.searchText,
    this.onChanged,
    this.enabled = true,
    this.prefixIcon,
    this.itemIcon,
    this.itemIconColor,
    this.emptyState,
    this.noSearchResults,
  });

  @override
  State<VKartSearchableDropdown<T>> createState() =>
      _VKartSearchableDropdownState<T>();
}

class _VKartSearchableDropdownState<T>
    extends State<VKartSearchableDropdown<T>> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  String _labelOf(T item) => widget.itemLabel(item);

Future<void> _openPicker() async {
    if (!widget.enabled) return;
    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchablePicker<T>(
        currentValue: widget.value,
        items: widget.items,
        itemLabel: widget.itemLabel,
        searchText: widget.searchText,
        itemIcon: widget.itemIcon,
        itemIconColor: widget.itemIconColor,
        emptyState: widget.emptyState,
        noSearchResults: widget.noSearchResults,
      ),
    );
    if (selected != null) {
      widget.onChanged?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null;
    final Color borderColor = hasError
        ? VKartColors.error
        : (_hasFocus ? VKartColors.primary : VKartColors.border);
    final Color fillColor =
        (widget.enabled && widget.items.isNotEmpty)
            ? VKartColors.surface
            : VKartColors.hover;

    final selectedItem = widget.items
        .where((item) => item == widget.value)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: VKartColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
        ],
Focus(
          focusNode: _focusNode,
          child: InkWell(
            onTap: widget.enabled && widget.items.isNotEmpty
                ? _openPicker
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasError ? VKartColors.error : borderColor,
                width: hasError
                    ? 1
                    : (_hasFocus ? 2 : 1),
              ),
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  Icon(
                    widget.prefixIcon,
                    color: _hasFocus
                        ? VKartColors.primary
                        : VKartColors.secondaryText,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    selectedItem != null
                        ? _labelOf(selectedItem)
                        : (widget.hint ?? 'Select...'),
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedItem != null
                          ? VKartColors.primaryText
                          : VKartColors.secondaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!widget.enabled || widget.items.isEmpty)
                  const Icon(
                    Icons.block_rounded,
                    color: VKartColors.disabled,
                    size: 20,
                  )
                else
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: VKartColors.secondaryText,
                    size: 24,
                  ),
],
            ),
          ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: const TextStyle(
              fontSize: 12,
              color: VKartColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// The modal bottom sheet showing a search box and options list.
class _SearchablePicker<T> extends StatefulWidget {
  final T? currentValue;
  final List<T> items;
  final String Function(T item) itemLabel;
  final String Function(T item)? searchText;
  final IconData? itemIcon;
  final Color? itemIconColor;
  final Widget? emptyState;
  final Widget? noSearchResults;

  const _SearchablePicker({
    required this.currentValue,
    required this.items,
    required this.itemLabel,
    this.searchText,
    this.itemIcon,
    this.itemIconColor,
    this.emptyState,
    this.noSearchResults,
  });

  @override
  State<_SearchablePicker<T>> createState() => _SearchablePickerState<T>();
}

class _SearchablePickerState<T> extends State<_SearchablePicker<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.items;
    return widget.items.where((item) {
      final label = widget.itemLabel(item).toLowerCase();
      final searchable = widget.searchText?.call(item).toLowerCase() ?? '';
      return label.contains(query) || searchable.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final hasItems = widget.items.isNotEmpty;
    final hasResults = filtered.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: VKartColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: VKartColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                controller: _searchController,
                enabled: hasItems,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: hasItems ? 'Search...' : 'No items',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: VKartColors.secondaryText,
                    size: 22,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: VKartColors.secondaryText,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: VKartColors.hover,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: VKartColors.border,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: VKartColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: !hasItems
                  ? (widget.emptyState ??
                      _defaultEmptyState('No items found'))
                  : !hasResults
                      ? (widget.noSearchResults ??
                          _defaultEmptyState('No matching items'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final selected = item == widget.currentValue;
                            return _buildItem(item, selected);
                          },
                        ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _defaultEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 48,
            color: VKartColors.secondaryText,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: VKartColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildItem(T item, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: () => Navigator.pop(context, item),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? VKartColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (widget.itemIcon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (widget.itemIconColor ?? VKartColors.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.itemIcon,
                    color: widget.itemIconColor ?? VKartColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  widget.itemLabel(item),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? VKartColors.primary
                        : VKartColors.primaryText,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: VKartColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
