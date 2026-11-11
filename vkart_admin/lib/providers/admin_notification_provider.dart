import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vkart_shared/vkart_shared.dart';
import '../repositories/admin_notification_repository.dart';

class AdminNotificationProvider extends ChangeNotifier {
  final AdminNotificationRepository _repository = AdminNotificationRepository();
  StreamSubscription? _subscription;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminNotificationProvider() {
    _loadNotifications();
  }

  void _loadNotifications() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _subscription = _repository.getNotifications().listen(
      (notifications) {
        _notifications = notifications;
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

  Future<void> addNotification(
    NotificationModel notification,
    File? image,
  ) async {
    _isLoading = true;
    notifyListeners();
    await _repository.addNotification(notification, image);
    _isLoading = false;
    notifyListeners();
  }

Future<void> updateNotification(
    NotificationModel notification,
    File? image,
  ) async {
    await _repository.updateNotification(notification, image);
    notifyListeners();
  }

  void retry() => _loadNotifications();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
