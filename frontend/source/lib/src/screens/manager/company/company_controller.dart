import 'package:flutter/material.dart';
import 'package:planck/src/models/store_company_model.dart';
import 'package:planck/src/services/store_manager_service.dart';

class CompanyController extends ChangeNotifier {
  CompanyController({StoreManagerService? service, bool loadOnCreate = true})
    : service = service ?? StoreManagerService() {
    if (loadOnCreate) load();
  }
  final StoreManagerService service;
  List<StoreCompanyModel> _companies = [];
  List<StoreCompanyModel> get companies => _companies;
  bool inAsyncCall = false, hasError = false, _disposed = false;
  int? _selectedId;
  StoreCompanyModel? get selected =>
      _companies.where((value) => value.id == _selectedId).firstOrNull ??
      _companies.firstOrNull;
  void select(int id) {
    _selectedId = id;
    _publish();
  }

  Future<void> load() async {
    inAsyncCall = true;
    _publish();
    try {
      _companies = await service.getCompanies(throwOnError: true);
      hasError = false;
    } catch (_) {
      hasError = true;
    } finally {
      inAsyncCall = false;
      _publish();
    }
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
