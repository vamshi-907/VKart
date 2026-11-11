import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/admin_delivery_partner_provider.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_empty_state.dart';
import 'package:vkart_admin/widgets/vkart_error_view.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';
import 'package:vkart_admin/widgets/vkart_search_bar.dart';

class DeliveryPartnerListScreen extends StatelessWidget {
  const DeliveryPartnerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDeliveryPartnerProvider>();

    return Scaffold(
      backgroundColor: VKartColors.background,
      appBar: const VKartAppBar(
        title: 'Delivery Partners',
        subtitle: 'Manage delivery partners',
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: VKartSearchBar(hint: 'Search delivery partners...'),
          ),
          Expanded(
            child: provider.error != null
                ? VKartErrorView(
                    description: provider.error,
                    onRetry: () =>
                        context.read<AdminDeliveryPartnerProvider>().retry(),
                  )
                : provider.isLoading
                    ? const VKartLoading(message: 'Loading delivery partners...')
                    : provider.partners.isEmpty
                        ? const VKartEmptyState(
                            message: 'No delivery partners found',
                            description:
                                'Delivery partners registered by the store will appear here.',
                            icon: Icons.delivery_dining_rounded,
                          )
                        : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: provider.partners.length,
                        itemBuilder: (context, index) {
                          final partner = provider.partners[index];
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
                                    child: partner.photoUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              partner.photoUrl,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.delivery_dining_rounded,
                                                color: VKartColors.primary,
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.delivery_dining_rounded,
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
                                          partner.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: VKartColors.primaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          partner.phone.isNotEmpty
                                              ? partner.phone
                                              : partner.email,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: VKartColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (partner.available
                                              ? VKartColors.success
                                              : VKartColors.disabled)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      partner.available ? 'Available' : 'Busy',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: partner.available
                                            ? VKartColors.success
                                            : VKartColors.secondaryText,
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
        ],
      ),
    );
  }
}
