import 'dart:async';
import 'package:flutter/material.dart';
import '../repositories/admin_analytics_repository.dart';

class AdminAnalyticsProvider extends ChangeNotifier {
  final AdminAnalyticsRepository _repository = AdminAnalyticsRepository();
  StreamSubscription? _subscription;

  Map<String, dynamic> _summary = {};
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminAnalyticsProvider() {
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    _isLoading = true;
    notifyListeners();
    try {
      _summary = await _repository.getExecutiveSummary();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

/// Re-triggers summary loading (used by the error Retry button).
  void retry() {
    _error = null;
    _loadSummary();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
