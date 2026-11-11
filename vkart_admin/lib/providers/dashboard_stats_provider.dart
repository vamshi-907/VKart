import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

class DashboardStatsProvider extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  final Map<String, int> _counts = {};

  bool _isLoading = false;

  String? _error;

  Map<String, int> get counts => _counts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      // NOTE: 'products' is intentionally excluded here. The product count is
      // derived from the single ProductsProvider realtime stream so the
      // Dashboard and Product List always show the exact same number.
      final collections = [
        'categories',
        'orders',
        'users',
        'delivery_partners',
        'banners',
        'sub_categories',
      ];
      for (final col in collections) {
        _counts[col] = await _service.getCollectionCount(col);
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
