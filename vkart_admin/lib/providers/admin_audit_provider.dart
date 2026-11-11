import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vkart_shared/vkart_shared.dart';
import '../repositories/admin_audit_repository.dart';

class AdminAuditProvider extends ChangeNotifier {
  final AdminAuditRepository _repository = AdminAuditRepository();
  StreamSubscription? _subscription;

  List<AuditLogModel> _logs = [];
  bool _isLoading = false;
  String? _error;

  List<AuditLogModel> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminAuditProvider() {
    _loadLogs();
  }

  void _loadLogs() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _subscription = _repository.getAuditLogs().listen(
      (logs) {
        _logs = logs;
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

  void retry() => _loadLogs();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
