import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/admin_brand_provider.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_button.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_empty_state.dart';
import 'package:vkart_admin/widgets/vkart_error_view.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';
import 'package:vkart_admin/widgets/vkart_search_bar.dart';

class BrandListScreen extends StatelessWidget {
  const BrandListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminBrandProvider>();

    return Scaffold(
      backgroundColor: VKartColors.background,
      appBar: VKartAppBar(
        title: 'Brands',
        subtitle: '${provider.brands.length} brands',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
child: VKartButton(
              text: 'Add Brand',
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
            child: VKartSearchBar(hint: 'Search brands...'),
          ),
Expanded(
            child: provider.error != null
                ? VKartErrorView(
                    description: provider.error,
                    onRetry: () =>
                        context.read<AdminBrandProvider>().retry(),
                  )
                : provider.isLoading
                    ? const VKartLoading(message: 'Loading brands...')
                    : provider.brands.isEmpty
? const VKartEmptyState(
                        message: 'No brands found',
                        description: 'Add brands for your products.',
                        icon: Icons.branding_watermark_rounded,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: provider.brands.length,
                        itemBuilder: (context, index) {
                          final brand = provider.brands[index];
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
                                    child: brand.logo.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              brand.logo,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.branding_watermark_rounded,
                                                color: VKartColors.primary,
                                              ),
                                            ),
                                          )
: const Icon(
                                            Icons.branding_watermark_rounded,
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
                                          brand.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: VKartColors.primaryText,
                                          ),
                                        ),
                                        if (brand.nameTelugu.isNotEmpty)
                                          Text(
                                            brand.nameTelugu,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color:
                                                  VKartColors.secondaryText,
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
