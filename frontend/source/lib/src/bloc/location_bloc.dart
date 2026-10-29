import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/src/bloc/socket_bloc.dart';
import 'package:planck/src/provider/preferences_provider.dart';

class LocationBloc {
  static LocationBloc? _instance;
  factory LocationBloc() => _instance ??= LocationBloc.testing();

  LocationBloc.testing({SocketBloc? socketBloc, DateTime Function()? now})
    : _socketBloc = socketBloc ?? SocketBloc(),
      _now = now ?? DateTime.now;

  final SocketBloc _socketBloc;
  final DateTime Function() _now;
  StreamSubscription<Position>? _getPositionSubscription;
  final _pref = PreferencesProvider();

  Future<bool> _hasPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<bool> start() async {
    if (_getPositionSubscription != null) return true;
    try {
      if (!await _hasPermission()) return false;
      _socketBloc.connect(0);
      DateTime? lastSent;
      _getPositionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 50,
            ),
          ).listen(
            (position) {
              final instant = _now();
              if (lastSent != null &&
                  instant.difference(lastSent!) <
                      const Duration(milliseconds: 5100)) {
                return;
              }
              if (!_pref.isAuth) return;
              lastSent = instant;
              _socketBloc.socket?.emit('l', {
                'id': _pref.user.id,
                'p': [position.latitude, position.longitude],
              });
            },
            onError: (Object error) {
              if (kDebugMode) debugPrint('Location stream unavailable: $error');
              unawaited(stop());
            },
          );
      return true;
    } catch (error) {
      await stop();
      if (kDebugMode) debugPrint('Location unavailable: $error');
      return false;
    }
  }

  Future<void> stop() async {
    await _getPositionSubscription?.cancel();
    _getPositionSubscription = null;
    _socketBloc.close();
  }

  Future<List<double>> determinePosition() async {
    const fallback = [klatitudeMap, klongitudeMap];
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        final position = await Geolocator.getLastKnownPosition();
        return position == null
            ? fallback
            : [position.latitude, position.longitude];
      }
      if (!await _hasPermission()) return fallback;
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 45),
        ),
      );
      return [position.latitude, position.longitude];
    } catch (_) {
      return fallback;
    }
  }

  Future<List<double>?> currentPosition() async {
    try {
      if (!await _hasPermission()) return null;
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return [position.latitude, position.longitude];
    } catch (_) {
      return null;
    }
  }
}
