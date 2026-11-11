import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_delivery_partner/src/providers/order_provider.dart';
import 'package:vkart_delivery_partner/src/ui/screens/order_details_screen.dart';
import 'package:vkart_shared/vkart_shared.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Delivery History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Completed'),
              Tab(text: 'Failed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HistoryListView(statuses: [OrderStatus.delivered, OrderStatus.completed]),
            HistoryListView(statuses: [OrderStatus.cancelled]), // Adjust based on failed logic
            HistoryListView(statuses: [OrderStatus.cancelled]),
          ],
        ),
      ),
    );
  }
}

class HistoryListView extends StatelessWidget {
  final List<OrderStatus> statuses;

  const HistoryListView({super.key, required this.statuses});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OrderProvider>();
    const partnerId = 'partner_id_here'; // Placeholder

    return StreamBuilder<List<OrderModel>>(
      stream: provider.getHistoryOrders(partnerId, statuses),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final orders = snapshot.data!;
        if (orders.isEmpty) return const Center(child: Text('No orders found.'));

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text('Order ID: ${order.id}'),
                subtitle: Text('Status: ${order.status.label}'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
