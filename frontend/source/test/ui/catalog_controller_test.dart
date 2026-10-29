import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_app/src/models/address_model.dart';
import 'package:delivery_app/src/models/category_model.dart';
import 'package:delivery_app/src/models/market_companies_response.dart';
import 'package:delivery_app/src/provider/db_provider.dart';
import 'package:delivery_app/src/screens/main/tab1_controller.dart';
import 'package:delivery_app/src/services/market_service.dart';

class _Market extends Mock implements MarketService {}

class _Database extends Mock implements DBProvider {}

void main() {
  late _Market market;
  late _Database database;
  late Tab1Controller controller;
  MarketCompaniesResponse result() =>
      MarketCompaniesResponse(companies: [], products: []);
  setUpAll(() => registerFallbackValue(CategoryModel(id: 0)));
  setUp(() {
    market = _Market();
    database = _Database();
    when(() => database.loadAddress()).thenAnswer(
      (_) async => AddressModel(
        id: 1,
        alias: 'Casa',
        location: Location(x: -0.2, y: -78.5),
      ),
    );
    when(() => database.loadProducts(any())).thenAnswer((_) async => []);
    when(() => market.getCategories(any(), any())).thenAnswer((_) async => []);
    when(
      () => market.getCompanies(
        any(),
        any(),
        any(),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((_) async => result());
    controller = Tab1Controller(
      market: market,
      database: database,
      loadOnCreate: false,
    );
  });
  tearDown(() => controller.dispose());

  testWidgets(
    'debounces typing and retains the query when a category changes',
    (tester) async {
      controller.filterCompanies('pol');
      await tester.pump(const Duration(milliseconds: 200));
      controller.filterCompanies('pollo');
      await tester.pump(const Duration(milliseconds: 349));
      verifyNever(
        () => market.getCompanies(
          any(),
          any(),
          any(),
          filter: any(named: 'filter'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      verify(() => market.getCompanies(any(), any(), any(), filter: 'pollo'))
          .called(1);
      controller.selectedCategory = CategoryModel(id: 4, name: 'Casera');
      await tester.pump();
      verify(() => market.getCompanies(any(), any(), any(), filter: 'pollo'))
          .called(1);
      expect(controller.selectedCategory.id, 4);
      await controller.clearFilters();
      expect(controller.query, isEmpty);
      expect(controller.selectedCategory.id, 0);
    },
  );

  test('older responses cannot replace newer search results', () async {
    final old = Completer<MarketCompaniesResponse>();
    final fresh = Completer<MarketCompaniesResponse>();
    when(() => market.getCompanies(any(), any(), any(), filter: 'old'))
        .thenAnswer((_) => old.future);
    when(() => market.getCompanies(any(), any(), any(), filter: 'new'))
        .thenAnswer((_) => fresh.future);
    final first = controller.loadCompanies(filter: 'old');
    await Future<void>.delayed(Duration.zero);
    final second = controller.loadCompanies(filter: 'new');
    await Future<void>.delayed(Duration.zero);
    fresh.complete(result());
    await second;
    old.complete(
      MarketCompaniesResponse(companies: [], products: [], hasError: true),
    );
    await first;
    expect(controller.hasError, isFalse);
    expect(controller.query, 'new');
    expect(controller.inAsyncCall, isFalse);
  });

  test(
    'connection failures and valid empty catalogs are different states',
    () async {
      await controller.loadCompanies();
      expect(controller.hasError, isFalse);
      when(
        () => market.getCompanies(
          any(),
          any(),
          any(),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer(
        (_) async => MarketCompaniesResponse(
          companies: [],
          products: [],
          hasError: true,
        ),
      );
      await controller.loadCompanies();
      expect(controller.hasError, isTrue);
      expect(controller.inAsyncCall, isFalse);
    },
  );

  test(
    'no address offers address selection without requesting the catalog',
    () async {
      when(() => database.loadAddress()).thenAnswer((_) async => null);
      await controller.loadCompanies();
      expect(controller.needsAddress, isTrue);
      expect(controller.inAsyncCall, isFalse);
      verifyNever(
        () => market.getCompanies(
          any(),
          any(),
          any(),
          filter: any(named: 'filter'),
        ),
      );
    },
  );
}
