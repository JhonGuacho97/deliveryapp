import 'dart:async';

import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/constants/status_constant.dart';
import 'package:planck/constants/types_constant.dart';
import 'package:planck/src/bloc/socket_bloc.dart';
import 'package:planck/src/common/map_helper.dart';
import 'package:planck/src/models/order_model.dart';
import 'package:planck/src/provider/push_provider.dart';
import 'package:planck/src/services/market_service.dart';

class OrderController extends ChangeNotifier {
  final MarketService marketService;
  final bool mapsEnabled;

  final Map<MarkerId, Marker> _markers = {};
  final MarkerId markerIdStore = const MarkerId('store');
  final MarkerId markerIdClient = const MarkerId('client');
  final MarkerId markerIdDeliveryMan = const MarkerId('deliveryman');
  late OrderModel _order;
  // An order view owns its transport; closing it must not stop rider tracking.
  final SocketBloc _socketBloc;
  StreamSubscription<LatLng>? _positionSubscription;
  StreamSubscription<Map<String, dynamic>>? _pushSubscription;
  bool _disposed = false;
  bool _refreshing = false;
  int? _trackedDeliveryId;
  int _trackingGeneration = 0;
  LatLng? courierPosition;
  Timer? _refreshTimer;

  GoogleMapController? _mapController;
  late CameraPosition initialCameraPosition;

  OrderController(
    OrderModel order, {
    MarketService? market,
    SocketBloc? socket,
    Stream<Map<String, dynamic>>? notifications,
    this.mapsEnabled = kOrderMapEnabled,
    Duration? refreshInterval = const Duration(seconds: 15),
  }) : marketService = market ?? MarketService(),
       _socketBloc = socket ?? SocketBloc.connection() {
    initialCameraPosition = CameraPosition(
      target: LatLng(order.location.x, order.location.y),
      zoom: 16,
    );

    // Clone the object, avoiding duplicate increases in the number of messages received.
    // Tab2Controller _pushProvider AND OrderController _pushProvider
    _order = OrderModel.fromJson(order.toJson());

    addMarkers();
    unawaited(onListenerPositions());

    _pushSubscription = (notifications ?? PushProvider().notifications).listen(
      evaluateNotification,
    );
    if (refreshInterval != null) {
      _refreshTimer = Timer.periodic(refreshInterval, (_) {
        if (orderIsActive) unawaited(refreshOrder());
      });
    }
  }

  bool get orderIsActive =>
      order.status == StatusOrder.started ||
      order.status == StatusOrder.assigned ||
      order.status == StatusOrder.taken;
  bool get isTrackingDelivery =>
      (order.status == StatusOrder.assigned ||
          order.status == StatusOrder.taken) &&
      (order.deliveryman?.id ?? 0) > 0;

  evaluateNotification(Map<String, dynamic> notification) async {
    if (_disposed) return;
    if (order.id.toString() == notification['orderId']) {
      switch (notification['type']) {
        case TypesNotification.changeOrderStatust:
          refreshOrder();
          break;
        case TypesNotification.messageChat:
          order.notificationsClient++;
          notifyListeners();
          break;
        default:
      }
    }
  }

  qualify() async {
    await marketService.qualify(order);
  }

  Future<void> refreshOrder() async {
    if (_disposed || _refreshing) return;
    _refreshing = true;
    try {
      final updated = await marketService.getOrder(order);
      if (_disposed) return;
      order = updated;
      await onListenerPositions();
    } catch (_) {
      // Keep the last known order during a temporary network failure.
    } finally {
      _refreshing = false;
    }
  }

  cleanNotificationsClient() {
    order.notificationsClient = 0;
    notifyListeners();
  }

  OrderModel get order => _order;

  set order(OrderModel order) {
    _order = order;
    if (!orderIsActive) _refreshTimer?.cancel();
    notifyListeners();
  }

  Future<void> centerMap() async {
    final controller = _mapController;
    if (_disposed || controller == null) return;
    final from = courierPosition ?? LatLng(order.start.x, order.start.y);
    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          MapHelper().latLngBounds(
            order.location.x,
            order.location.y,
            from.latitude,
            from.longitude,
          ),
          130.0,
        ),
      );
    } catch (_) {
      // The native map may have been removed while the camera was moving.
    }
  }

  void addMarkers() {
    addMarker(
      markerIdStore,
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      LatLng(order.start.x, order.start.y),
    );
    addMarker(
      markerIdClient,
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      LatLng(order.location.x, order.location.y),
    );
  }

  Set<Marker> get markers => _markers.values.toSet();

  void onMapCreated(GoogleMapController controller) {
    if (_disposed) return;
    _mapController = controller;
    unawaited(centerMap());
  }

  Future<void> onListenerPositions() async {
    final deliveryId = isTrackingDelivery ? order.deliveryman!.id : null;
    if (_disposed || deliveryId == _trackedDeliveryId) return;
    final generation = ++_trackingGeneration;
    _trackedDeliveryId = deliveryId;
    await _positionSubscription?.cancel();
    if (_disposed || generation != _trackingGeneration) return;
    _socketBloc.close();
    courierPosition = null;
    _markers.remove(markerIdDeliveryMan);
    if (deliveryId != null) {
      _positionSubscription = _socketBloc.stream.listen((position) {
        if (generation == _trackingGeneration &&
            deliveryId == _trackedDeliveryId) {
          updateLocationDeliveryMan(position);
        }
      });
      _socketBloc.connect(deliveryId);
    }
    if (!_disposed) notifyListeners();
  }

  addMarker(MarkerId markerId, BitmapDescriptor icon, LatLng position) {
    final market = Marker(markerId: markerId, icon: icon, position: position);
    _markers[markerId] = market;
  }

  updateLocationDeliveryMan(LatLng position) async {
    if (_disposed || !isTrackingDelivery) return;
    final previous = _markers[markerIdDeliveryMan];
    courierPosition = position;
    final rotation = previous == null
        ? 0.0
        : Geolocator.bearingBetween(
            previous.position.latitude,
            previous.position.longitude,
            position.latitude,
            position.longitude,
          );

    final market = Marker(
      markerId: markerIdDeliveryMan,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      position: position,
      rotation: rotation,
    );
    _markers[markerIdDeliveryMan] = market;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _trackingGeneration++;
    _refreshTimer?.cancel();
    unawaited(_positionSubscription?.cancel());
    unawaited(_pushSubscription?.cancel());
    _socketBloc.disposeStreams();
    super.dispose();
  }
}
