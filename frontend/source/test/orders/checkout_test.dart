import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_app/src/models/address_model.dart';
import 'package:delivery_app/src/models/cart_summary_model.dart';
import 'package:delivery_app/src/models/fee_model.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:delivery_app/src/provider/db_provider.dart';
import 'package:delivery_app/src/screens/cart_summary/cart_summary_controller.dart';
import 'package:delivery_app/src/services/market_service.dart';

class _Database extends Mock implements DBProvider {}

class _Market extends Mock implements MarketService {}

ProductModel product(int company) => ProductModel(
  id: company,
  companyId: company,
  companyName: 'Comercio',
  name: 'Producto',
  description: '',
  type: 1,
  price: 3.25,
  image: '',
);
FeeModel fee(int company) => FeeModel(
  name: 'Comercio',
  marker: '',
  image: '',
  storeId: company,
  companyId: company,
  deliveryfee: 1.5,
  fromlt: -0.2,
  fromlg: -78.5,
);

void main() {
  final address = AddressModel(
    id: 1,
    alias: 'Casa',
    address: 'Calle 1',
    location: Location(x: -0.3, y: -78.6),
  );
  setUpAll(() {
    registerFallbackValue(address);
    registerFallbackValue(CartSummaryModel(products: [], fee: fee(2)));
  });
  late _Database database;
  late _Market market;
  late CartSummaryController controller;
  setUp(() async {
    database = _Database();
    market = _Market();
    when(() => database.loadProducts(any()))
        .thenAnswer((_) async => [product(2), product(3)]);
    when(() => database.loadAddress()).thenAnswer((_) async => address);
    when(
      () => market.deliveryCost(
        any(),
        any(),
        any(),
        isSumaryTaxi: any(named: 'isSumaryTaxi'),
        fromLtTaxi: any(named: 'fromLtTaxi'),
        fromLgTaxi: any(named: 'fromLgTaxi'),
      ),
    ).thenAnswer((_) async => [fee(2), fee(3)]);
    when(() => database.deleteProductByCompany(any()))
        .thenAnswer((_) async => 1);
    controller = CartSummaryController(
      market: market,
      database: database,
      loadOnCreate: false,
    );
    await controller.loadDeliveryFee();
  });
  tearDown(() => controller.dispose());

  test('failed orders preserve the cart and reset the busy state', () async {
    when(() => market.buy(any(), any(), any())).thenAnswer((_) async => false);
    expect(await controller.buy(5001), isFalse);
    expect(controller.products, hasLength(2));
    expect(controller.summaries, hasLength(2));
    expect(controller.inAsyncCall, isFalse);
    verifyNever(() => database.deleteProductByCompany(any()));
  });
  test('a partial checkout only removes acknowledged stores and retries the remainder', () async {
    when(() => market.buy(any(), any(), any())).thenAnswer(
      (call) async =>
          (call.positionalArguments.first as CartSummaryModel).fee.companyId ==
          2,
    );
    expect(await controller.buy(5001), isFalse);
    expect(controller.products.single.companyId, 3);
    expect(controller.summaries.single.fee.companyId, 3);
    verify(() => database.deleteProductByCompany(2)).called(1);
    verifyNever(() => database.deleteProductByCompany(3));
    clearInteractions(market);
    when(() => market.buy(any(), any(), any())).thenAnswer((_) async => true);
    expect(await controller.buy(5001), isTrue);
    expect(controller.products, isEmpty);
    verify(() => market.buy(any(), any(), 5001)).called(1);
    verify(() => database.deleteProductByCompany(3)).called(1);
  });
}
