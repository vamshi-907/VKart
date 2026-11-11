import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:vkart_admin/firebase_options.dart';
import 'package:vkart_admin/auth/admin_auth_provider.dart';
import 'package:vkart_admin/providers/dashboard_stats_provider.dart';
import 'package:vkart_admin/providers/orders_provider.dart';
import 'package:vkart_admin/providers/products_provider.dart';
import 'package:vkart_admin/providers/admin_customer_provider.dart';
import 'package:vkart_admin/providers/admin_notification_provider.dart';
import 'package:vkart_admin/providers/admin_audit_provider.dart';
import 'package:vkart_admin/providers/admin_settings_provider.dart';
import 'package:vkart_admin/providers/admin_analytics_provider.dart';
import 'package:vkart_admin/auth/auth_gate.dart';
import 'package:vkart_admin/screens/login/admin_login_screen.dart';
import 'package:vkart_admin/screens/login/admin_otp_screen.dart';
import 'package:vkart_admin/screens/login/access_denied_screen.dart';
import 'package:vkart_admin/screens/dashboard/dashboard_screen.dart';
import 'package:vkart_admin/screens/products/add_product_screen.dart';
import 'package:vkart_admin/theme/vkart_theme.dart';
import 'package:vkart_admin/providers/admin_brand_provider.dart';
import 'package:vkart_admin/providers/admin_category_provider.dart';
import 'package:vkart_admin/providers/admin_sub_category_provider.dart';
import 'package:vkart_admin/providers/admin_delivery_partner_provider.dart';
import 'package:vkart_admin/screens/products/product_list_screen.dart';
import 'package:vkart_admin/screens/category/category_list_screen.dart';
import 'package:vkart_admin/screens/orders/order_list_screen.dart';
import 'package:vkart_admin/screens/customer/customer_list_screen.dart';
import 'package:vkart_admin/screens/delivery/delivery_partner_list_screen.dart';
import 'package:vkart_admin/screens/analytics/analytics_screen.dart';
import 'package:vkart_admin/screens/settings/business_settings_screen.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardStatsProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => AdminBrandProvider()),
        ChangeNotifierProvider(create: (_) => AdminCategoryProvider()),
        ChangeNotifierProvider(create: (_) => AdminSubCategoryProvider()),
        ChangeNotifierProvider(create: (_) => AdminDeliveryPartnerProvider()),
        ChangeNotifierProvider(create: (_) => AdminCustomerProvider()),
        ChangeNotifierProvider(create: (_) => AdminNotificationProvider()),
        ChangeNotifierProvider(create: (_) => AdminAuditProvider()),
        ChangeNotifierProvider(create: (_) => AdminSettingsProvider()),
        ChangeNotifierProvider(create: (_) => AdminAnalyticsProvider()),
      ],
      child: MaterialApp(
        title: 'VKart Admin',
        theme: vkartTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthGate(),
'/login': (context) => const AdminLoginScreen(),
          '/otp': (context) => const AdminOtpScreen(),
          '/access-denied': (context) => const AccessDeniedScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/add-product': (context) => const AddProductScreen(),
          '/products': (context) => const ProductListScreen(),
          '/categories': (context) => const CategoryListScreen(),
          '/orders': (context) => const OrderListScreen(),
          '/customers': (context) => const CustomerListScreen(),
          '/delivery': (context) => const DeliveryPartnerListScreen(),
          '/analytics': (context) => const AnalyticsScreen(),
          '/settings': (context) => const BusinessSettingsScreen(),
        },
      ),
    );
  }
}
