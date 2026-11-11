import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vkart_shared/vkart_shared.dart';
import '../repositories/admin_settings_repository.dart';

class AdminSettingsProvider extends ChangeNotifier {
  final AdminSettingsRepository _repository = AdminSettingsRepository();
  StreamSubscription? _subscription;

  BusinessSettingsModel? _settings;
  bool _isLoading = false;
  String? _error;

  BusinessSettingsModel? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminSettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _subscription = _repository.getSettings().listen(
      (settings) {
        _settings = settings;
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

  Future<void> updateSettings(
    BusinessSettingsModel settings, {
    File? logoFile,
    File? bannerFile,
  }) async {
    _isLoading = true;
    notifyListeners();
    await _repository.updateSettings(
      settings,
      logoFile: logoFile,
      bannerFile: bannerFile,
    );
    _isLoading = false;
    notifyListeners();
  }

  void retry() => _loadSettings();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
