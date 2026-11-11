import 'package:flutter/material.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/widgets/vkart_button.dart';
import 'package:vkart_admin/widgets/vkart_text_field.dart';

/// A reusable dialog for adding or editing a category.
class AddEditCategoryDialog extends StatefulWidget {
  final String? initialName;
  final String? initialNameTelugu;
  final bool isEdit;

  const AddEditCategoryDialog({
    super.key,
    this.initialName,
    this.initialNameTelugu,
    this.isEdit = false,
  });

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nameTeluguController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _nameTeluguController = TextEditingController(
      text: widget.initialNameTelugu ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameTeluguController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
        'nameTelugu': _nameTeluguController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: VKartColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: VKartColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.isEdit
                          ? Icons.edit_rounded
                          : Icons.add_box_rounded,
                      color: VKartColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isEdit ? 'Edit Category' : 'Add Category',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: VKartColors.primaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              VKartTextField(
                label: 'Category Name *',
                controller: _nameController,
                hint: 'e.g. Groceries',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              VKartTextField(
                label: 'Category Name (Telugu)',
                controller: _nameTeluguController,
                hint: 'e.g. కిరాణా',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: VKartOutlinedButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: VKartButton(
                      text: widget.isEdit ? 'Save' : 'Add',
                      prefixIcon: Icons.save_rounded,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
