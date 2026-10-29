import 'package:flutter/material.dart';
import 'package:delivery_app/src/models/hour_model.dart';
import 'package:delivery_app/src/models/store_company_model.dart';
import 'package:delivery_app/src/services/store_manager_service.dart';

class HoursController extends ChangeNotifier {
  HoursController(
    this.storeCompany, {
    StoreManagerService? service,
    bool loadOnCreate = true,
  }) : service = service ?? StoreManagerService() {
    if (loadOnCreate) load();
  }
  final StoreCompanyModel storeCompany;
  final StoreManagerService service;
  List<HourModel> _hours = [];
  List<HourModel> get hours => _hours;
  bool inAsyncCall = false, hasError = false, _disposed = false;
  final Set<int> _busy = {};
  bool isBusy(int id) => _busy.contains(id);
  Future<void> load() async {
    inAsyncCall = true;
    _publish();
    try {
      _hours = await service.getHours(storeCompany.id, throwOnError: true);
      hasError = false;
    } catch (_) {
      hasError = true;
    } finally {
      inAsyncCall = false;
      _publish();
    }
  }

  Future<bool> updateHour(HourModel draft) async {
    if (_busy.contains(draft.id)) return false;
    _busy.add(draft.id);
    _publish();
    try {
      final result = await service.updateHour(draft, throwOnError: true);
      final index = _hours.indexWhere((value) => value.id == result.id);
      if (index >= 0) _hours[index] = result;
      return true;
    } catch (_) {
      return false;
    } finally {
      _busy.remove(draft.id);
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
