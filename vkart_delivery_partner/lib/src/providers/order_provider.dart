import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vkart_delivery_partner/src/repositories/order_repository.dart';
import 'package:vkart_shared/vkart_shared.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();
  List<OrderModel> _assignedOrders = [];
  bool _isLoading = true;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  List<OrderModel> get assignedOrders => _assignedOrders;
  bool get isLoading => _isLoading;

  void listenToAssignedOrders(String partnerId) {
    // Cancel any previous listener so re-listening (e.g. pull-to-refresh)
    // never stacks duplicate Firestore subscriptions.
    _ordersSubscription?.cancel();
    _ordersSubscription =
        _repository.getAssignedOrders(partnerId).listen((orders) {
      _assignedOrders = orders;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('[ORDERS] Partner order stream error: $e');
    });
  }

  Stream<List<OrderModel>> getHistoryOrders(String partnerId, List<OrderStatus> statuses) {
    return _repository.getHistoryOrders(partnerId, statuses);
  }

  /// Numeric rank of the frozen workflow: ORDER PLACED → CONFIRMED →
  /// DELIVERED. 'confirmed' is the legacy alias of orderReceived.
  static int _statusRank(String value) {
    switch (value) {
      case 'orderPlaced':
        return 0;
      case 'orderReceived':
      case 'confirmed':
        return 1;
      case 'delivered':
        return 2;
      default:
        return -1;
    }
  }

  /// SECURITY GUARD (Stage 4.2): order status may only move exactly one
  /// step forward. Reversing a completed status is rejected locally; the
  /// Firestore rules enforce the same constraint server-side. A same-rank
  /// update is allowed only when it carries operational delivery data.
  Future<void> updateOrderStatus(String orderId, OrderStatus status, {String? notes, String? photoUrl, String? reason}) async {
    OrderModel? current;
    for (final order in _assignedOrders) {
      if (order.id == orderId) {
        current = order;
        break;
      }
    }
    final newRank = _statusRank(status.value);
    if (current != null && newRank >= 0) {
      final currentRank = _statusRank(current.status.value);
      final carriesOperationalData =
          notes != null || photoUrl != null || reason != null;
      final allowed = (newRank == currentRank + 1) ||
          (newRank == currentRank && carriesOperationalData);
      if (currentRank >= 0 && !allowed) {
        throw StateError(
          'Invalid order status transition for $orderId: '
          '"${current.status.value}" cannot move to "${status.value}". '
          'Allowed workflow: ORDER PLACED → CONFIRMED → DELIVERED.',
        );
      }
    }
    await _repository.updateOrderStatus(orderId, status, notes: notes, photoUrl: photoUrl, reason: reason);
  }
}
