import 'package:flutter/material.dart';
import 'package:vkart_shared/vkart_shared.dart';
import '../repositories/admin_order_repository.dart';

class AdminOrderProvider extends ChangeNotifier {
  final AdminOrderRepository _repository = AdminOrderRepository();
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  AdminOrderProvider() {
    _loadOrders();
  }

  void _loadOrders() {
    _isLoading = true;
    _repository.getAllOrders().listen((orders) {
      _orders = orders;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _repository.updateOrderStatus(orderId, status);
  }
}
