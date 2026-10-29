import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

typedef SocketFactory = io.Socket Function(String, Map<String, dynamic>);

class SocketBloc {
  static SocketBloc? _instance;
  factory SocketBloc() => _instance ??= SocketBloc.connection();

  SocketBloc.connection({
    String? endpoint,
    PreferencesProvider? preferences,
    SocketFactory? socketFactory,
  }) : _endpoint = endpoint ?? kSokect,
       prefs = preferences ?? PreferencesProvider(),
       _socketFactory = socketFactory ?? io.io;

  final String _endpoint;
  final PreferencesProvider prefs;
  final SocketFactory _socketFactory;
  io.Socket? socket;
  int? _deliveryUserId;
  final streamController = StreamController<LatLng>.broadcast();
  Function(LatLng) get sink => streamController.sink.add;
  Stream<LatLng> get stream => streamController.stream;

  void close() {
    socket?.dispose();
    socket = null;
    _deliveryUserId = null;
  }

  void connect(int idUserDeliveryMen) {
    if (streamController.isClosed) return;
    if (socket != null && _deliveryUserId == idUserDeliveryMen) {
      if (!socket!.connected) socket!.connect();
      return;
    }
    close();
    _deliveryUserId = idUserDeliveryMen;
    socket = _socketFactory(_endpoint, <String, dynamic>{
      'path': '/socket.io',
      'autoConnect': false,
      'forceNew': true,
      'transports': ['websocket'],
      'extraHeaders': {
        'auth': prefs.token,
        'iduserdeliverymen': idUserDeliveryMen.toString(),
      },
    });
    socket!.on('l', (dynamic data) {
      if (data is! List || data.length < 2) return;
      if (data[0] is! num || data[1] is! num) return;
      final latitude = (data[0] as num).toDouble();
      final longitude = (data[1] as num).toDouble();
      if (!latitude.isFinite ||
          !longitude.isFinite ||
          latitude.abs() > 90 ||
          longitude.abs() > 180)
        return;
      if (!streamController.isClosed) sink(LatLng(latitude, longitude));
    });
    socket!.connect();
  }

  bool connected() => socket?.connected ?? false;

  void disposeStreams() {
    close();
    unawaited(streamController.close());
    if (identical(_instance, this)) _instance = null;
  }
}
