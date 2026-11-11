import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vkart_shared/vkart_shared.dart';
import '../repositories/admin_order_repository.dart';

/// Provides the list of orders from Firestore (single source of truth).
class OrdersProvider extends ChangeNotifier {
  final AdminOrderRepository _repository = AdminOrderRepository();
  StreamSubscription? _subscription;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  List<OrderModel> get recentOrders => _orders.take(5).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  OrdersProvider() {
    _loadOrders();
  }

  /// Re-subscribes to the orders stream (used by the error Retry button).
  void retry() {
    _error = null;
    _loadOrders();
  }

  void _loadOrders() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _subscription = _repository.getAllOrders().listen(
      (orders) {
        _orders = orders;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _repository.updateOrderStatus(orderId, status);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

