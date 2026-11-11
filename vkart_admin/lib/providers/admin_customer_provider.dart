import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vkart_shared/vkart_shared.dart';
import '../repositories/admin_customer_repository.dart';

class AdminCustomerProvider extends ChangeNotifier {
  final AdminCustomerRepository _repository = AdminCustomerRepository();
  StreamSubscription? _subscription;

  List<UserModel> _customers = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminCustomerProvider() {
    _loadCustomers();
  }

  void _loadCustomers() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _subscription = _repository.getCustomers().listen(
      (customers) {
        _customers = customers;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> updateStatus(String uid, bool active) async {
    await _repository.updateCustomerStatus(uid, active);
    notifyListeners();
  }

  void retry() => _loadCustomers();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
