import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vkart_shared/vkart_shared.dart';
import '../repositories/admin_delivery_partner_repository.dart';

class AdminDeliveryPartnerProvider extends ChangeNotifier {
  final AdminDeliveryPartnerRepository _repository =
      AdminDeliveryPartnerRepository();
  StreamSubscription? _subscription;

  List<DeliveryPartnerModel> _partners = [];
  bool _isLoading = false;
  String? _error;

  List<DeliveryPartnerModel> get partners => _partners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminDeliveryPartnerProvider() {
    _loadPartners();
  }

  void _loadPartners() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _subscription = _repository.getDeliveryPartners().listen(
      (partners) {
        _partners = partners;
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

  void retry() => _loadPartners();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
