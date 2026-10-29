import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/main.dart' as application;
import 'package:planck/src/models/address_model.dart' as addresses;
import 'package:planck/src/provider/db_provider.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/services/auth_service.dart';
import 'package:planck/src/services/address_service.dart';
import 'package:planck/src/services/market_service.dart';
import 'package:planck/src/screens/main/tab_main_screen.dart';
import 'package:planck/src/screens/main/tab1_controller.dart';
import 'package:planck/src/screens/store/store_controller.dart';
import 'package:planck/src/screens/store/store_screen.dart';
import 'package:planck/src/screens/login/login_screen.dart';
import 'package:planck/src/screens/main/tab_main_controller.dart';
import 'package:planck/src/screens/main/account_screen.dart';
import 'package:planck/src/screens/profile/profile_screen.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'real client sees the seeded restaurants and menus at the default address',
    (tester) async {
      // Synthetic edits must not race the real Android IME after refocusing.
      binding.testTextInput.register();
      addTearDown(binding.testTextInput.unregister);
      expect(kExternalServicesEnabled, isFalse);
      const email = String.fromEnvironment('UI_LOCAL_EMAIL'),
          password = String.fromEnvironment('UI_LOCAL_PASSWORD');
      expect(email, isNotEmpty);
      final preferences = PreferencesProvider();
      await preferences.init();
      final user = await AuthService().login(email, password);
      expect(user, isNotNull);
      expect(user!.roles, contains('client'));
      expect(user.roles, isNot(contains('admin')));
      preferences.user = user;
      preferences.token = user.token;
      final service = AddressService(), saved = await service.getAdress();
      final matching = saved.where(
        (a) =>
            (a.location.x - klatitudeMap).abs() < 0.00001 &&
            (a.location.y - klongitudeMap).abs() < 0.00001,
      );
      final address = matching.isNotEmpty
          ? matching.first
          : await service.create(
              addresses.AddressModel(
                alias: 'Centro · Prueba local',
                address: 'Dirección predeterminada · Loja',
                location: addresses.Location(x: klatitudeMap, y: klongitudeMap),
              ),
            );
      expect(address, isNotNull);
      await DBProvider.db.createAddress(address!);
      await application.main();
      await tester.pumpAndSettle();
      expect(find.byType(TabMainScreen), findsOneWidget);
      Navigator.of(tester.element(find.byType(TabMainScreen)))
          .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      await tester.pumpAndSettle();
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('ui-auth-signin-modern');
      await tester.tap(find.text(S.current.bSignup).first);
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNWidgets(4));
      await binding.takeScreenshot('ui-auth-signup-modern');
      await tester.tap(find.text(S.current.bSignin).first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, email);
      await tester.enterText(find.byType(TextFormField).last, password);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, S.current.bSignin));
      await tester.runAsync(() async {
        for (
          var i = 0;
          i < 100 && find.byType(LoginScreen).evaluate().isNotEmpty;
          i++
        ) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      });
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TabMainScreen), findsOneWidget);
      final context = tester.element(find.byType(TabMainScreen)),
          catalog = context.read<Tab1Controller>();
      Future<void> waitUntil(bool Function() ready) async {
        for (var i = 0; i < 100 && !ready(); i++) {
          await tester.pump(const Duration(milliseconds: 100));
          await tester.runAsync(() async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
          });
        }
        await tester.pumpAndSettle();
        expect(
          ready(),
          isTrue,
          reason:
              'query=${catalog.query}, loading=${catalog.inAsyncCall}, error=${catalog.hasError}',
        );
      }

      await waitUntil(() => !catalog.inAsyncCall && !catalog.needsAddress);
      expect(catalog.hasError, isFalse);
      expect(catalog.companies.length, greaterThanOrEqualTo(5));
      expect(catalog.companies.every((c) => c.type == 10), isTrue);
      expect(
        catalog.companies.any((c) => c.name == 'Restaurante de prueba'),
        isTrue,
      );
      const demoNames = {
        'Restaurante de prueba',
        'La Esquina · Pizzería Demo',
        'Barrio Burger · Demo',
        'Verde y Fresco · Demo',
        'Café del Parque · Demo',
      };
      final names = catalog.companies.map((c) => c.name).toSet();
      expect(
        names,
        containsAll([
          'La Esquina · Pizzería Demo',
          'Barrio Burger · Demo',
          'Verde y Fresco · Demo',
          'Café del Parque · Demo',
        ]),
      );
      for (final company in catalog.companies.where(
        (c) => demoNames.contains(c.name),
      )) {
        final menu = await tester.runAsync(
          () => MarketService().getProducts(company.id, 0),
        );
        expect(menu!.hasError, isFalse);
        expect(menu.products.length, greaterThanOrEqualTo(6));
      }
      await binding.takeScreenshot('ui-client-local-catalog');
      expect(find.text('lili.'), findsNothing);
      await tester.enterText(find.byType(TextField).first, 'pizz');
      await tester.pump(const Duration(milliseconds: 500));
      await waitUntil(() => !catalog.inAsyncCall && catalog.query == 'pizz');
      expect(catalog.products.length, 4);
      expect(catalog.companies.single.name, 'La Esquina · Pizzería Demo');
      expect(find.text(S.current.matchingDishes), findsOneWidget);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('ui-client-global-pizza-search');
      await tester.enterText(find.byType(TextField).first, 'pepperoni');
      await tester.pump(const Duration(milliseconds: 500));
      await waitUntil(
        () => !catalog.inAsyncCall && catalog.query == 'pepperoni',
      );
      expect(catalog.products.single.name, 'Pizza pepperoni · La Esquina');
      expect(catalog.companies.single.name, 'La Esquina · Pizzería Demo');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('ui-client-global-dish-and-restaurant');
      await tester.enterText(
        find.byType(TextField).first,
        'Restaurante de prueba',
      );
      await tester.pump(const Duration(milliseconds: 500));
      await waitUntil(
        () => !catalog.inAsyncCall && catalog.query == 'Restaurante de prueba',
      );
      expect(catalog.companies.single.name, 'Restaurante de prueba');
      await binding.takeScreenshot('ui-client-local-restaurant');
      await tester.ensureVisible(find.text('Restaurante de prueba').last);
      await tester.tap(find.text('Restaurante de prueba').last);
      await tester.pumpAndSettle();
      // A deliberately closed business still allows viewing its menu.
      if (find.byType(StoreScreen).evaluate().isEmpty) {
        final s = S.of(tester.element(find.byType(TabMainScreen)));
        await tester.tap(find.text(s.bAccept).last);
        await tester.pumpAndSettle();
      }
      expect(find.byType(StoreScreen), findsOneWidget);
      final store = tester
          .element(find.byType(StoreScreen))
          .read<StoreController>();
      await waitUntil(
        () =>
            !store.inAsyncCall &&
            (!store.company.isOpen || store.hasDeliveryFee),
      );
      expect(store.hasError, isFalse);
      expect(store.products.length, greaterThanOrEqualTo(6));
      expect(find.text('Bowl de pollo · Prueba local'), findsOneWidget);
      if (store.company.isOpen) expect(store.deliveryFee, closeTo(1.25, 0.02));
      await binding.takeScreenshot('ui-client-local-menu');
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pump(const Duration(milliseconds: 500));
      await waitUntil(() => !catalog.inAsyncCall);
      final tabs = tester
          .element(find.byType(TabMainScreen))
          .read<TabManController>();
      tabs.currentScreen = 2;
      await tester.pumpAndSettle();
      expect(find.byType(AccountScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('catalog-search')), findsNothing);
      await tester.tap(find.text(S.current.editProfile));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      await tester.tap(find.byTooltip(S.current.signOut));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(FilledButton, S.current.signOut),
        findsOneWidget,
      );
      await binding.takeScreenshot('ui-profile-logout-readable');
      await tester.tap(find.text(S.current.bCancel));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      tabs.currentScreen = 0;
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
