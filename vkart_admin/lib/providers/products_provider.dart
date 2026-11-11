import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vkart_shared/vkart_shared.dart';
import '../repositories/admin_product_repository.dart';

/// Provides the list of products from the single [AdminProductRepository]
/// realtime stream and computes low-stock products.
///
/// The same stream (and therefore the same count) is used by the Dashboard
/// and the Product List, so the numbers always agree.
class ProductsProvider extends ChangeNotifier {
  final AdminProductRepository _repository = AdminProductRepository();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<ProductModel>>? _subscription;

  List<ProductModel> get products => _products;

  /// The exact number of products shown in Product List.
  int get count => _products.length;

  bool get isLoading => _isLoading;
  String? get error => _error;

/// Products with a total stock of 5 or fewer units.
  List<ProductModel> get lowStockProducts =>
      _products.where((p) => p.stock <= 5).toList();

  ProductsProvider() {
    startListening();
  }

  void startListening() {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();
    _subscription = _repository.streamProducts().listen(
          (products) {
            _products = products;
            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          onError: (Object e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
          cancelOnError: false,
        );
  }

  void retry() => startListening();

  Future<void> loadProducts({bool force = true}) async {
    if (force || _products.isEmpty) {
      _isLoading = true;
      _error = null;
      notifyListeners();
      try {
        _products = await _repository.fetchProducts();
        _error = null;
      } catch (e) {
        _error = e.toString();
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    await _repository.updateProduct(product);
    // The realtime stream updates automatically; a manual refresh is a
    // defensive measure in case the stream hasn't emitted yet.
    await loadProducts(force: true);
  }

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
    await loadProducts(force: true);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

