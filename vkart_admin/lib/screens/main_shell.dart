import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkart_admin/auth/admin_auth_provider.dart';
import 'package:vkart_admin/materials/vkart_colors.dart';
import 'package:vkart_admin/screens/dashboard/dashboard_screen.dart';
import 'package:vkart_admin/screens/products/product_list_screen.dart';
import 'package:vkart_admin/screens/category/category_list_screen.dart';
import 'package:vkart_admin/screens/sub_category/sub_category_list_screen.dart';
import 'package:vkart_admin/screens/brand/brand_list_screen.dart';
import 'package:vkart_admin/screens/orders/order_list_screen.dart';
import 'package:vkart_admin/screens/customer/customer_list_screen.dart';
import 'package:vkart_admin/screens/notification/notification_list_screen.dart';
import 'package:vkart_admin/screens/analytics/analytics_screen.dart';
import 'package:vkart_admin/screens/audit/audit_log_screen.dart';
import 'package:vkart_admin/screens/settings/business_settings_screen.dart';

/// The main navigation shell.
///
/// Responsive layout:
/// - Mobile  (< 600dp): Scaffold `Drawer` for navigation.
/// - Tablet   (>= 600dp): Compact `NavigationRail` on the left.
/// - Desktop  (>= 1100dp): Extended `NavigationRail` (labels always visible).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const List<_MenuItem> _menuItems = [
    _MenuItem('Dashboard', Icons.dashboard_rounded, Icons.dashboard_rounded),
    _MenuItem('Products', Icons.inventory_2_rounded, Icons.inventory_2_rounded),
    _MenuItem('Categories', Icons.category_rounded, Icons.category_rounded),
    _MenuItem(
      'Sub Categories',
      Icons.account_tree_rounded,
      Icons.account_tree_rounded,
    ),
    _MenuItem(
      'Brands',
      Icons.branding_watermark_rounded,
      Icons.branding_watermark_rounded,
    ),
    _MenuItem('Orders', Icons.shopping_bag_rounded, Icons.shopping_bag_rounded),
    _MenuItem('Customers', Icons.people_alt_rounded, Icons.people_alt_rounded),
    _MenuItem(
      'Notifications',
      Icons.notifications_rounded,
      Icons.notifications_rounded,
    ),
    _MenuItem('Analytics', Icons.bar_chart_rounded, Icons.bar_chart_rounded),
    _MenuItem('Audit Logs', Icons.history_rounded, Icons.history_rounded),
    _MenuItem('Settings', Icons.settings_rounded, Icons.settings_rounded),
  ];

  static const List<Widget> _screens = [
    DashboardScreen(),
    ProductListScreen(),
    CategoryListScreen(),
    SubCategoryListScreen(),
    BrandListScreen(),
    OrderListScreen(),
    CustomerListScreen(),
    NotificationListScreen(),
    AnalyticsScreen(),
    AuditLogScreen(),
    BusinessSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 1100;
        final bool isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1100;

        // Mobile: Scaffold with Drawer
        if (!isDesktop && !isTablet) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: VKartColors.surface,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  color: VKartColors.primaryText,
                  tooltip: 'Open navigation menu',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: const Text(
                'VKart Admin',
                style: TextStyle(
                  color: VKartColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            drawer: _buildDrawer(context),
            body: _screens[_selectedIndex],
          );
        }

        // Tablet / Desktop: NavigationRail on the left
        return Scaffold(
          body: Row(
            children: [
              _buildNavigationRail(isDesktop),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                child: _screens[_selectedIndex],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationRail(bool extended) {
    final auth = context.watch<AdminAuthProvider>();

    return SafeArea(
      child: NavigationRail(
        extended: extended,
        backgroundColor: VKartColors.surface,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: VKartColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              if (extended) ...[
                const SizedBox(height: 8),
                const Text(
                  'VKart Admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: VKartColors.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: _buildLogoutButton(auth, extended),
        ),
        destinations: [
          for (final item in _menuItems)
            NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final auth = context.watch<AdminAuthProvider>();

    return Drawer(
      backgroundColor: VKartColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: VKartColors.primary,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.storefront,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'VKart Admin',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Store Management',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  final selected = index == _selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Material(
                      color: selected
                          ? VKartColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: Icon(
                          selected ? item.selectedIcon : item.icon,
                          size: 22,
                          color: selected
                              ? VKartColors.primary
                              : VKartColors.secondaryText,
                        ),
                        title: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w500,
                            color: selected
                                ? VKartColors.primary
                                : VKartColors.primaryText,
                          ),
                        ),
                        selected: selected,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildLogoutButton(auth, true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AdminAuthProvider auth, bool showName) {
    return Material(
      color: VKartColors.hover,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => auth.performLogout(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, size: 22, color: VKartColors.error),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Logout',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: VKartColors.error,
                  ),
                ),
              ),
              if (showName && auth.currentAdmin != null)
                Flexible(
                  child: Text(
                    auth.currentAdmin!.name.split(' ').isNotEmpty
                        ? auth.currentAdmin!.name.split(' ').first
                        : '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: VKartColors.secondaryText,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const _MenuItem(this.label, this.icon, this.selectedIcon);
}

