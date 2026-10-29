import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_app/constants/status_constant.dart';
import 'package:delivery_app/constants/types_constant.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/models/cart_summary_model.dart';
import 'package:delivery_app/src/models/dropdown_option.dart';
import 'package:delivery_app/src/models/fee_model.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:delivery_app/src/models/order_model.dart';
import 'package:delivery_app/src/provider/db_provider.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';
import 'package:delivery_app/src/screens/cart_summary/widget/details_products.dart';
import 'package:delivery_app/src/screens/main/tab1_controller.dart';
import 'package:delivery_app/src/screens/main/tab1_screen.dart';
import 'package:delivery_app/src/screens/main/tab2_controller.dart';
import 'package:delivery_app/src/screens/main/tab_main_controller.dart';
import 'package:delivery_app/src/screens/main/tab_main_screen.dart';
import 'package:delivery_app/src/screens/order/widget/order_progress.dart';
import 'package:delivery_app/src/screens/order/widget/floating_head.dart';
import 'package:delivery_app/src/screens/order/order_controller.dart';
import 'package:delivery_app/src/services/market_service.dart';
import 'package:delivery_app/src/widgets/address_dropdown/address_dropdown_controller.dart';
import 'package:delivery_app/src/widgets/icon_cart/icon_cart_controller.dart';
import 'package:delivery_app/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Database extends Mock implements DBProvider {}

class _Market extends Mock implements MarketService {}

class _OrderController extends Mock implements OrderController {}

class _Address extends ChangeNotifier implements AddressDropdownController {
  @override
  DropdownOption get dropdown => DropdownOption(
    name: 'Casa · Una dirección con un nombre muy largo',
    value: '1',
  );
  @override
  bool get inAsyncCall => false;
  @override
  Future<void> loadAddress() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Cart extends ChangeNotifier implements IconCartController {
  @override
  int items = 2;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Session extends TabManController {
  @override
  Future<int> checkSession() async => 0;
}

void main() {
  late Tab1Controller catalog;
  late Tab2Controller orders;
  late _Address address;
  late _Cart cart;
  late _Session tabs;
  final product = ProductModel(
    id: 1,
    companyId: 1,
    companyName: 'Un restaurante de nombre muy largo',
    name: 'Bowl de vegetales con una descripción extensa',
    description:
        'Ingredientes frescos y una descripción que ocupa varias líneas.',
    type: 10,
    price: 6.5,
    image: '',
  );
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesProvider().init();
    await S.load(const Locale('es'));
    final database = _Database();
    when(() => database.loadAddress()).thenAnswer((_) async => null);
    catalog = Tab1Controller(database: database, loadOnCreate: false)
      ..products = [product];
    orders = Tab2Controller(
      market: _Market(),
      notifications: const Stream.empty(),
      loadOnCreate: false,
    );
    address = _Address();
    cart = _Cart();
    tabs = _Session();
  });
  tearDown(() {
    catalog.dispose();
    orders.dispose();
    address.dispose();
    cart.dispose();
    tabs.dispose();
  });

  Future<void> pump(
    WidgetTester tester,
    Widget body, {
    bool dark = false,
    bool scaffold = true,
  }) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<Tab1Controller>.value(value: catalog),
          ChangeNotifierProvider<Tab2Controller>.value(value: orders),
          ChangeNotifierProvider<TabManController>.value(value: tabs),
          ChangeNotifierProvider<AddressDropdownController>.value(
            value: address,
          ),
          ChangeNotifierProvider<IconCartController>.value(value: cart),
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
            theme: dark ? darkThemeData(context) : lightThemeData(context),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: scaffold ? Scaffold(body: body) : body,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    testWidgets(
      'catalog fits 320 px with large text and no duplicated products ($dark)',
      (tester) async {
        await pump(tester, const Tab1Screen(), dark: dark);
        expect(find.text(product.name), findsOneWidget);
        expect(find.text('¿Qué te provoca hoy?'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets(
      'checkout breakdown wraps long names and shows delivery before total ($dark)',
      (tester) async {
        await pump(
          tester,
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DetailsProducts(
                cartSummary: CartSummaryModel(
                  products: [product],
                  fee: FeeModel(
                    name: 'Comercio',
                    marker: '',
                    image: '',
                    storeId: 1,
                    companyId: 1,
                    deliveryfee: 1.5,
                    fromlt: 0,
                    fromlg: 0,
                  ),
                ),
              ),
            ),
          ),
          dark: dark,
        );
        expect(find.text('1.50 USD'), findsOneWidget);
        expect(find.text('8.00 USD'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('restoring the account tab also restores its visible content', (
    tester,
  ) async {
    tabs.currentScreen = 2;
    await pump(tester, const TabMainScreen(), scaffold: false);
    expect(find.text('Todo listo para tu próximo pedido'), findsOneWidget);
    expect(find.byKey(const ValueKey('catalog-search')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigation exposes account and guest orders without a drawer', (
    tester,
  ) async {
    await pump(tester, const TabMainScreen(), scaffold: false);
    expect(
      tester.takeException(),
      isNull,
      reason: 'initial catalog and cart bar',
    );
    expect(
      tester.widget<GlassTabBar>(find.byType(GlassTabBar)).tabs,
      hasLength(3),
    );
    expect(find.byType(Drawer), findsNothing);
    await tester.tap(find.text('Cuenta').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'account screen');
    expect(find.text('Todo listo para tu próximo pedido'), findsOneWidget);
    await tester.tap(find.text('Pedidos').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Inicia sesión para consultar y seguir tus pedidos.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'tracking marks only the real completed stages and handles cancellation',
    (tester) async {
      await pump(
        tester,
        const OrderProgress(
          status: StatusOrder.assigned,
          companyType: TypesCompany.store,
        ),
      );
      expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));
      expect(
        find.byIcon(Icons.radio_button_unchecked_rounded),
        findsNWidgets(2),
      );
      await pump(
        tester,
        const OrderProgress(
          status: StatusOrder.cancelled,
          companyType: TypesCompany.store,
        ),
      );
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('tracking header remains compact above the map with large text', (
    tester,
  ) async {
    final controller = _OrderController();
    when(() => controller.order).thenReturn(
      OrderModel(
        id: 1,
        note: '',
        address: 'Centro',
        status: StatusOrder.assigned,
        products: [],
        deliveryFee: 1.5,
        total: 8,
        start: Location(x: 0, y: 0),
        location: Location(x: 0, y: 0),
        createdAt: DateTime(2026),
        store: Store(
          id: 1,
          name: 'Local',
          address: '',
          company: Company(image: '', marker: '', type: TypesCompany.store),
        ),
        notificationsClient: 0,
        payment: TypesPayment.cash,
        deliveryman: Deliveryman(
          id: 1,
          fullName: 'Motorizado de prueba',
          image: '',
        ),
      ),
    );
    await pump(
      tester,
      Stack(
        children: [
          const SizedBox.expand(),
          FloatingHead(orderController: controller),
        ],
      ),
    );
    final card = find
        .descendant(
          of: find.byType(FloatingHead),
          matching: find.byType(Container),
        )
        .first;
    expect(tester.getSize(card).height, lessThan(180));
    expect(tester.takeException(), isNull);
  });
}
