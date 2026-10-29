import 'package:flutter/material.dart';
import 'package:planck/src/models/company_product_model.dart';
import 'package:planck/src/models/store_company_model.dart';
import 'package:planck/src/services/store_manager_service.dart';

class ProductsController extends ChangeNotifier {
  ProductsController(
    this.storeCompany, {
    StoreManagerService? service,
    bool loadOnCreate = true,
  }) : service = service ?? StoreManagerService() {
    if (loadOnCreate) load();
  }
  final StoreManagerService service;
  final StoreCompanyModel storeCompany;
  List<CompanyProductModel> _products = [];
  List<CompanyProductModel> get products => _products;
  bool inAsyncCall = false, hasError = false, saving = false, _disposed = false;
  Future<void> load() async {
    inAsyncCall = true;
    _publish();
    try {
      _products = await service.getProducts(
        storeCompany.company.id,
        throwOnError: true,
      );
      hasError = false;
    } catch (_) {
      hasError = true;
    } finally {
      inAsyncCall = false;
      _publish();
    }
  }

  Future<bool> save(CompanyProductModel product) async {
    if (saving) return false;
    saving = true;
    _publish();
    try {
      final result = product.id > 0
          ? await service.updateProduct(product)
          : await service.createProduct(product, storeCompany.company.id);
      if (result == null) return false;
      setProducts(result);
      return true;
    } catch (_) {
      return false;
    } finally {
      saving = false;
      _publish();
    }
  }

  void setProducts(CompanyProductModel product) {
    final index = _products.indexWhere((value) => value.id == product.id);
    if (index < 0)
      _products.insert(0, product);
    else
      _products[index] = product;
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
