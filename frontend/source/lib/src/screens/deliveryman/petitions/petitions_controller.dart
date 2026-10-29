import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:delivery_app/constants/code_error_constant.dart';
import 'package:delivery_app/constants/status_constant.dart';
import 'package:delivery_app/src/bloc/location_bloc.dart';
import 'package:delivery_app/src/models/petition_model.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';
import 'package:delivery_app/src/provider/push_provider.dart';
import 'package:delivery_app/src/services/auth_service.dart';
import 'package:delivery_app/src/services/petition_service.dart';

class PetitionsController extends ChangeNotifier {
  PetitionsController({
    PetitionService? service,
    LocationBloc? location,
    Stream<Map<String, dynamic>>? notifications,
    bool loadOnCreate = true,
  }) : petitionService = service ?? PetitionService(),
       _location = location ?? LocationBloc() {
    _subscription = (notifications ?? PushProvider().notifications).listen(
      (_) => loadPetitions(),
    );
    if (loadOnCreate) unawaited(loadPetitions());
  }
  final PetitionService petitionService;
  final AuthService authService = AuthService();
  final LocationBloc _location;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  final _pref = PreferencesProvider();
  final Map<int, PetitionModel> _known = {};
  List<PetitionModel> _petitions = [], historyItems = [];
  List<PetitionModel> get petitions => _petitions;
  List<PetitionModel> get active => _petitions
      .where(
        (p) =>
            p.isAssignedToMe &&
            [StatusOrder.assigned, StatusOrder.taken].contains(p.status),
      )
      .toList();
  List<PetitionModel> get offers => _petitions
      .where((p) => !p.isAssignedToMe && p.status == StatusOrder.started)
      .toList();
  PetitionModel current(PetitionModel p) => _known[p.id] ?? p;
  bool _disposed = false,
      _loading = false,
      _isOnline = false,
      availabilityBusy = false;
  bool historyVisible = false;
  bool get inAsyncCall => _loading;
  set inAsyncCall(bool value) {
    _loading = value;
    _notify();
  }

  bool get isOnline => _isOnline;
  set isOnline(bool value) {
    _isOnline = value;
    _notify();
  }

  int _screen = 0, _revision = 0;
  int _earningsRequest = 0;
  int get currentScreen => _screen;
  set currentScreen(int value) {
    _screen = value;
    _notify();
    if (value == 1) unawaited(loadEarnings());
  }

  DateTime _day = DateTime.now();
  DateTime get selectedDay => _day;
  String get dayKey => _day.toIso8601String().split('T').first;
  set selectedDay(DateTime value) {
    _day = value;
    earnings = null;
    historyItems = [];
    _notify();
    unawaited(loadEarnings());
  }

  CourierEarnings? earnings;
  String? error;
  final Set<int> _busy = {};
  bool busy(int id) => _busy.contains(id);
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  String _message(Object exception) {
    if (exception is CourierApiException) {
      if (exception.code == CodeError.insufficientBalance ||
          exception.code == CodeError.notBalance)
        return 'balance';
      if (exception.status == 401 || exception.status == 403) return 'session';
      if (exception.status == 404 || exception.status == 409) return 'changed';
    }
    return 'network';
  }

  Future<void> _tracking() async {
    if (_isOnline || active.isNotEmpty) {
      if (!await _location.start()) {
        error = 'gps';
      }
    } else {
      await _location.stop();
    }
  }

  Future<void> loadPetitions() async {
    if (_loading || availabilityBusy || _disposed) return;
    final revision = _revision;
    _loading = true;
    _notify();
    try {
      final feed = await petitionService.readFeed();
      if (_disposed || revision != _revision) return;
      _petitions = feed.petitions;
      for (final p in _petitions) {
        _known[p.id] = p;
      }
      _isOnline = feed.isOnline;
      _pref.isOnline = _isOnline;
      error = null;
      await _tracking();
    } catch (e) {
      error = _message(e);
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<void> loadEarnings() async {
    final day = dayKey;
    final revision = _revision;
    final request = ++_earningsRequest;
    try {
      final result = await petitionService.readEarnings(day);
      final history = historyVisible
          ? await petitionService.readHistory(day)
          : <PetitionModel>[];
      if (day != dayKey ||
          _disposed ||
          revision != _revision ||
          request != _earningsRequest)
        return;
      earnings = result;
      historyItems = history;
      for (final p in [...result.deliveries, ...history]) {
        _known[p.id] = p;
      }
      error = null;
    } catch (e) {
      if (day == dayKey && revision == _revision && request == _earningsRequest)
        error = _message(e);
    }
    _notify();
  }

  Future<bool> setAvailability(bool value) async {
    if (availabilityBusy || _disposed) return false;
    availabilityBusy = true;
    var confirmed = false;
    error = null;
    _revision++;
    _notify();
    try {
      List<double> position = [0, 0];
      if (value) {
        final current = await _location.currentPosition();
        if (current == null || !await _location.start()) {
          error = 'gps';
          return false;
        }
        position = current;
      }
      await petitionService.setAvailability(value, position[0], position[1]);
      _isOnline = value;
      _pref.isOnline = value;
      confirmed = true;
      await _tracking();
      return true;
    } catch (e) {
      error = _message(e);
      await _tracking();
      return false;
    } finally {
      availabilityBusy = false;
      _notify();
      if (confirmed) unawaited(loadPetitions());
    }
  }

  Future<bool> act(PetitionModel petition, String action) async {
    if (_busy.contains(petition.id) || _disposed) return false;
    _busy.add(petition.id);
    _revision++;
    error = null;
    _notify();
    try {
      final updated = await petitionService.changeDelivery(petition.id, action);
      if (_disposed) return true;
      _known[updated.id] = updated;
      _petitions.removeWhere((p) => p.id == updated.id);
      if ([
        StatusOrder.started,
        StatusOrder.assigned,
        StatusOrder.taken,
      ].contains(updated.status))
        _petitions.add(updated);
      await _tracking();
      unawaited(loadEarnings());
      return true;
    } catch (e) {
      error = _message(e);
      return false;
    } finally {
      _busy.remove(petition.id);
      _notify();
    }
  }

  Future<bool> refreshDelivery(PetitionModel p) async {
    final revision = _revision;
    try {
      final result = await petitionService.readDelivery(p.id);
      if (_disposed || revision != _revision || busy(p.id)) return false;
      _known[p.id] = result;
      error = null;
      _notify();
      return true;
    } catch (e) {
      error = _message(e);
      _notify();
      return false;
    }
  }

  Future<void> startOnline() async {
    await setAvailability(true);
  }

  Future<void> stopTracking() => _location.stop();

  Future<void> startOffline() async {
    await setAvailability(false);
  }

  Future<List<dynamic>> apply(PetitionModel p) async => await act(p, 'apply')
      ? [CodeError.none, current(p)]
      : [CodeError.unknown];
  void cleanNotificationsDeliveryman(int id) {
    final p = _known[id];
    if (p != null) p.notificationsDeliveryman = 0;
    _notify();
  }

  void removeOrder(PetitionModel p) {
    _petitions.removeWhere((item) => item.id == p.id);
    _notify();
  }

  Future<int> checkSession() async {
    final result = await authService.check();
    if (result == null) return CodeError.unknown;
    return result.containsKey('user')
        ? CodeError.none
        : (result['codeError'] ?? CodeError.unauthorized);
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    unawaited(_location.stop());
    super.dispose();
  }
}
