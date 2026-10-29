import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:delivery_app/constants/code_error_constant.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/constants/types_constant.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/models/address_model.dart' as address;
import 'package:delivery_app/src/models/category_model.dart';
import 'package:delivery_app/src/models/dropdown_option.dart';
import 'package:delivery_app/src/models/market_companies_response.dart';
import 'package:delivery_app/src/models/order_model.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:delivery_app/src/provider/db_provider.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';
import 'package:delivery_app/src/screens/main/tab1_controller.dart';
import 'package:delivery_app/src/screens/main/tab2_controller.dart';
import 'package:delivery_app/src/screens/main/tab_main_controller.dart';
import 'package:delivery_app/src/screens/main/tab_main_screen.dart';
import 'package:delivery_app/src/screens/store/store_controller.dart';
import 'package:delivery_app/src/services/market_service.dart';
import 'package:delivery_app/src/services/auth_service.dart';
import 'package:delivery_app/src/widgets/address_dropdown/address_dropdown_controller.dart';
import 'package:delivery_app/src/widgets/icon_cart/icon_cart_controller.dart';
import 'package:delivery_app/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/liquid_navigation_gestures.dart';

class _Session extends TabManController {
  @override
  Future<int> checkSession() async => CodeError.none;
}

class _Address extends ChangeNotifier implements AddressDropdownController {
  @override
  DropdownOption get dropdown =>
      DropdownOption(name: 'Casa · Centro', value: '900001');
  @override
  bool get inAsyncCall => false;
  @override
  Future<void> loadAddress() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProductModel _product(int id, String name) => ProductModel(
  id: id,
  companyId: 900001,
  companyName: 'Casa Verde',
  name: name,
  description: 'Ingredientes frescos, preparados al momento.',
  type: TypesCompany.store,
  price: 6.5,
  image: '',
);
final _order = OrderModel.fromJson({
  'id': 900001,
  'note': '',
  'address': 'Calle Principal 123 · Centro',
  'status': 1,
  'products': [_product(900001, 'Bowl de pollo').toJson()],
  'deliveryFee': 1.5,
  'total': 8.0,
  'start': {'x': -0.2, 'y': -78.5},
  'location': {'x': -0.21, 'y': -78.51},
  'createdAt': '2026-10-28T12:00:00Z',
  'store': {
    'id': 900001,
    'name': 'Casa Verde',
    'address': 'Calle Principal 320',
    'company': {'image': '', 'marker': '', 'type': 10},
  },
  'notificationsClient': 0,
  'payment': TypesPayment.cash,
});

class _Market extends MarketService {
  @override
  Future<List<CategoryModel>> getCategories(double lt, double lg) async => [
    CategoryModel(id: 1, name: 'Casera'),
  ];
  @override
  Future<MarketCompaniesResponse> getCompanies(
    CategoryModel selectedCategory,
    double lt,
    double lg, {
    String filter = '',
  }) async => MarketCompaniesResponse(
    companies: [],
    products:
        [
              _product(900001, 'Bowl de pollo'),
              _product(900002, 'Bowl de vegetales'),
            ]
            .where((p) => p.name.toLowerCase().contains(filter.toLowerCase()))
            .toList(),
  );
  @override
  Future<List<OrderModel>> getOrders({bool throwOnError = false}) async => [
    _order,
  ];
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android customer flow preserves cart quantities and notes and shows real tracking stages',
    (tester) async {
      expect(
        kExternalServicesEnabled,
        isFalse,
        reason: 'Run with config/local-emulator.json',
      );
      final db = DBProvider.db;
      final preferences = PreferencesProvider();
      await preferences.init();
      // Optional local login leaves the normal app ready for review after the test.
      const email = String.fromEnvironment('UI_LOCAL_EMAIL');
      const password = String.fromEnvironment('UI_LOCAL_PASSWORD');
      if (email.isNotEmpty) {
        final user = await AuthService().login(email, password);
        expect(
          user,
          isNotNull,
          reason: 'Local review account must authenticate',
        );
        preferences.user = user!;
        preferences.token = user.token;
        if (user.addresses.isNotEmpty)
          await db.createAddress(user.addresses.first);
      }
      final nativePreferences = preferences.preferences;
      final savedCart = await db.loadProducts(TypesCompany.store);
      final savedAddress = await db.loadAddress();
      // Preference mocks are process-local; native user credentials stay untouched.
      SharedPreferences.setMockInitialValues({
        'userId': 900001,
        'token': 'ui-fixture',
        'fullName': 'Cliente de prueba',
        'email': 'cliente@example.test',
        'roles': ['client'],
      });
      await PreferencesProvider().init();
      await S.load(const Locale('es'));
      await db.deleteAllProduct(TypesCompany.store);
      await db.createAddress(
        address.AddressModel(
          id: 900001,
          alias: 'Casa · Centro',
          address: 'Calle Principal 123',
          location: address.Location(x: -0.2, y: -78.5),
        ),
      );
      final market = _Market();
      final catalog = Tab1Controller(market: market, loadOnCreate: false);
      await catalog.load();
      try {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<Tab1Controller>.value(value: catalog),
              ChangeNotifierProvider<Tab2Controller>(
                create: (_) => Tab2Controller(
                  market: market,
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
              ChangeNotifierProvider<StoreController>(
                create: (_) => StoreController(),
              ),
            ],
            child: Builder(
              builder: (context) => MaterialApp(
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
                home: const TabMainScreen(),
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
          selectedIndex: () => tester
              .element(find.byType(TabMainScreen))
              .read<TabManController>()
              .currentScreen,
          role: 'client',
        );
        await binding.takeScreenshot('ui-client-catalog');
        expect(find.text('Bowl de pollo'), findsOneWidget);
        await tester.enterText(
          find.byKey(const ValueKey('catalog-search')),
          'pollo',
        );
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        expect(find.text('Bowl de vegetales'), findsNothing);
        await tester.tap(find.text('Casera'));
        await tester.pumpAndSettle();
        expect(catalog.query, 'pollo');
        await tester.tap(find.byKey(const ValueKey('cart-product-900001')));
        await tester.pumpAndSettle();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('ui-glass-client-cart');
        await tester.tap(find.byKey(const ValueKey('client-cart-bar')));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Aumentar cantidad'));
        await tester.pumpAndSettle();
        expect(find.text('13.00 USD'), findsNWidgets(2));
        await tester.enterText(
          find.byKey(const ValueKey('note-900001')),
          'Sin cebolla',
        );
        await tester.pumpAndSettle();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        final stored = (await db.loadProducts(TypesCompany.store)).single;
        expect(stored.number, 2);
        expect(stored.note, 'Sin cebolla');
        await binding.takeScreenshot('ui-client-cart');
        await tester.tap(find.byTooltip('Eliminar producto'));
        await tester.pumpAndSettle();
        expect(find.text('Tu carrito está esperando'), findsOneWidget);
        expect(await db.countProducts(TypesCompany.store), 0);
        await tester.tap(find.text('Explorar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pedidos').last);
        await tester.pumpAndSettle();
        expect(find.text('Pedido #900001'), findsOneWidget);
        await binding.takeScreenshot('ui-client-orders');
        await tester.tap(find.text('Pedido #900001'));
        await tester.pumpAndSettle();
        expect(find.text('Estado del pedido'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        await binding.takeScreenshot('ui-client-tracking');
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cuenta').last);
        await tester.pumpAndSettle();
        expect(find.text('Editar perfil'), findsOneWidget);
        await binding.takeScreenshot('ui-client-account');
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        catalog.dispose();
        await db.deleteAllProduct(TypesCompany.store);
        for (final product in savedCart) {
          await db.createProduct(product, TypesCompany.store);
        }
        await db.deleteAddress();
        if (savedAddress != null) await db.createAddress(savedAddress);
        preferences.preferences = nativePreferences;
      }
    },
  );
}
