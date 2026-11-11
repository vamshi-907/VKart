import 'package:flutter/material.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';

/// A reusable search bar with optional filtering callback.
class VKartSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onClear;
  final bool enabled;

  const VKartSearchBar({
    super.key,
    this.hint = 'Search...',
    this.onChanged,
    this.controller,
    this.onClear,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? VKartColors.surface : VKartColors.hover,
prefixIcon: const Icon(
          Icons.search_rounded,
          color: VKartColors.secondaryText,
          size: 22,
        ),
        suffixIcon: controller != null && controller!.text.isNotEmpty
            ? IconButton(
icon: const Icon(
                  Icons.clear_rounded,
                  color: VKartColors.secondaryText,
                  size: 20,
                ),
                onPressed: () {
                  controller!.clear();
                  onClear?.call();
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
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
    );
  }
}
