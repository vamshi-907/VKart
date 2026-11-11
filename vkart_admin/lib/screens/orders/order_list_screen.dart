import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/utils/currency_formatter.dart';
import 'package:vkart_admin/providers/orders_provider.dart';
import 'package:vkart_admin/screens/orders/order_details_screen.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_empty_state.dart';
import 'package:vkart_admin/widgets/vkart_error_view.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';
import 'package:vkart_admin/widgets/vkart_search_bar.dart';
import 'package:vkart_admin/widgets/vkart_status_chip.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();

    return Scaffold(
      backgroundColor: VKartColors.background,
      appBar: VKartAppBar(
        title: 'Orders',
        subtitle: '${provider.orders.length} orders',
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: VKartSearchBar(hint: 'Search orders...'),
          ),
          Expanded(
            child: provider.error != null
                ? VKartErrorView(
                    description: provider.error,
                    onRetry: () =>
                        context.read<OrdersProvider>().retry(),
                  )
                : provider.isLoading
                    ? const VKartLoading(message: 'Loading orders...')
                    : provider.orders.isEmpty
                        ? const VKartEmptyState(
                            message: 'No orders found',
                            description:
                                'Orders placed by customers will appear here.',
                            icon: Icons.shopping_bag_rounded,
                          )
                        : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: provider.orders.length,
                        itemBuilder: (context, index) {
                          final order = provider.orders[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: VKartCard(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrderDetailsScreen(
                                      orderId: order.id,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Order #${order.id}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: VKartColors.primaryText,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              order.address.name,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color:
                                                    VKartColors.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      VKartStatusChip(status: order.status),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
Text(
                                        CurrencyFormatter.format(order.grandTotal),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: VKartColors.primary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        order.createdAt
                                            .toLocal()
                                            .toString()
                                            .split('.')[0],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: VKartColors.secondaryText,
                                        ),
                                      ),
                                    ],
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
