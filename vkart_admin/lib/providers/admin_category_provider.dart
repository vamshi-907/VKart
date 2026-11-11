import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vkart_shared/vkart_shared.dart';
import '../repositories/admin_category_repository.dart';

class AdminCategoryProvider extends ChangeNotifier {
  final AdminCategoryRepository _repository = AdminCategoryRepository();
  StreamSubscription? _subscription;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminCategoryProvider() {
    _loadCategories();
  }

  void _loadCategories() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _subscription = _repository.getCategories().listen(
      (categories) {
        _categories = categories;
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

  Future<void> addCategory(CategoryModel category, File? image) async {
    _isLoading = true;
    notifyListeners();
    await _repository.addCategory(category, image);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateCategory(CategoryModel category, File? image) async {
    _isLoading = true;
    notifyListeners();
    await _repository.updateCategory(category, image);
    _isLoading = false;
    notifyListeners();
  }

Future<void> deleteCategory(String categoryId) async {
    _isLoading = true;
    notifyListeners();
    await _repository.deleteCategory(categoryId);
    _isLoading = false;
    notifyListeners();
  }

  void retry() => _loadCategories();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
