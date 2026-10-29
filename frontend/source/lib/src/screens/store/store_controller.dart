import 'dart:async';

import 'package:flutter/material.dart';
import 'package:delivery_app/src/models/company_model.dart';
import 'package:delivery_app/src/models/group_model.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:delivery_app/src/provider/db_provider.dart';
import 'package:delivery_app/src/services/market_service.dart';

enum MenuPriceFilter { all, upToFive, aboveFive }

class StoreController with ChangeNotifier {
  StoreController({MarketService? market, DBProvider? database})
    : marketService = market ?? MarketService(),
      _database = database ?? DBProvider.db;
  final MarketService marketService;
  final DBProvider _database;
  CompanyModel? _company;
  CompanyModel get company => _company!;
  bool get hasCompany => _company != null;
  bool _inAsyncCall = false, _disposed = false;
  int _request = 0, _feeRequest = 0;
  double _deliveryFee = 0;
  bool hasDeliveryFee = false, hasError = false;
  final List<ProductModel> _products = [];
  GroupModel _groupSelected = GroupModel(id: 0);
  final List<GroupModel> _groups = [];
  String _query = '';
  MenuPriceFilter _priceFilter = MenuPriceFilter.all;

  set company(CompanyModel value) => unawaited(openCompany(value));

  Future<void> openCompany(CompanyModel value) async {
    _company = value;
    _products.clear();
    _groups.clear();
    _query = '';
    _priceFilter = MenuPriceFilter.all;
    hasDeliveryFee = false;
    _groupSelected = GroupModel(id: 0);
    await Future.wait([loadProducts(), loadDeliveryFeed()]);
  }

  GroupModel get groupSelected => _groupSelected;
  set groupSelected(GroupModel value) {
    _groupSelected = value;
    unawaited(loadProducts());
  }

  bool get inAsyncCall => _inAsyncCall;
  double get deliveryFee => _deliveryFee;
  List<ProductModel> get products => _products;
  List<GroupModel> get groups => _groups;
  String get query => _query;
  MenuPriceFilter get priceFilter => _priceFilter;
  set priceFilter(MenuPriceFilter value) {
    _priceFilter = value;
    _publish();
  }

  void search(String value) {
    _query = value.trim();
    _publish();
  }

  void clearFilters() {
    _query = '';
    _priceFilter = MenuPriceFilter.all;
    _publish();
  }

  static String _normalize(String text) {
    var result = text.toLowerCase();
    const accents = {
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ë': 'e',
      'í': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ö': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    accents.forEach((from, to) => result = result.replaceAll(from, to));
    return result;
  }

  List<ProductModel> get visibleProducts {
    final term = _normalize(_query);
    return _products
        .where(
          (p) =>
              (_priceFilter == MenuPriceFilter.all ||
                  (_priceFilter == MenuPriceFilter.upToFive
                      ? p.price <= 5
                      : p.price > 5)) &&
              (term.isEmpty ||
                  _normalize('${p.name} ${p.description}').contains(term)),
        )
        .toList();
  }

  void setProducts(ProductModel product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index < 0) return;
    _products[index] = product;
    _publish();
  }

  Future<void> loadDeliveryFeed() async {
    final id = ++_feeRequest;
    final selected = company;
    try {
      final address = await _database.loadAddress();
      if (address == null || _disposed || id != _feeRequest) return;
      final fees = await marketService.deliveryCost(
        selected.id.toString(),
        address.location.x,
        address.location.y,
      );
      if (_disposed || id != _feeRequest) return;
      final index = fees.indexWhere((fee) => fee.storeId == selected.storeId);
      if (index >= 0) {
        _deliveryFee = fees[index].deliveryfee;
        hasDeliveryFee = true;
        _publish();
      }
    } catch (_) {
      /* The checkout will request a fresh delivery quote. */
    }
  }

  Future<void> loadProducts() async {
    final id = ++_request;
    final selected = company;
    hasError = false;
    _inAsyncCall = true;
    _publish();
    try {
      final response = await marketService.getProducts(
        selected.id,
        groupSelected.id,
      );
      final cart = await _database.loadProducts(selected.type);
      if (_disposed || id != _request) return;
      hasError = response.hasError;
      if (hasError) return;
      _groups
        ..clear()
        ..addAll(response.groups);
      for (final product in response.products) {
        product.isInCart = cart.any((item) => item.id == product.id);
      }
      _products
        ..clear()
        ..addAll(response.products);
    } catch (_) {
      if (!_disposed && id == _request) hasError = true;
    } finally {
      if (!_disposed && id == _request) {
        _inAsyncCall = false;
        _publish();
      }
    }
  }

  void _publish() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _request++;
    _feeRequest++;
    super.dispose();
  }
}
