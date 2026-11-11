import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Computes the executive summary from real Firestore data.
  ///
  /// - totalRevenue: sum of `grandTotal` across all orders
  /// - totalOrders: total number of orders
  /// - activeCustomers: number of active users in the `users` collection
  Future<Map<String, dynamic>> getExecutiveSummary() async {
    // Total revenue & order count from the orders collection.
    final ordersSnapshot = await _db.collection('orders').get();
    double totalRevenue = 0;
    for (final doc in ordersSnapshot.docs) {
      final grandTotal = (doc.data()['grandTotal'] as num?)?.toDouble() ?? 0;
      totalRevenue += grandTotal;
    }
    final totalOrders = ordersSnapshot.size;

    // Active customers from the users collection.
    final usersSnapshot = await _db.collection('users').get();
    int activeCustomers = 0;
    for (final doc in usersSnapshot.docs) {
      final active = (doc.data()['active'] as bool?) ?? true;
      if (active) activeCustomers++;
    }

    return {
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'activeCustomers': activeCustomers,
    };
  }
}

