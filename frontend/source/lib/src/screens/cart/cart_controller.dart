import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:delivery_app/constants/types_constant.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:delivery_app/src/provider/db_provider.dart';

class CartController extends ChangeNotifier {
  CartController({DBProvider? database})
    : _database = database ?? DBProvider.db {
    loadProducts();
  }
  final DBProvider _database;
  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;
  bool loading = true;
  bool hasError = false;
  bool _disposed = false;
  double get subtotal =>
      _products.fold(0, (sum, product) => sum + product.total);
  Future<void> loadProducts() async {
    loading = true;
    hasError = false;
    _publish();
    try {
      _products = await _database.loadProducts(TypesCompany.store);
    } catch (_) {
      hasError = true;
    } finally {
      loading = false;
      _publish();
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    await _database.updateProduct(product);
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index >= 0) _products[index] = product;
    _publish();
  }

  Future<void> removeProduct(ProductModel product) async {
    await _database.deleteProduct(product);
    _products.removeWhere((p) => p.id == product.id);
    product.isInCart = false;
    _publish();
  }

  void _publish() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
