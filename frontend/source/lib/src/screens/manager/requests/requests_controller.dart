import 'dart:async';

import 'package:flutter/material.dart';
import 'package:planck/constants/code_error_constant.dart';
import 'package:planck/constants/preparation_status.dart';
import 'package:planck/constants/status_constant.dart';
import 'package:planck/constants/types_constant.dart';
import 'package:planck/src/models/request_model.dart';
import 'package:planck/src/provider/push_provider.dart';
import 'package:planck/src/services/auth_service.dart';
import 'package:planck/src/services/request_service.dart';
import 'package:planck/src/services/restaurant_api.dart';

class RequestsController with ChangeNotifier {
  RequestsController({
    RequestService? service,
    AuthService? auth,
    Stream<Map<String, dynamic>>? notifications,
    bool loadOnCreate = true,
  }) : requestService = service ?? RequestService(),
       authService = auth ?? AuthService() {
    if (loadOnCreate) loadRequests();
    _subscription = (notifications ?? PushProvider().notifications).listen(
      evaluateNotification,
    );
  }
  final AuthService authService;
  final RequestService requestService;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  int _currentScreen = 0, _sequence = 0;
  bool _disposed = false, _inAsyncCall = false, hasError = false;
  bool showHistory = false;
  DateTime _selectedDay = DateTime.now();
  String _stage = PreparationStatus.pending;
  int? actionErrorCode;
  final Set<int> _busy = {};
  List<RequestModel> _requests = [];
  List<RequestModel> get requests => _requests;
  int get currentScreen => _currentScreen;
  set currentScreen(int value) {
    _currentScreen = value;
    _publish();
  }

  String get stage => _stage;
  set stage(String value) {
    _stage = value;
    _publish();
  }

  bool get inAsyncCall => _inAsyncCall;
  set inAsyncCall(bool value) {
    _inAsyncCall = value;
    _publish();
  }

  DateTime get selectedDay => _selectedDay;
  set selectedDay(DateTime value) {
    _selectedDay = value;
    loadRequests();
  }

  bool isBusy(int id) => _busy.contains(id);
  static bool editable(RequestModel request) =>
      request.status == StatusOrder.started ||
      request.status == StatusOrder.assigned;
  static String stageOf(RequestModel request) => !editable(request)
      ? PreparationStatus.dispatched
      : request.preparationStatus ?? PreparationStatus.pending;
  List<RequestModel> get visibleRequests => showHistory
      ? _requests
      : _requests.where((request) => stageOf(request) == stage).toList();
  int count(String stage) =>
      _requests.where((request) => stageOf(request) == stage).length;
  void toggleHistory() {
    showHistory = !showHistory;
    loadRequests();
  }

  Future<void> loadRequests({bool silent = false}) async {
    final sequence = ++_sequence;
    if (!silent) {
      _inAsyncCall = true;
      _publish();
    }
    try {
      final data = showHistory
          ? await requestService.history(
              _selectedDay.toIso8601String().split('T').first,
              throwOnError: true,
            )
          : await requestService.findNearRequests(throwOnError: true);
      if (_disposed || sequence != _sequence) return;
      _requests = data;
      hasError = false;
    } catch (_) {
      if (!_disposed && sequence == _sequence) hasError = true;
    } finally {
      if (!_disposed && sequence == _sequence) {
        _inAsyncCall = false;
        _publish();
      }
    }
  }

  Future<bool> accept(int id, int minutes) =>
      _act(id, () => requestService.accept(id, minutes));
  Future<bool> ready(int id) => _act(id, () => requestService.ready(id));
  Future<bool> _act(int id, Future<RequestModel> Function() action) async {
    if (_busy.contains(id)) return false;
    _busy.add(id);
    actionErrorCode = null;
    _publish();
    // Invalidate list responses started before this mutation.
    _sequence++;
    try {
      final request = await action();
      if (_disposed) return false;
      _sequence++;
      final index = _requests.indexWhere((value) => value.id == id);
      if (index >= 0)
        _requests[index] = request;
      else
        _requests.add(request);
      hasError = false;
      return true;
    } catch (error) {
      actionErrorCode = error is RestaurantApiException ? error.statusCode : 0;
      if (actionErrorCode == 409 || actionErrorCode == 404)
        await loadRequests(silent: true);
      return false;
    } finally {
      _busy.remove(id);
      _inAsyncCall = false;
      _publish();
    }
  }

  Future<void> refreshOne(RequestModel initial) async {
    try {
      final request = await requestService.findRequest(
        initial,
        throwOnError: true,
      );
      if (_disposed) return;
      final index = _requests.indexWhere((value) => value.id == request.id);
      if (index >= 0) {
        _requests[index] = request;
        _publish();
      }
    } catch (_) {}
  }

  void evaluateNotification(Map<String, dynamic> data) {
    if ([
      TypesNotification.newOrder,
      TypesNotification.changeOrderStatust,
    ].contains(data['type']))
      loadRequests(silent: true);
  }

  Future<int> checkSession() async {
    final data = await authService.check();
    if (data == null) return CodeError.unknown;
    if (data.containsKey('user')) return CodeError.none;
    return data['codeError'] ?? CodeError.unauthorized;
  }

  void removeOrder(RequestModel request) {
    _requests.removeWhere((value) => value.id == request.id);
    _publish();
  }

  void _publish() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sequence++;
    _subscription?.cancel();
    super.dispose();
  }
}
