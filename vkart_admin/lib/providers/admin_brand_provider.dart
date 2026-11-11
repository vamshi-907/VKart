import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vkart_shared/vkart_shared.dart';
import '../repositories/admin_brand_repository.dart';

class AdminBrandProvider extends ChangeNotifier {
  final AdminBrandRepository _repository = AdminBrandRepository();
  StreamSubscription? _subscription;

  List<BrandModel> _brands = [];
  bool _isLoading = false;
  String? _error;

  List<BrandModel> get brands => _brands;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminBrandProvider() {
    _loadBrands();
  }

  void _loadBrands() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _subscription = _repository.getBrands().listen(
      (brands) {
        _brands = brands;
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

  Future<void> addBrand(BrandModel brand, File? logo) async {
    _isLoading = true;
    notifyListeners();
    await _repository.addBrand(brand, logo);
    _isLoading = false;
    notifyListeners();
  }

Future<void> updateBrand(BrandModel brand, File? logo) async {
    _isLoading = true;
    notifyListeners();
    await _repository.updateBrand(brand, logo);
    _isLoading = false;
    notifyListeners();
  }

  void retry() => _loadBrands();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
