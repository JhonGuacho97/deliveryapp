import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:delivery_app/src/models/category_model.dart';
import 'package:delivery_app/src/services/market_service.dart';

void main() {
  test(
    'the real store payload without a legacy business type remains readable',
    () async {
      final payload = {
        'companies': [
          {
            'id': 1,
            'storeId': 1,
            'isOpen': true,
            'name': 'Restaurante de prueba',
            'address': 'Dirección de demostración local',
            'contact': '0990000001',
            'image': '',
            'open': '00:00:00',
            'close': '23:59:59',
            'categoryId': 1,
            'location': {'x': -4.0236715, 'y': -79.1978733},
          },
        ],
        'products': [
          {
            'id': 1,
            'companyId': 1,
            'companyName': 'Restaurante de prueba',
            'name': 'Bowl de pollo · Prueba local',
            'description': 'Pollo y arroz.',
            'type': 1,
            'price': 6.5,
            'image': '',
          },
        ],
      };
      await http.runWithClient(
        () async {
          final response = await MarketService().getCompanies(
            CategoryModel(id: 0),
            -4.0236715,
            -79.1978733,
          );
          expect(response.hasError, isFalse);
          expect(response.companies.single.name, 'Restaurante de prueba');
          expect(response.companies.single.type, 10);
          expect(response.products.single.price, 6.5);
        },
        () => MockClient(
          (_) async => http.Response(
            jsonEncode(payload),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      );
    },
  );
  TestWidgetsFlutterBinding.ensureInitialized();
  test('global search sends encoded text and keeps related restaurants from the server', () async {
    await http.runWithClient(
      () async {
        final result = await MarketService().getCompanies(
          CategoryModel(id: 3),
          -4,
          -79,
          filter: '  queso & limón  ',
        );
        expect(result.hasError, isFalse);
        expect(result.companies.single.name, 'La Esquina');
        expect(result.products.single.name, 'Especial de la casa');
      },
      () => MockClient((request) async {
        expect(request.url.queryParameters, {
          'longitude': '-79.0',
          'latitude': '-4.0',
          'categoryId': '3',
          'query': 'queso & limón',
        });
        return http.Response(
          jsonEncode({
            'companies': [
              {
                'id': 3,
                'storeId': 3,
                'name': 'La Esquina',
                'address': 'Local',
                'contact': '',
                'image': '',
                'isOpen': true,
                'open': '00:00:00',
                'close': '23:59:59',
                'categoryId': 3,
                'location': {'x': -4, 'y': -79},
              },
            ],
            'products': [
              {
                'id': 20,
                'companyId': 3,
                'companyName': 'La Esquina',
                'name': 'Especial de la casa',
                'description': 'Queso & limón',
                'type': 1,
                'price': 8.5,
                'image': '',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
  });
  final service = MarketService();
  test('catalog errors cannot be mistaken for a valid empty market', () async {
    for (final code in [200, 500]) {
      await http.runWithClient(
        () async {
          final result = await service.getCompanies(
            CategoryModel(id: 0),
            -0.2,
            -78.5,
          );
          expect(result.hasError, code != 200);
          expect(result.products, isEmpty);
        },
        () => MockClient(
          (_) async => http.Response(
            jsonEncode({'companies': [], 'products': []}),
            code,
          ),
        ),
      );
    }
  });
  test(
    'malformed catalog responses show an error instead of partial results',
    () async {
      await http.runWithClient(() async {
        expect(
          (await service.getCompanies(CategoryModel(id: 0), 0, 0)).hasError,
          isTrue,
        );
      }, () => MockClient((_) async => http.Response('not-json', 200)));
    },
  );
  test(
    'a failed menu request is not shown as a restaurant with no products',
    () async {
      await http.runWithClient(() async {
        expect((await service.getProducts(1, 0)).hasError, isTrue);
      }, () => MockClient((_) async => http.Response('{}', 503)));
      await http.runWithClient(
        () async {
          expect((await service.getProducts(1, 0)).hasError, isFalse);
        },
        () => MockClient(
          (_) async => http.Response('{"products":[],"groups":[]}', 200),
        ),
      );
    },
  );
  test(
    'order loading distinguishes a network failure from no orders',
    () async {
      await http.runWithClient(() async {
        expect(await service.getOrders(throwOnError: true), isEmpty);
      }, () => MockClient((_) async => http.Response('{"orders":[]}', 200)));
      await http.runWithClient(() async {
        await expectLater(
          service.getOrders(throwOnError: true),
          throwsStateError,
        );
        expect(await service.getOrders(), isEmpty);
      }, () => MockClient((_) async => http.Response('{}', 503)));
    },
  );
}
