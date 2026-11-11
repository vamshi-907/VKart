import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_shared/vkart_shared.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/orders_provider.dart';
import 'package:vkart_admin/utils/currency_formatter.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';
import 'package:vkart_admin/widgets/vkart_status_chip.dart';

/// Displays the details of a single order and allows updating its status.
class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final order = provider.orders.where((o) => o.id == orderId).firstOrNull;

    return Scaffold(
      backgroundColor: VKartColors.background,
      appBar: const VKartAppBar(title: 'Order Details'),
      body: provider.isLoading
          ? const VKartLoading(message: 'Loading order...')
          : order == null
              ? const Center(
                  child: Text(
                    'Order not found',
                    style: TextStyle(color: VKartColors.secondaryText),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(order),
                      const SizedBox(height: 16),
                      _buildStatusCard(context, order),
                      const SizedBox(height: 16),
                      _buildItemsCard(order),
                      const SizedBox(height: 16),
                      _buildCustomerCard(order),
                      const SizedBox(height: 16),
                      _buildTotalsCard(order),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(OrderModel order) {
    return VKartCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: VKartColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: VKartColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: VKartColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.createdAt.toLocal().toString().split('.')[0],
                  style: const TextStyle(
                    fontSize: 13,
                    color: VKartColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          VKartStatusChip(status: order.status),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, OrderModel order) {
    return VKartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: VKartColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<OrderStatus>(
            initialValue: order.status,
            decoration: InputDecoration(
              filled: true,
              fillColor: VKartColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: VKartColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: VKartColors.border),
              ),
            ),
            items: OrderStatus.values
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.label),
                  ),
                )
                .toList(),
            onChanged: (status) async {
              if (status == null || status == order.status) return;
              await context.read<OrdersProvider>().updateStatus(
                    order.id,
                    status,
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(OrderModel order) {
    return VKartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: VKartColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: VKartColors.primaryText,
                          ),
                        ),
                        if (item.weight.isNotEmpty)
                          Text(
                            item.weight,
                            style: const TextStyle(
                              fontSize: 12,
                              color: VKartColors.secondaryText,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '×${item.quantity}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: VKartColors.secondaryText,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    CurrencyFormatter.format(item.lineTotal),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: VKartColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(OrderModel order) {
    return VKartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer & Delivery',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: VKartColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.person_rounded,
                size: 20,
                color: VKartColors.secondaryText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.address.displayText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: VKartColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.payment_rounded,
                size: 20,
                color: VKartColors.secondaryText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Payment: ${order.paymentMethod}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: VKartColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsCard(OrderModel order) {
    return VKartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: VKartColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          _buildTotalRow('Subtotal', order.subtotal),
          const SizedBox(height: 6),
          _buildTotalRow('Delivery Charge', order.deliveryCharge),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: VKartColors.border),
          ),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: VKartColors.primaryText,
                ),
              ),
              const Spacer(),
              Text(
                CurrencyFormatter.format(order.grandTotal),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: VKartColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: VKartColors.secondaryText,
          ),
        ),
        const Spacer(),
        Text(
          CurrencyFormatter.format(value),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: VKartColors.primaryText,
          ),
        ),
      ],
    );
  }
}
