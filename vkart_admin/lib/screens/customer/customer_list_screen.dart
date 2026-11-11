import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/admin_customer_provider.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_empty_state.dart';
import 'package:vkart_admin/widgets/vkart_error_view.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';
import 'package:vkart_admin/widgets/vkart_search_bar.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCustomerProvider>();

    return Scaffold(
      backgroundColor: VKartColors.background,
      appBar: VKartAppBar(
        title: 'Customers',
        subtitle: '${provider.customers.length} customers',
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: VKartSearchBar(hint: 'Search customers...'),
          ),
          Expanded(
            child: provider.error != null
                ? VKartErrorView(
                    description: provider.error,
                    onRetry: () =>
                        context.read<AdminCustomerProvider>().retry(),
                  )
                : provider.isLoading
                    ? const VKartLoading(message: 'Loading customers...')
                    : provider.customers.isEmpty
? const VKartEmptyState(
                        message: 'No customers found',
                        description: 'Registered customers will appear here.',
                        icon: Icons.people_alt_rounded,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: provider.customers.length,
                        itemBuilder: (context, index) {
                          final customer = provider.customers[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: VKartCard(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: VKartColors.primary
                                        .withValues(alpha: 0.1),
                                    child: customer.photoURL != null &&
                                            customer.photoURL!.isNotEmpty
                                        ? ClipOval(
                                            child: Image.network(
                                              customer.photoURL!,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.people_alt_rounded,
                                                color: VKartColors.primary,
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.people_alt_rounded,
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
                                          customer.displayName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: VKartColors.primaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          customer.email,
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
