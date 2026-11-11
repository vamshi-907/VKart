import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vkart_shared/vkart_shared.dart';
import '../repositories/admin_sub_category_repository.dart';

class AdminSubCategoryProvider extends ChangeNotifier {
  final AdminSubCategoryRepository _repository = AdminSubCategoryRepository();
  StreamSubscription? _subscription;

  List<SubCategoryModel> _subCategories = [];
  bool _isLoading = false;
  String? _error;

  List<SubCategoryModel> get subCategories => _subCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminSubCategoryProvider() {
    _loadSubCategories();
  }

  void _loadSubCategories() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _subscription = _repository.getSubCategories().listen(
      (subCategories) {
        _subCategories = subCategories;
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

  Future<void> addSubCategory(
    SubCategoryModel subCategory,
    File? icon,
  ) async {
    await _repository.addSubCategory(subCategory, icon);
    notifyListeners();
  }

  void retry() => _loadSubCategories();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
