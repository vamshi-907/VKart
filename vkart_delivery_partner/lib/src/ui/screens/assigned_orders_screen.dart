import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_delivery_partner/src/providers/order_provider.dart';
import 'package:vkart_delivery_partner/src/ui/screens/order_details_screen.dart';

class AssignedOrdersScreen extends StatefulWidget {
  const AssignedOrdersScreen({super.key});

  @override
  State<AssignedOrdersScreen> createState() => _AssignedOrdersScreenState();
}

class _AssignedOrdersScreenState extends State<AssignedOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Assuming partnerId is available via an AuthProvider
    // Using a placeholder for now
    context.read<OrderProvider>().listenToAssignedOrders('partner_id_here');
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    if (orderProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (orderProvider.assignedOrders.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assigned Orders')),
        body: const Center(
          child: Text('No assigned deliveries.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Assigned Orders')),
      body: ListView.builder(
        itemCount: orderProvider.assignedOrders.length,
        itemBuilder: (context, index) {
          final order = orderProvider.assignedOrders[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text('Order ID: ${order.id}'),
              subtitle: Text('Customer: ${order.address.name}\nVillage: ${order.villageName}'),
              trailing: Text('₹${order.grandTotal.toStringAsFixed(2)}'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsScreen(order: order),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}