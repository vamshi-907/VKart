import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_delivery_partner/src/providers/order_provider.dart';
import 'package:vkart_shared/vkart_shared.dart';

class PerformanceDashboardScreen extends StatelessWidget {
  const PerformanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().assignedOrders;

    // Basic stats calculation
    final total = orders.length;
    final completed = orders.where((o) => o.status == OrderStatus.completed).length;
    final failed = orders.where((o) => o.status == OrderStatus.cancelled).length;
    final pending = total - completed - failed;

    return Scaffold(
      appBar: AppBar(title: const Text('Performance Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard('Total Assigned', '$total', Colors.blue),
                _buildStatCard('Completed', '$completed', Colors.green),
                _buildStatCard('Pending', '$pending', Colors.orange),
                _buildStatCard('Failed', '$failed', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
