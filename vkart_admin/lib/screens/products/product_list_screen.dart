import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_shared/vkart_shared.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/utils/currency_formatter.dart';
import 'package:vkart_admin/providers/products_provider.dart';
import 'package:vkart_admin/screens/products/edit_product_screen.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_button.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_empty_state.dart';
import 'package:vkart_admin/widgets/vkart_error_view.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';
import 'package:vkart_admin/widgets/vkart_search_bar.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();

    return Scaffold(
      backgroundColor: VKartColors.background,
      appBar: VKartAppBar(
        title: 'Products',
        subtitle: '${provider.products.length} products',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
child: VKartButton(
              text: 'Add Product',
              prefixIcon: Icons.add_box_rounded,
              onPressed: () => Navigator.pushNamed(context, '/add-product'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: VKartSearchBar(
              hint: 'Search products...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: provider.error != null
                ? VKartErrorView(
                    description: provider.error,
                    onRetry: () =>
                        context.read<ProductsProvider>().loadProducts(),
                  )
                : provider.isLoading
                    ? const VKartLoading(message: 'Loading products...')
                    : provider.products.isEmpty
                        ? const VKartEmptyState(
                            message: 'No products found',
                            description:
                                'Add your first product to get started.',
                            icon: Icons.inventory_2_rounded,
                          )
                        : _buildProductList(provider.products),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<ProductModel> products) {
    final filtered = products
        .where((p) =>
            _query.isEmpty ||
            p.name.toLowerCase().contains(_query.toLowerCase()) ||
            p.category.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    if (filtered.isEmpty) {
return const VKartEmptyState(
        message: 'No matching products found',
        icon: Icons.search_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];
        return _ProductTile(product: product);
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ProductModel product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: VKartCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditProductScreen(productId: product.id),
            ),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: product.image.isNotEmpty
                  ? Image.network(
                      product.image,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: VKartColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.category}${product.weight.isNotEmpty ? ' · ${product.weight}' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: VKartColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    CurrencyFormatter.format(product.price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: VKartColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${product.stock}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: product.stock <= 5
                          ? VKartColors.error
                          : VKartColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.edit_rounded,
              color: VKartColors.secondaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 56,
      color: VKartColors.hover,
child: const Icon(
        Icons.inventory_2_rounded,
        color: VKartColors.secondaryText,
      ),
    );
  }
}
