import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planck/src/models/market_products_response.dart';
import 'package:planck/src/models/product_model.dart';
import 'package:planck/src/provider/db_provider.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/main/tab1_controller.dart';
import 'package:planck/src/screens/store/store_controller.dart';
import 'package:planck/src/screens/store/store_screen.dart';
import 'package:planck/src/widgets/catalog_product_tile.dart';
import 'package:planck/src/widgets/icon_cart/icon_cart_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../support/form_fixtures.dart';
import '../support/storefront_fixtures.dart';

class _Cart extends IconCartController {
  @override
  Future<void> count() async {}
}

class _CartDatabase extends DBProvider {
  final rows = <ProductModel>[];
  @override
  Future<int> createProduct(
    ProductModel product,
    int companyType, {
    double lt = 0,
    double lg = 0,
  }) async {
    rows.add(product);
    return 1;
  }

  @override
  Future<int> deleteProduct(ProductModel product) async {
    rows.removeWhere((row) => row.id == product.id);
    return 1;
  }
}

class _SlowMarket extends StorefrontMarket {
  final first = Completer<MarketProductsResponse>();
  @override
  Future<MarketProductsResponse> getProducts(int companyId, int groupId) =>
      companyId == 1 ? first.future : super.getProducts(companyId, groupId);
}

void main() {
  late DBProvider database;
  late StorefrontMarket market;
  late StoreController menu;
  setUpAll(sqfliteFfiInit);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesProvider().init();
    database = DBProvider(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    market = StorefrontMarket();
    menu = StoreController(market: market, database: database);
    await menu.openCompany(storefrontCompany());
  });
  tearDown(() async {
    menu.dispose();
    await database.close();
  });

  test(
    'menu search ignores accents and combines with the real price filter',
    () {
      final calls = market.requests;
      menu.search('MARGÁRITA');
      expect(menu.visibleProducts.single.id, 101);
      menu.priceFilter = MenuPriceFilter.upToFive;
      expect(menu.visibleProducts, isEmpty);
      menu.search('');
      expect(menu.visibleProducts.map((p) => p.id), [103, 104]);
      menu.clearFilters();
      expect(menu.visibleProducts, hasLength(6));
      expect(
        market.requests,
        calls,
        reason: 'Menu filtering should be immediate',
      );
    },
  );
  test('an older restaurant response cannot overwrite the next menu', () async {
    final slow = _SlowMarket();
    final controller = StoreController(market: slow, database: database);
    final first = controller.openCompany(storefrontCompany());
    await controller.openCompany(storefrontCompany(id: 2));
    slow.first.complete(
      MarketProductsResponse(
        groups: [],
        products: [storefrontDish(999, 'Respuesta anterior', 1)],
      ),
    );
    await first;
    expect(controller.company.id, 2);
    expect(controller.products.any((p) => p.id == 999), isFalse);
    controller.dispose();
  });
  test('failed refresh keeps the last menu and allows retry', () async {
    market.fail = true;
    await menu.loadProducts();
    expect(menu.hasError, isTrue);
    expect(menu.products, hasLength(6));
    market.fail = false;
    await menu.loadProducts();
    expect(menu.hasError, isFalse);
  });

  Future<void> pump(
    WidgetTester tester, {
    bool dark = false,
    double scale = 1.3,
    Widget? body,
  }) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StoreController>.value(value: menu),
          ChangeNotifierProvider<Tab1Controller>(
            create: (_) => Tab1Controller(
              market: market,
              database: database,
              loadOnCreate: false,
            ),
          ),
          ChangeNotifierProvider<IconCartController>(create: (_) => _Cart()),
        ],
        child: formReviewApp(
          body ?? StoreScreen(storefrontCompany()),
          dark: dark,
          scale: scale,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    testWidgets(
      'cover, sticky search and menu fit 320 px and large text: $dark',
      (tester) async {
        await pump(tester, dark: dark);
        expect(find.text('La Esquina · Pizzería Demo'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Buscar en el menú'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(TextField));
        await tester.enterText(find.byType(TextField), 'pepperoni');
        await tester.pumpAndSettle();
        expect(menu.visibleProducts.single.id, 102);
        expect(find.text('Pizza pepperoni'), findsOneWidget);
        await tester.ensureVisible(find.text('Pizza pepperoni'));
        await tester.tap(find.byKey(const ValueKey('dish-detail-102')));
        await tester.pumpAndSettle();
        expect(find.text('Detalle del plato'), findsOneWidget);
        expect(find.text(market.dishes[1].description), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('menu reflows to a single column at 200 percent text', (
    tester,
  ) async {
    await pump(tester, scale: 2);
    await tester.tap(find.byTooltip('Buscar en el menú'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Pan de ajo');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('dish-detail-104')));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'photo detail adds and removes the dish without duplicate writes',
    (tester) async {
      final product = market.dishes[1];
      final cartDatabase = _CartDatabase();
      await pump(
        tester,
        scale: 1,
        body: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 310,
              child: CatalogProductTile(
                product: product,
                database: cartDatabase,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('dish-detail-102')));
      await tester.pumpAndSettle();
      final action = find.byKey(const ValueKey('dish-detail-cart-102'));
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.tap(action, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(cartDatabase.rows, hasLength(1));
      expect(product.isInCart, isTrue);
      await tester.tap(find.byKey(const ValueKey('cart-product-102')));
      await tester.pumpAndSettle();
      expect(cartDatabase.rows, isEmpty);
      expect(product.isInCart, isFalse);
    },
  );
}
