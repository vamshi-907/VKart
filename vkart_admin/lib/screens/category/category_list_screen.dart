import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_shared/vkart_shared.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/admin_category_provider.dart';
import 'package:vkart_admin/screens/category/add_edit_category_dialog.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_button.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_empty_state.dart';
import 'package:vkart_admin/widgets/vkart_error_view.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';
import 'package:vkart_admin/widgets/vkart_search_bar.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const AddEditCategoryDialog(),
    );
    if (result == null || !context.mounted) return;
    final provider = context.read<AdminCategoryProvider>();
    await provider.addCategory(
      CategoryModel(
        id: '',
        name: result['name']!,
        nameTelugu: result['nameTelugu'] ?? '',
        icon: '',
        displayOrder: provider.categories.length,
        active: true,
      ),
      null,
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    dynamic category,
  ) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AddEditCategoryDialog(
        isEdit: true,
        initialName: category.name,
        initialNameTelugu: category.nameTelugu,
      ),
    );
    if (result == null || !context.mounted) return;
    await context.read<AdminCategoryProvider>().updateCategory(
      CategoryModel(
        id: category.id,
        name: result['name']!,
        nameTelugu: result['nameTelugu'] ?? '',
        icon: category.icon,
        displayOrder: category.displayOrder,
        active: category.active,
      ),
      null,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    dynamic category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: VKartColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?',
          style: const TextStyle(color: VKartColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: VKartColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AdminCategoryProvider>().deleteCategory(category.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCategoryProvider>();

    return Scaffold(
      backgroundColor: VKartColors.background,
      appBar: VKartAppBar(
        title: 'Categories',
        subtitle: '${provider.categories.length} categories',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: VKartButton(
              text: 'Add Category',
              prefixIcon: Icons.add_box_rounded,
              onPressed: () => _showAddDialog(context),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: VKartSearchBar(hint: 'Search categories...'),
          ),
Expanded(
            child: provider.error != null
                ? VKartErrorView(
                    description: provider.error,
                    onRetry: () =>
                        context.read<AdminCategoryProvider>().retry(),
                  )
                : provider.isLoading
                    ? const VKartLoading(message: 'Loading categories...')
                    : provider.categories.isEmpty
                    ? const VKartEmptyState(
                        message: 'No categories found',
                        description: 'Add your first category to get started.',
                        icon: Icons.category_rounded,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: provider.categories.length,
                        itemBuilder: (context, index) {
                          final category = provider.categories[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: VKartCard(
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: VKartColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.category_rounded,
                                      color: VKartColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: VKartColors.primaryText,
                                          ),
                                        ),
                                        if (category.nameTelugu.isNotEmpty)
                                          Text(
                                            category.nameTelugu,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color:
                                                  VKartColors.secondaryText,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Edit',
                                    icon: const Icon(
                                      Icons.edit_rounded,
                                      color: VKartColors.primary,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _showEditDialog(context, category),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    icon: const Icon(
                                      Icons.delete_rounded,
                                      color: VKartColors.error,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _confirmDelete(context, category),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
