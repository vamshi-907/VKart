import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/admin_category_provider.dart';
import 'package:vkart_admin/providers/admin_sub_category_provider.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_button.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_empty_state.dart';
import 'package:vkart_admin/widgets/vkart_error_view.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';
import 'package:vkart_admin/widgets/vkart_search_bar.dart';

class SubCategoryListScreen extends StatelessWidget {
  const SubCategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminSubCategoryProvider>();
    final categories = context.watch<AdminCategoryProvider>().categories;

    String categoryName(String categoryId) {
      final cat = categories.where((c) => c.id == categoryId).firstOrNull;
      return cat?.name ?? 'Unknown';
    }

    return Scaffold(
      backgroundColor: VKartColors.background,
      appBar: VKartAppBar(
        title: 'Sub Categories',
        subtitle: '${provider.subCategories.length} sub categories',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
child: VKartButton(
              text: 'Add Sub Category',
              prefixIcon: Icons.add_box_rounded,
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: VKartSearchBar(hint: 'Search sub categories...'),
          ),
          Expanded(
            child: provider.error != null
                ? VKartErrorView(
                    description: provider.error,
                    onRetry: () =>
                        context.read<AdminSubCategoryProvider>().retry(),
                  )
                : provider.isLoading
                    ? const VKartLoading(message: 'Loading sub categories...')
                    : provider.subCategories.isEmpty
? const VKartEmptyState(
                        message: 'No sub categories found',
                        description: 'Add sub categories to organize products.',
                        icon: Icons.account_tree_rounded,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: provider.subCategories.length,
                        itemBuilder: (context, index) {
                          final sub = provider.subCategories[index];
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
                                      color: VKartColors.accent.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
child: const Icon(
                                      Icons.account_tree_rounded,
                                      color: VKartColors.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sub.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: VKartColors.primaryText,
                                          ),
                                        ),
                                        Text(
                                          categoryName(sub.categoryId),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: VKartColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: VKartColors.secondaryText,
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
