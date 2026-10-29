import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:planck/constants/code_error_constant.dart';
import 'package:planck/constants/preparation_status.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/models/company_product_model.dart';
import 'package:planck/src/models/hour_model.dart';
import 'package:planck/src/models/request_model.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/manager/hours/hours_controller.dart';
import 'package:planck/src/screens/manager/products/products_controller.dart';
import 'package:planck/src/screens/manager/requests/requests_controller.dart';
import 'package:planck/src/screens/manager/requests/requests_screen.dart';
import 'package:planck/src/services/request_service.dart';
import 'package:planck/src/services/restaurant_api.dart';
import 'package:planck/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/restaurant_fixtures.dart';

class _Controller extends RequestsController {
  _Controller(RequestService service)
    : super(
        service: service,
        notifications: const Stream.empty(),
        loadOnCreate: false,
      );
  @override
  Future<int> checkSession() async => CodeError.none;
}

class _SlowRequests extends RestaurantRequestsFixture {
  final gate = Completer<void>();
  @override
  Future<RequestModel> accept(int id, int minutes) async {
    await gate.future;
    return super.accept(id, minutes);
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'uuid': 'test-device',
      'token': 'fixture',
    });
    await PreferencesProvider().init();
    await S.load(const Locale('es'));
  });
  test('preparation is independent from assignment and legacy requests remain readable', () async {
    final service = RestaurantRequestsFixture();
    final controller = _Controller(service);
    addTearDown(controller.dispose);
    await controller.loadRequests();
    expect(controller.count(PreparationStatus.pending), 1);
    expect(await controller.accept(1024, 25), isTrue);
    expect(controller.requests.single.status, 1);
    expect(controller.count(PreparationStatus.preparing), 1);
    expect(await controller.ready(1024), isTrue);
    expect(controller.count(PreparationStatus.ready), 1);
    expect(controller.requests.single.status, 1);
    final legacy = restaurantOrder(preparation: null);
    expect(RequestModel.fromJson(legacy.toJson()).preparationStatus, isNull);
    expect(legacy.store.company.type, 10);
  });
  test('double taps send only one accept request', () async {
    final service = _SlowRequests();
    final controller = _Controller(service);
    addTearDown(controller.dispose);
    await controller.loadRequests();
    final first = controller.accept(1024, 25);
    expect(await controller.accept(1024, 25), isFalse);
    expect(controller.isBusy(1024), isTrue);
    service.gate.complete();
    expect(await first, isTrue);
    expect(service.accepts, 1);
    expect(controller.isBusy(1024), isFalse);
  });
  test(
    'failed transitions keep the previous order and release the busy state',
    () async {
      final service = RestaurantRequestsFixture();
      final controller = _Controller(service);
      addTearDown(controller.dispose);
      await controller.loadRequests();
      service.fail = true;
      expect(await controller.accept(1024, 25), isFalse);
      expect(
        controller.requests.single.preparationStatus,
        PreparationStatus.pending,
      );
      expect(controller.actionErrorCode, 409);
      expect(controller.isBusy(1024), isFalse);
    },
  );
  test(
    'product payload matches the backend DTO and omits unsupported groups',
    () {
      final product = CompanyProductModel(
        id: 0,
        name: 'Bowl',
        description: 'Una descripción',
        price: 6.5,
      );
      final body = jsonDecode(
        product.toHttpBodyCreate(1) as String,
      ) as Map<String, dynamic>;
      expect(body.containsKey('group'), isFalse);
      expect(body['company'], {'id': 1});
      expect(body['image'], '');
    },
  );
  test('failed product saves preserve the current menu', () async {
    final service = RestaurantStoreFixture();
    final controller = ProductsController(
      restaurantStore(),
      service: service,
      loadOnCreate: false,
    );
    addTearDown(controller.dispose);
    await controller.load();
    service.fail = true;
    final draft = CompanyProductModel.fromJson(
      controller.products.single.toJson(),
    )..price = 9;
    expect(await controller.save(draft), isFalse);
    expect(controller.products.single.price, 6.5);
    expect(controller.saving, isFalse);
  });
  test(
    'the first schedule row updates and a failure does not overwrite it',
    () async {
      final service = RestaurantStoreFixture();
      final controller = HoursController(
        restaurantStore(),
        service: service,
        loadOnCreate: false,
      );
      addTearDown(controller.dispose);
      await controller.load();
      final draft = HourModel.fromJson(controller.hours.first.toJson())
        ..open = '09:00:00';
      expect(await controller.updateHour(draft), isTrue);
      expect(controller.hours.first.open, '09:00:00');
      service.fail = true;
      final rejected = HourModel.fromJson(draft.toJson())..close = '20:00:00';
      expect(await controller.updateHour(rejected), isFalse);
      expect(controller.hours.first.close, '22:00:00');
    },
  );
  test('accept uses authenticated PATCH and exposes state conflicts', () async {
    await http.runWithClient(
      () async {
        final result = await RequestService().accept(1024, 25);
        expect(result.preparationStatus, PreparationStatus.preparing);
      },
      () => MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/api/manager/request/1024/accept');
        expect(jsonDecode(request.body), {'preparationMinutes': 25});
        expect(request.headers['Authorization'], 'Bearer fixture');
        return http.Response(
          jsonEncode({
            'request': restaurantOrder(preparation: PreparationStatus.preparing)
                .toJson(),
          }),
          200,
        );
      }),
    );
    await http.runWithClient(() async {
      await expectLater(
        RequestService().ready(1024),
        throwsA(
          isA<RestaurantApiException>().having(
            (e) => e.statusCode,
            'status',
            409,
          ),
        ),
      );
    }, () => MockClient((_) async => http.Response('{}', 409)));
  });
  for (final dark in [false, true]) {
    testWidgets(
      'restaurant queues, menu and business fit 320 px with larger text ($dark)',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = _Controller(RestaurantRequestsFixture());
        await controller.loadRequests();
        await tester.pumpWidget(
          ChangeNotifierProvider<RequestsController>.value(
            value: controller,
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
                home: RequestsScreen(storeService: RestaurantStoreFixture()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Sin cebolla en un bowl.'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Menú').last);
        await tester.pumpAndSettle();
        expect(find.text('Bowl de pollo'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Negocio').last);
        await tester.pumpAndSettle();
        expect(find.text('Horarios de atención'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
      },
    );
  }
}
