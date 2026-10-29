import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:delivery_app/constants/status_constant.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/order/order_controller.dart';
import 'package:delivery_app/src/screens/order/widget/content_order.dart';

import '../support/form_fixtures.dart';
import '../support/tracking_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Future<void> tick() => Future<void>.delayed(Duration.zero);

  test('tracking receives real positions with maps and Firebase disabled, without a fake initial location', () async {
    final socket = TrackingSocketFixture(), order = trackingOrder();
    final controller = OrderController(
      order,
      socket: socket,
      mapsEnabled: false,
      notifications: const Stream.empty(),
      refreshInterval: null,
    );
    addTearDown(controller.dispose);
    await tick();
    expect(socket.connectedRiders, [7]);
    expect(controller.courierPosition, isNull);
    expect(
      controller.markers.any((m) => m.markerId.value == 'deliveryman'),
      isFalse,
    );
    socket.sink(const LatLng(-4.024, -79.197));
    await tick();
    expect(controller.courierPosition, const LatLng(-4.024, -79.197));
    expect(
      controller.markers
          .singleWhere((m) => m.markerId.value == 'deliveryman')
          .position,
      controller.courierPosition,
    );
    await controller.centerMap().timeout(const Duration(milliseconds: 100));
  });

  test(
    'refresh keeps the socket alive and stops tracking after delivery',
    () async {
      final socket = TrackingSocketFixture(),
          market = TrackingMarketFixture(trackingOrder());
      final controller = OrderController(
        trackingOrder(),
        socket: socket,
        market: market,
        notifications: const Stream.empty(),
        refreshInterval: null,
      );
      addTearDown(controller.dispose);
      await tick();
      await controller.refreshOrder();
      expect(socket.connectedRiders, [7]);
      market.next = trackingOrder(riderId: 8);
      await controller.refreshOrder();
      expect(socket.connectedRiders, [7, 8]);
      socket.sink(const LatLng(-4.024, -79.196));
      await tick();
      expect(controller.courierPosition, isNotNull);
      market.next = trackingOrder(status: StatusOrder.delivered, riderId: 8);
      await controller.refreshOrder();
      expect(controller.courierPosition, isNull);
      socket.sink(const LatLng(-4.025, -79.195));
      await tick();
      expect(controller.courierPosition, isNull);
      expect(controller.isTrackingDelivery, isFalse);
    },
  );

  testWidgets(
    'polling discovers the courier assignment without push notifications and tolerates network failure',
    (tester) async {
      final socket = TrackingSocketFixture(),
          market = TrackingMarketFixture(trackingOrder());
      final controller = OrderController(
        trackingOrder(status: StatusOrder.started, riderId: null),
        socket: socket,
        market: market,
        notifications: const Stream.empty(),
      );
      addTearDown(() {
        if (!socket.streamController.isClosed) controller.dispose();
      });
      expect(socket.connectedRiders, isEmpty);
      await tester.pump(const Duration(seconds: 15));
      await tester.pump();
      expect(controller.isTrackingDelivery, isTrue);
      expect(socket.connectedRiders, [7]);
      market.fail = true;
      await tester.pump(const Duration(seconds: 15));
      await tester.pump();
      expect(controller.order.status, StatusOrder.assigned);
      expect(socket.connectedRiders, [7]);
      controller.dispose();
      final reads = market.reads;
      await tester.pump(const Duration(seconds: 30));
      expect(market.reads, reads);
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'the map fallback explains availability and keeps order progress ($dark)',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = OrderController(
          trackingOrder(),
          socket: TrackingSocketFixture(),
          mapsEnabled: false,
          notifications: const Stream.empty(),
          refreshInterval: null,
        );
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          formReviewApp(
            Scaffold(body: ContentOrder(controller)),
            dark: dark,
            scale: 1.3,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(S.current.trackingMapUnavailable), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
