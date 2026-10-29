import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';
import 'package:delivery_app/src/screens/login/login_screen.dart';
import 'package:delivery_app/src/screens/order/order_controller.dart';
import 'package:delivery_app/src/screens/order/widget/content_order.dart';
import 'package:delivery_app/src/screens/welcome/welcome_screen.dart';

import '../test/support/form_fixtures.dart';
import '../test/support/tracking_fixtures.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native tracking map works independently of Firebase and welcome opens access',
    (tester) async {
      await PreferencesProvider().init();
      final socket = TrackingSocketFixture();
      final controller = OrderController(
        trackingOrder(),
        socket: socket,
        notifications: const Stream.empty(),
        mapsEnabled: true,
        refreshInterval: null,
      );
      await tester.pumpWidget(
        formReviewApp(
          Scaffold(
            appBar: AppBar(title: const Text('La Esquina')),
            body: ListenableBuilder(
              listenable: controller,
              builder: (_, _) => ContentOrder(controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 10)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GoogleMap), findsOneWidget);
      expect(socket.connectedRiders, [7]);
      expect(controller.courierPosition, isNull);
      socket.sink(const LatLng(-4.024, -79.197));
      await tester.pumpAndSettle();
      expect(controller.courierPosition, const LatLng(-4.024, -79.197));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 1)),
      );
      await tester.pumpAndSettle();
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('ui-tracking-map-independent');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      controller.dispose();
      await tester.pumpWidget(formReviewApp(const WelcomeScreen()));
      await tester.pumpAndSettle();
      await binding.takeScreenshot('ui-welcome-minimal');
      await tester.ensureVisible(find.byKey(const ValueKey('welcome-access')));
      await tester.tap(find.byKey(const ValueKey('welcome-access')));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      await tester.tap(find.byType(BackButton).first);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(formReviewApp(const WelcomeScreen(), dark: true));
      await tester.pumpAndSettle();
      await binding.takeScreenshot('ui-welcome-minimal-dark');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
