import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_delivery_partner/src/providers/order_provider.dart';
import 'package:vkart_delivery_partner/src/services/map_service.dart';
import 'package:vkart_shared/vkart_shared.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Details: ${order.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildCustomerInfo(),
            const SizedBox(height: 16),
            _buildOrderItems(),
            const SizedBox(height: 16),
            _buildBillSummary(),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final provider = context.read<OrderProvider>();
    return Column(
      children: [
        if (order.status == OrderStatus.assigned)
          ElevatedButton(
            onPressed: () => provider.updateOrderStatus(order.id, OrderStatus.confirmed),
            child: const Text('Accept Delivery'),
          ),
        if (order.status == OrderStatus.confirmed)
          ElevatedButton(
            onPressed: () => provider.updateOrderStatus(order.id, OrderStatus.packed),
            child: const Text('Mark Picked Up'),
          ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => MapService.openMap(
            order.address,
            lat: order.address.latitude,
            lon: order.address.longitude,
          ),
          icon: const Icon(Icons.map),
          label: const Text('Open Maps'),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Card(
      child: ListTile(
        title: Text('Status: ${order.status.label}'),
        subtitle: Text('Date: ${order.createdAt}'),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      child: ListTile(
        title: Text('Customer: ${order.address.name}'),
        subtitle: Text('Phone: ${order.address.phone}\nAddress: ${order.address.displayText}'),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Column(
      children: order.items.map((item) => Card(
        child: ListTile(
          title: Text(item.name),
          subtitle: Text('Qty: ${item.quantity} x ₹${item.price}'),
          trailing: Text('₹${item.lineTotal.toStringAsFixed(2)}'),
        ),
      )).toList(),
    );
  }

  Widget _buildBillSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', order.subtotal),
            _buildSummaryRow('Delivery Charge', order.deliveryCharge),
            const Divider(),
            _buildSummaryRow('Grand Total', order.grandTotal, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text('₹${value.toStringAsFixed(2)}', style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}