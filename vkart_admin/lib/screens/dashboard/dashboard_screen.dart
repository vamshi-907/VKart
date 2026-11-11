import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_admin/utils/currency_formatter.dart';
import 'package:vkart_admin/widgets/vkart_app_bar.dart';
import 'package:vkart_admin/widgets/vkart_card.dart';
import 'package:vkart_admin/widgets/vkart_stat_card.dart';
import 'package:vkart_admin/widgets/vkart_button.dart';
import 'package:vkart_admin/widgets/vkart_loading.dart';
import 'package:vkart_admin/widgets/vkart_empty_state.dart';
import 'package:vkart_admin/widgets/vkart_error_view.dart';
import 'package:vkart_admin/widgets/vkart_status_chip.dart';
import 'package:vkart_admin/providers/dashboard_stats_provider.dart';
import 'package:vkart_admin/providers/orders_provider.dart';
import 'package:vkart_admin/providers/products_provider.dart';
import 'package:vkart_admin/auth/admin_auth_provider.dart';
import 'package:vkart_admin/screens/orders/order_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardStatsProvider>().fetchAllStats();
      context.read<ProductsProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<DashboardStatsProvider>();

    return Scaffold(
      appBar: VKartAppBar(
        title: 'VKart Admin Dashboard',
        subtitle: 'Overview & quick actions',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: VKartButton(
              text: 'Add Product',
              onPressed: () => Navigator.pushNamed(context, '/add-product'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _welcomeHeader(),
            const SizedBox(height: 16),
            _adminProfileCard(),
            const SizedBox(height: 16),
            _statsGrid(statsProvider),
            const SizedBox(height: 16),
            const _RecentOrders(),
            const SizedBox(height: 16),
            const _LowStockProducts(),
          ],
        ),
      ),
    );
  }

  Widget _welcomeHeader() {
    return Card(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.dashboard_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Welcome, Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminProfileCard() {
    final authProvider = context.watch<AdminAuthProvider>();
    return VKartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (authProvider.currentAdmin != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${authProvider.currentAdmin?.name ?? 'N/A'}'),
                const SizedBox(height: 4),
                Text(
                  'Email: ${authProvider.currentAdmin?.email ?? 'Not available'}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            )
          else
            const Text(
              'Not logged in',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _statsGrid(DashboardStatsProvider provider) {
    if (provider.error != null) {
      return VKartErrorView(
        description: provider.error,
        onRetry: () => context.read<DashboardStatsProvider>().fetchAllStats(),
      );
    }

    if (provider.isLoading) {
      return const SizedBox(
        height: 200,
        child: VKartLoading(message: 'Loading stats...'),
      );
    }

    final stats = provider.counts;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width >= 1000
            ? 4
            : width >= 600
                ? 3
                : 2;
        final double cardWidth = (width - 12 * (crossAxisCount - 1)) /
            crossAxisCount;
        final double childAspectRatio =
            cardWidth >= 200 ? 1.3 : cardWidth >= 150 ? 1.1 : 1.0;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            VKartStatCard(
              title: 'Revenue',
              value: CurrencyFormatter.format(stats['revenue'] ?? 0),
              icon: Icons.currency_rupee_rounded,
              iconColor: Theme.of(context).colorScheme.primary,
            ),
            // Product count comes from the ProductsProvider (shared stream),
            // NOT from the DashboardStatsProvider, so it always matches the
            // actual Product List count.
            Consumer<ProductsProvider>(
              builder: (context, productsProvider, _) => VKartStatCard(
                title: 'Products',
                value: '${productsProvider.count}',
                icon: Icons.inventory_2_rounded,
                iconColor: Theme.of(context).colorScheme.primary,
                onTap: () => Navigator.pushNamed(context, '/products'),
              ),
            ),
            VKartStatCard(
              title: 'Categories',
              value: '${stats['categories'] ?? 0}',
              icon: Icons.category_rounded,
              onTap: () => Navigator.pushNamed(context, '/categories'),
            ),
            VKartStatCard(
              title: 'Orders',
              value: '${stats['orders'] ?? 0}',
              icon: Icons.shopping_bag_rounded,
              onTap: () => Navigator.pushNamed(context, '/orders'),
            ),
            VKartStatCard(
              title: 'Customers',
              value: '${stats['users'] ?? 0}',
              icon: Icons.people_alt_rounded,
              iconColor: Theme.of(context).colorScheme.secondary,
              onTap: () => Navigator.pushNamed(context, '/customers'),
            ),
VKartStatCard(
              title: 'Delivery Partners',
              value: '${stats['delivery_partners'] ?? 0}',
              icon: Icons.delivery_dining_rounded,
              onTap: () => Navigator.pushNamed(context, '/delivery'),
            ),
            VKartStatCard(
              title: 'Analytics',
              value: 'View',
              icon: Icons.bar_chart_rounded,
              onTap: () => Navigator.pushNamed(context, '/analytics'),
            ),
            VKartStatCard(
              title: 'Settings',
              value: 'Manage',
              icon: Icons.settings_rounded,
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        );
      },
    );
  }
}

class _RecentOrders extends StatelessWidget {
  const _RecentOrders();

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();

    return VKartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Orders',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (ordersProvider.error != null)
            VKartErrorView(
              description: ordersProvider.error,
              onRetry: () => context.read<OrdersProvider>().retry(),
            )
          else if (ordersProvider.orders.isEmpty)
            const VKartEmptyState(
              message: 'No recent orders found',
              icon: Icons.shopping_bag_rounded,
            )
          else
            ...ordersProvider.recentOrders.map(
              (order) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Order #${order.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${order.address.name} · ${order.createdAt.toLocal()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: VKartStatusChip(status: order.status),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderDetailsScreen(orderId: order.id),
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

class _LowStockProducts extends StatelessWidget {
  const _LowStockProducts();

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductsProvider>().lowStockProducts;
    return VKartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Low Stock Products',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (products.isEmpty)
            const VKartEmptyState(
              message: 'No low stock products found',
              icon: Icons.inventory_2_rounded,
            )
          else
            ...products.map(
              (product) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: product.image.isNotEmpty
                    ? Image.network(
                        product.image,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.inventory_2_rounded,
                        ),
                      )
                    : const Icon(Icons.inventory_2_rounded),
                title: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('Stock: ${product.stock}'),
              ),
            ),
        ],
      ),
    );
  }
}

