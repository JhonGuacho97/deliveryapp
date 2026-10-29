import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';
import 'package:delivery_app/src/screens/deliveryman/petitions/petitions_screen.dart';

import '../test/support/courier_fixtures.dart';
import '../test/courier/courier_test.dart' show courierApp;
import 'support/liquid_navigation_gestures.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'courier availability, preparation gate, pickup, delivery and earnings on Android',
    (tester) async {
      final preferences = PreferencesProvider();
      await preferences.init();
      final native = preferences.preferences;
      SharedPreferences.setMockInitialValues({
        'userId': 900003,
        'fullName': 'Motorizado de prueba',
        'email': 'motorizado@example.test',
        'roles': ['deliveryman'],
        'token': 'ui-fixture',
      });
      await preferences.init();
      // Keep this fixture independent of the installed native session.
      final service = CourierFixture(), location = CourierLocationFixture();
      final controller = CourierControllerFixture(service, location);
      Future<void> capture(String name) async {
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        await binding.takeScreenshot(name);
      }

      try {
        await controller.loadPetitions();
        await courierApp(tester, controller);
        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await reviewLiquidNavigation(
          tester,
          binding,
          selectedIndex: () => controller.currentScreen,
          role: 'courier',
        );
        await capture('ui-courier-offline');
        await tester.tap(find.byKey(const ValueKey('courier-availability')));
        await tester.pumpAndSettle();
        expect(controller.isOnline, isTrue);
        await capture('ui-courier-offers');
        await tester.tap(find.byKey(const ValueKey('delivery-2048')));
        await tester.pumpAndSettle();
        await capture('ui-courier-offer-detail');
        service.records.first.preparationStatus = 'preparing';
        await tester.tap(find.byKey(const ValueKey('courier-primary')));
        await tester.pumpAndSettle();
        final collect = tester.widget<FilledButton>(
          find.byKey(const ValueKey('courier-primary')),
        );
        expect(collect.onPressed, isNull);
        expect(
          find.text('El restaurante está preparando el pedido.'),
          findsWidgets,
        );
        await capture('ui-courier-preparing');
        service.records.first.preparationStatus = 'ready';
        await controller.refreshDelivery(service.records.first);
        await tester.pumpAndSettle();
        await capture('ui-courier-pickup');
        await tester.tap(find.byKey(const ValueKey('courier-primary')));
        await tester.pumpAndSettle();
        expect(find.text('Confirmar entrega'), findsOneWidget);
        await capture('ui-courier-on-way');
        await tester.tap(find.byKey(const ValueKey('courier-primary')));
        await tester.pumpAndSettle();
        expect(find.text('¿Completaste la entrega?'), findsOneWidget);
        await capture('ui-courier-confirm');
        await tester.tap(
          find.widgetWithText(FilledButton, 'Confirmar entrega').last,
        );
        await tester.pumpAndSettle();
        expect(find.text('Entrega completada'), findsOneWidget);
        expect(service.mutations, 3);
        await capture('ui-courier-completed');
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ingresos').last);
        await tester.pumpAndSettle();
        expect(controller.earnings!.earnings, 1.28);
        expect(controller.earnings!.completedCount, 1);
        await capture('ui-courier-earnings');
        await tester.tap(find.text('Cuenta').last);
        await tester.pumpAndSettle();
        await capture('ui-courier-account');
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Entregas').last);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('courier-availability')));
        await tester.pumpAndSettle();
        expect(controller.isOnline, isFalse);
        expect(location.running, isFalse);
        expect(find.byType(PetitionsScreen), findsOneWidget);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
        preferences.preferences = native;
      }
    },
  );
}
