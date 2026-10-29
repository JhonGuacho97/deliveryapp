import 'package:planck/constants/status_constant.dart';
import 'package:planck/src/bloc/socket_bloc.dart';
import 'package:planck/src/models/order_model.dart';
import 'package:planck/src/services/market_service.dart';

OrderModel trackingOrder({
  int status = StatusOrder.assigned,
  int? riderId = 7,
}) => OrderModel.fromJson({
  'id': 900001,
  'note': '',
  'address': 'Calle Bolívar · Loja',
  'status': status,
  'products': [],
  'deliveryFee': 1.5,
  'total': 9.5,
  'start': {'x': -4.023, 'y': -79.198},
  'location': {'x': -4.025, 'y': -79.195},
  'createdAt': '2026-10-28T12:00:00Z',
  'store': {
    'id': 1,
    'name': 'La Esquina',
    'address': 'Centro',
    'company': {'image': '', 'marker': '', 'type': 10},
  },
  'notificationsClient': 0,
  'payment': 5001,
  'deliveryman': riderId == null
      ? null
      : {'id': riderId, 'fullName': 'Motorizado de prueba', 'image': ''},
});

class TrackingSocketFixture extends SocketBloc {
  TrackingSocketFixture() : super.connection();
  final connectedRiders = <int>[];
  int closes = 0;
  @override
  void connect(int idUserDeliveryMen) => connectedRiders.add(idUserDeliveryMen);
  @override
  void close() {
    closes++;
    super.close();
  }
}

class TrackingMarketFixture extends MarketService {
  TrackingMarketFixture(this.next);
  OrderModel next;
  int reads = 0;
  bool fail = false;
  @override
  Future<OrderModel> getOrder(OrderModel order) async {
    reads++;
    if (fail) throw StateError('Offline');
    return next;
  }
}
