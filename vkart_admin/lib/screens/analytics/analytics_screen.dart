import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/providers/admin_analytics_provider.dart';
import 'package:vkart_admin/utils/currency_formatter.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_error_view.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminAnalyticsProvider>();
    final summary = provider.summary;

    return Scaffold(
      backgroundColor: VKartColors.background,
      appBar: const VKartAppBar(
        title: 'Analytics',
        subtitle: 'Business performance overview',
      ),
      body: provider.error != null
          ? VKartErrorView(
              description: provider.error,
              onRetry: () => context.read<AdminAnalyticsProvider>().retry(),
            )
          : provider.isLoading
              ? const VKartLoading(message: 'Loading analytics...')
              : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMetricCard(
                    context,
                    'Total Revenue',
                    CurrencyFormatter.format(summary['totalRevenue'] ?? 0),
                    Icons.currency_rupee_rounded,
                    VKartColors.success,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricCard(
                    context,
                    'Total Orders',
                    '${summary['totalOrders'] ?? 0}',
                    Icons.shopping_bag_rounded,
                    VKartColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricCard(
                    context,
                    'Active Customers',
                    '${summary['activeCustomers'] ?? 0}',
                    Icons.people_alt_rounded,
                    VKartColors.info,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return VKartCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: VKartColors.secondaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: VKartColors.primaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
