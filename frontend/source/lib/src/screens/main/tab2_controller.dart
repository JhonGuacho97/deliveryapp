import 'dart:async';

import 'package:flutter/material.dart';
import 'package:delivery_app/constants/types_constant.dart';
import 'package:delivery_app/src/models/order_model.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';
import 'package:delivery_app/src/provider/push_provider.dart';
import 'package:delivery_app/src/services/market_service.dart';

class Tab2Controller with ChangeNotifier {
  Tab2Controller({
    MarketService? market,
    Stream<Map<String, dynamic>>? notifications,
    bool loadOnCreate = true,
  }) : marketService = market ?? MarketService() {
    if (loadOnCreate) loadOrders();
    _subscription = (notifications ?? PushProvider().notifications).listen(
      evaluateNotification,
    );
  }
  final MarketService marketService;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  bool _disposed = false;
  int _requestId = 0;
  bool _inAsyncCall = false;
  bool hasError = false;
  int _numOrders = 0;
  List<OrderModel> orders = [];
  bool get inAsyncCall => _inAsyncCall;
  int get numOrders => _numOrders;
  set numOrders(int value) {
    _numOrders = value;
    _publish();
  }

  set inAsyncCall(bool value) {
    _inAsyncCall = value;
    _publish();
  }

  void evaluateNotification(Map<String, dynamic> notification) {
    if (notification['type'] == TypesNotification.changeOrderStatust) {
      loadOrders();
    } else if (notification['type'] == TypesNotification.messageChat) {
      final id = int.tryParse(notification['orderId'].toString());
      final index = orders.indexWhere((order) => order.id == id);
      if (index >= 0) {
        orders[index].notificationsClient++;
        _publish();
      }
    }
  }

  void cleanNotificationsClient(int orderId) {
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index >= 0) {
      orders[index].notificationsClient = 0;
      _publish();
    }
  }

  Future<void> loadOrders() async {
    final request = ++_requestId;
    hasError = false;
    if (!PreferencesProvider().isAuth) {
      orders = [];
      _numOrders = 0;
      _inAsyncCall = false;
      _publish();
      return;
    }
    _inAsyncCall = true;
    _publish();
    try {
      final result = await marketService.getOrders(throwOnError: true);
      if (_disposed || request != _requestId) return;
      orders = result;
      _numOrders = orders.length;
    } catch (_) {
      if (!_disposed && request == _requestId) hasError = true;
    } finally {
      if (!_disposed && request == _requestId) {
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
    _requestId++;
    _subscription?.cancel();
    super.dispose();
  }
}
