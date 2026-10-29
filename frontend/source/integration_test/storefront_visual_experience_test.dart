import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/models/address_model.dart' as addresses;
import 'package:planck/src/models/dropdown_option.dart';
import 'package:planck/src/provider/db_provider.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/main/tab1_controller.dart';
import 'package:planck/src/screens/main/tab2_controller.dart';
import 'package:planck/src/screens/main/tab_main_controller.dart';
import 'package:planck/src/screens/main/tab_main_screen.dart';
import 'package:planck/src/screens/main/widget/list_company.dart';
import 'package:planck/src/screens/store/store_controller.dart';
import 'package:planck/src/screens/store/store_screen.dart';
import 'package:planck/src/widgets/address_dropdown/address_dropdown_controller.dart';
import 'package:planck/src/widgets/icon_cart/icon_cart_controller.dart';
import 'package:planck/theme.dart';
import 'package:provider/provider.dart';

// Catalog and menu requests use the real public NestJS endpoints. Session checks
// are isolated so this visual review cannot log out the installed native user.
class _Session extends TabManController {
  @override
  Future<int> checkSession() async => 0;
}

class _Address extends ChangeNotifier implements AddressDropdownController {
  @override
  DropdownOption get dropdown =>
      DropdownOption(name: 'Centro · Loja', value: '900001');
  @override
  bool get inAsyncCall => false;
  @override
  Future<void> loadAddress() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native catalog photos, restaurant menu, search, details and cart',
    (tester) async {
      binding.testTextInput.register();
      addTearDown(binding.testTextInput.unregister);
      await LiquidGlassWidgets.initialize(enablePerformanceMonitor: false);
      await PreferencesProvider().init();
      final db = DBProvider.db;
      final savedAddress = await db.loadAddress(),
          savedCart = await db.loadProducts(10);
      final mode = ValueNotifier(ThemeMode.light);
      final catalog = Tab1Controller(loadOnCreate: false);
      final store = StoreController();
      Future<void> waitFor(bool Function() done) async {
        for (var attempt = 0; attempt < 60 && !done(); attempt++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 250)),
          );
          await tester.pump();
        }
        expect(done(), isTrue);
        await tester.pumpAndSettle();
      }

      Future<void> capture(String name) async {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(seconds: 2)),
        );
        await tester.pumpAndSettle();
        await binding.takeScreenshot(name);
      }

      try {
        if (savedAddress == null)
          await db.createAddress(
            addresses.AddressModel(
              id: 900001,
              alias: 'Centro · Loja',
              address: 'Dirección de demostración',
              location: addresses.Location(x: klatitudeMap, y: klongitudeMap),
            ),
          );
        await catalog.load();
        expect(catalog.hasError, isFalse);
        expect(catalog.companies.length, greaterThanOrEqualTo(5));
        final pizza = catalog.companies.firstWhere(
          (c) => c.name.contains('La Esquina'),
        );
        expect(pizza.image, isNotEmpty);
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<Tab1Controller>.value(value: catalog),
              ChangeNotifierProvider<StoreController>.value(value: store),
              ChangeNotifierProvider<Tab2Controller>(
                create: (_) => Tab2Controller(
                  notifications: const Stream.empty(),
                  loadOnCreate: false,
                ),
              ),
              ChangeNotifierProvider<TabManController>(
                create: (_) => _Session(),
              ),
              ChangeNotifierProvider<AddressDropdownController>(
                create: (_) => _Address(),
              ),
              ChangeNotifierProvider<IconCartController>(
                create: (_) => IconCartController(),
              ),
            ],
            child: Builder(
              builder: (context) => ValueListenableBuilder(
                valueListenable: mode,
                builder: (context, value, _) => MaterialApp(
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
                  themeMode: value,
                  home: const TabMainScreen(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(seconds: 4)),
        );
        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await capture('ui-storefront-home');
        final vertical = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.byType(ListCompany),
          200,
          scrollable: vertical,
        );
        await tester.drag(vertical, const Offset(0, -120));
        await tester.pumpAndSettle();
        await capture('ui-storefront-restaurants');
        final card = find.byKey(ValueKey('restaurant-${pizza.storeId}'));
        final carousel = find.descendant(
          of: find.byType(ListCompany),
          matching: find.byType(Scrollable),
        );
        await tester.scrollUntilVisible(card, 180, scrollable: carousel);
        await tester.ensureVisible(card);
        await tester.pumpAndSettle();
        await tester.tap(card);
        await tester.pumpAndSettle();
        if (find.byType(StoreScreen).evaluate().isEmpty) {
          await tester.tap(find.text(S.current.bAccept).last);
          await tester.pumpAndSettle();
        }
        await waitFor(() => store.hasCompany && !store.inAsyncCall);
        expect(store.hasError, isFalse);
        expect(store.products, hasLength(6));
        expect(store.products.every((p) => p.image.isNotEmpty), isTrue);
        await capture('ui-storefront-restaurant-cover');
        await tester.tap(find.byTooltip('Buscar en el menú'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'pepperoni');
        await tester.pumpAndSettle();
        expect(store.visibleProducts.single.name, contains('pepperoni'));
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await capture('ui-storefront-menu-search');
        await tester.tap(find.byTooltip(S.current.clearSearch));
        await tester.pumpAndSettle();
        await tester.tap(find.text(S.current.menuUpTo('5 $kCoin')));
        await tester.pumpAndSettle();
        expect(store.visibleProducts, hasLength(2));
        expect(store.visibleProducts.every((p) => p.price <= 5), isTrue);
        await capture('ui-storefront-menu-price-filter');
        await tester.tap(find.text(S.current.fullMenu));
        await tester.pumpAndSettle();
        await capture('ui-storefront-menu-grid');
        final dish = store.visibleProducts.first;
        final detail = find.byKey(ValueKey('dish-detail-${dish.id}'));
        await tester.ensureVisible(detail);
        await tester.pumpAndSettle();
        await tester.tap(detail);
        await tester.pumpAndSettle();
        expect(find.text(S.current.dishDetails), findsOneWidget);
        await capture('ui-storefront-dish-detail');
        final wasInCart = dish.isInCart;
        final add = find.byKey(ValueKey('dish-detail-cart-${dish.id}'));
        await tester.ensureVisible(add);
        await tester.pumpAndSettle();
        await tester.tap(add);
        await tester.pumpAndSettle();
        expect(dish.isInCart, !wasInCart);
        expect(
          (await db.loadProducts(10)).any((p) => p.id == dish.id),
          !wasInCart,
        );
        await capture('ui-storefront-menu-cart');
        mode.value = ThemeMode.dark;
        await tester.pumpAndSettle();
        await capture('ui-storefront-menu-dark');
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        catalog.dispose();
        store.dispose();
        mode.dispose();
        await db.deleteAllProduct(10);
        for (final item in savedCart) await db.createProduct(item, 10);
        if (savedAddress == null) await db.deleteAddress();
      }
    },
  );
}
