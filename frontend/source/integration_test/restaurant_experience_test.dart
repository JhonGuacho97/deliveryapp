import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:planck/constants/code_error_constant.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/constants/preparation_status.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/manager/requests/requests_controller.dart';
import 'package:planck/src/screens/manager/requests/requests_screen.dart';
import 'package:planck/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/support/restaurant_fixtures.dart';
import 'support/liquid_navigation_gestures.dart';

class _Controller extends RequestsController {
  _Controller(RestaurantRequestsFixture service)
    : super(
        service: service,
        notifications: const Stream.empty(),
        loadOnCreate: false,
      );
  @override
  Future<int> checkSession() async => CodeError.none;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android restaurant accepts, prepares, edits the menu and updates opening hours',
    (tester) async {
      expect(kExternalServicesEnabled, isFalse);
      final preferences = PreferencesProvider();
      await preferences.init();
      final nativePreferences = preferences.preferences;
      SharedPreferences.setMockInitialValues({
        'userId': 900002,
        'fullName': 'Restaurante de prueba',
        'email': 'restaurante@example.test',
        'roles': ['manager'],
        'token': 'ui-fixture',
      });
      await preferences.init();
      await S.load(const Locale('es'));
      final orders = RestaurantRequestsFixture();
      final stores = RestaurantStoreFixture();
      final controller = _Controller(orders);
      await controller.loadRequests();
      Future<void> capture(String name) async {
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        await binding.takeScreenshot(name);
      }

      try {
        await tester.pumpWidget(
          ChangeNotifierProvider<RequestsController>.value(
            value: controller,
            child: Builder(
              builder: (context) => MaterialApp(
                debugShowCheckedModeBanner: false,
                locale: const Locale('es'),
                supportedLocales: S.delegate.supportedLocales,
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: lightThemeData(context),
                darkTheme: darkThemeData(context),
                home: RequestsScreen(storeService: stores),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await reviewLiquidNavigation(
          tester,
          binding,
          selectedIndex: () => controller.currentScreen,
          role: 'restaurant',
        );
        expect(find.text('Sin cebolla en un bowl.'), findsOneWidget);
        await capture('ui-restaurant-new');
        await tester.ensureVisible(find.byKey(const ValueKey('accept-1024')));
        await tester.tap(find.byKey(const ValueKey('accept-1024')));
        await tester.pumpAndSettle();
        expect(orders.accepts, 1);
        final preparing = find.text('En preparación · 1');
        await tester.ensureVisible(preparing);
        await tester.tap(preparing);
        await tester.pumpAndSettle();
        expect(
          controller.requests.single.preparationStatus,
          PreparationStatus.preparing,
        );
        await capture('ui-restaurant-preparing');
        await tester.ensureVisible(find.byKey(const ValueKey('ready-1024')));
        await tester.tap(find.byKey(const ValueKey('ready-1024')));
        await tester.pumpAndSettle();
        final ready = find.text('Listos · 1');
        await tester.ensureVisible(ready);
        await tester.tap(ready);
        await tester.pumpAndSettle();
        expect(orders.readies, 1);
        await capture('ui-restaurant-ready');
        await tester.tap(find.text('Ver detalle'));
        await tester.pumpAndSettle();
        expect(find.text('Cliente de prueba'), findsOneWidget);
        await capture('ui-restaurant-detail');
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Menú').last);
        await tester.pumpAndSettle();
        await capture('ui-restaurant-menu');
        await tester.tap(find.byKey(const ValueKey('menu-product-1')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('product-price')),
          '7.25',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await capture('ui-restaurant-editor');
        await tester.tap(find.byKey(const ValueKey('save-menu-product')));
        await tester.pumpAndSettle();
        expect(stores.products.first.price, 7.25);
        expect(find.text('7.25 USD'), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('new-menu-product')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('product-name')),
          'Bowl de vegetales',
        );
        await tester.enterText(
          find.byKey(const ValueKey('product-description')),
          'Vegetales frescos preparados al momento.',
        );
        await tester.enterText(
          find.byKey(const ValueKey('product-price')),
          '6.00',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('save-menu-product')));
        await tester.pumpAndSettle();
        expect(stores.products.length, 2);
        expect(find.text('Bowl de vegetales'), findsOneWidget);
        await tester.tap(find.text('Negocio').last);
        await tester.pumpAndSettle();
        await capture('ui-restaurant-business');
        await tester.tap(find.text('Horarios de atención'));
        await tester.pumpAndSettle();
        await capture('ui-restaurant-hours');
        await tester.tap(find.text('08:00'));
        await tester.pumpAndSettle();
        final fields = find.descendant(
          of: find.byType(TimePickerDialog),
          matching: find.byType(TextField),
        );
        await tester.enterText(fields.first, '9');
        await tester.enterText(fields.last, '30');
        final ok = MaterialLocalizations.of(
          tester.element(find.byType(TimePickerDialog)),
        ).okButtonLabel;
        await tester.tap(find.text(ok).last);
        await tester.pumpAndSettle();
        expect(stores.hours.first.open, '09:30:00');
        expect(find.text('09:30'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        controller.dispose();
        preferences.preferences = nativePreferences;
      }
    },
  );
}
