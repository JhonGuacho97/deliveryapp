import 'dart:async';

import 'package:flutter/material.dart';
import 'package:planck/constants/types_constant.dart';
import 'package:planck/src/models/category_model.dart';
import 'package:planck/src/models/company_model.dart';
import 'package:planck/src/models/product_model.dart';
import 'package:planck/src/provider/db_provider.dart';
import 'package:planck/src/services/market_service.dart';

class Tab1Controller with ChangeNotifier {
  Tab1Controller({
    MarketService? market,
    DBProvider? database,
    bool loadOnCreate = true,
  }) : marketService = market ?? MarketService(),
       _database = database ?? DBProvider.db {
    categories = [_selectedCategory];
    if (loadOnCreate) load();
  }

  final MarketService marketService;
  final DBProvider _database;
  List<CompanyModel> companies = [];
  List<ProductModel> products = [];
  List<CategoryModel> categories = [];
  CategoryModel _selectedCategory = CategoryModel(id: 0, name: '', image: '');
  bool _inAsyncCall = false;
  bool hasError = false;
  bool needsAddress = false;
  bool _disposed = false;
  int _requestId = 0;
  Timer? _debounce;
  String _query = '';
  String get query => _query;
  bool get inAsyncCall => _inAsyncCall;
  bool get hasFilters => _query.isNotEmpty || selectedCategory.id != 0;

  set inAsyncCall(bool value) {
    _inAsyncCall = value;
    _publish();
  }

  CategoryModel get selectedCategory => _selectedCategory;
  set selectedCategory(CategoryModel category) {
    _selectedCategory = category;
    _debounce?.cancel();
    loadCompanies();
  }

  Future<void> load() async {
    _debounce?.cancel();
    await Future.wait([loadCategories(), loadCompanies()]);
  }

  Future<void> loadCompanies({String? filter}) async {
    if (filter != null) _query = filter.trim();
    final request = ++_requestId;
    _inAsyncCall = true;
    hasError = false;
    _publish();
    try {
      final address = await _database.loadAddress();
      if (_disposed || request != _requestId) return;
      needsAddress = address == null;
      if (address == null) {
        companies = [];
        products = [];
        return;
      }
      final response = await marketService.getCompanies(
        selectedCategory,
        address.location.x,
        address.location.y,
        filter: _query,
      );
      final cart = await _database.loadProducts(TypesCompany.store);
      if (_disposed || request != _requestId) return;
      for (final product in response.products) {
        product.isInCart = cart.any((item) => item.id == product.id);
      }
      products = response.products;
      companies = response.companies;
      hasError = response.hasError;
    } catch (_) {
      if (!_disposed && request == _requestId) hasError = true;
    } finally {
      if (!_disposed && request == _requestId) {
        _inAsyncCall = false;
        _publish();
      }
    }
  }

  void filterCompanies(String filter) {
    _query = filter.trim();
    _debounce?.cancel();
    // Invalidate earlier requests as soon as the search changes.
    _requestId++;
    _inAsyncCall = true;
    _publish();
    _debounce = Timer(const Duration(milliseconds: 350), loadCompanies);
  }

  Future<void> clearFilters() async {
    _query = '';
    _selectedCategory = categories.first;
    _debounce?.cancel();
    await loadCompanies();
  }

  Future<void> loadCategories() async {
    final address = await _database.loadAddress();
    if (address == null || _disposed) return;
    final values = await marketService.getCategories(
      address.location.x,
      address.location.y,
    );
    if (_disposed) return;
    categories = [CategoryModel(id: 0, name: '', image: ''), ...values];
    _publish();
  }

  void setProducts(ProductModel product) {
    final index = products.indexWhere((item) => item.id == product.id);
    if (index >= 0) products[index] = product;
    _publish();
  }

  void _publish() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestId++;
    _debounce?.cancel();
    super.dispose();
  }
}
