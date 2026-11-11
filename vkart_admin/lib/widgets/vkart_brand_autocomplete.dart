import 'package:flutter/material.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';

/// A searchable brand text field with live suggestions.
///
/// Suggestions come from distinct `brandName` values (provided as a
/// `List<String>`). The admin can either tap a suggestion or type a brand-new
/// brand. The current text value is surfaced via [onChanged].
class VKartBrandAutocomplete extends StatefulWidget {
  final List<String> brands;
  final String? initialValue;
  final ValueChanged<String?>? onChanged;
  final String? errorText;

  const VKartBrandAutocomplete({
    super.key,
    required this.brands,
    this.initialValue,
    this.onChanged,
    this.errorText,
  });

  @override
  State<VKartBrandAutocomplete> createState() => _VKartBrandAutocompleteState();
}

class _VKartBrandAutocompleteState extends State<VKartBrandAutocomplete> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brands = widget.brands;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Brand',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: VKartColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        RawAutocomplete<String>(
          textEditingController: _controller,
          focusNode: _focusNode,
          optionsBuilder: (TextEditingValue v) {
            final query = v.text.trim().toLowerCase();
            if (query.isEmpty) return const Iterable<String>.empty();
            return brands.where(
              (b) => b.toLowerCase().contains(query),
            );
          },
          onSelected: (s) {
            _controller.text = s;
            _controller.selection = TextSelection.collapsed(
              offset: _controller.text.length,
            );
            widget.onChanged?.call(s);
          },
          fieldViewBuilder: _buildField,
          optionsViewBuilder: _buildOptions,
        ),
      ],
    );
  }

  Widget _buildField(
    BuildContext context,
    TextEditingController textController,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  ) {
return _BrandField(
      controller: textController,
      focusNode: focusNode,
      errorText: widget.errorText,
      onChanged: (v) => widget.onChanged?.call(
        v.trim().isEmpty ? null : v.trim(),
      ),
    );
  }

  Widget _buildOptions(
    BuildContext context,
    AutocompleteOnSelected<String> onSelected,
    Iterable<String> options,
  ) {
    return _BrandOptions(
      options: options.toList(),
      onSelected: onSelected,
    );
  }
}

class _BrandField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const _BrandField({
    required this.controller,
    required this.focusNode,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16, color: VKartColors.primaryText),
      decoration: InputDecoration(
        hintText: 'Type brand name (optional)',
        errorText: errorText,
        prefixIcon: const Icon(
          Icons.branding_watermark_rounded,
          color: VKartColors.secondaryText,
          size: 22,
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
          borderSide: BorderSide(
            color: hasError ? VKartColors.error : VKartColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: hasError ? VKartColors.error : VKartColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: VKartColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: VKartColors.error, width: 2),
        ),
      ),
    );
  }
}

class _BrandOptions extends StatelessWidget {
  final List<String> options;
  final ValueChanged<String> onSelected;

  const _BrandOptions({
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: VKartColors.surface,
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260, maxWidth: 420),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return InkWell(
                onTap: () => onSelected(option),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.branding_watermark_rounded,
                        color: VKartColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: VKartColors.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
