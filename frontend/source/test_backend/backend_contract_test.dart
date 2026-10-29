import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http/testing.dart';
import 'package:delivery_app/src/bloc/socket_bloc.dart';
import 'package:delivery_app/src/screens/order/order_controller.dart';
import 'package:delivery_app/src/models/address_model.dart' as addresses;
import 'package:delivery_app/src/models/cart_summary_model.dart';
import 'package:delivery_app/src/models/category_model.dart';
import 'package:delivery_app/src/models/chat_message_model.dart';
import 'package:delivery_app/src/models/enrollment_model.dart' as enrollments;
import 'package:delivery_app/src/models/fee_model.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';
import 'package:delivery_app/src/services/address_service.dart';
import 'package:delivery_app/src/services/auth_service.dart';
import 'package:delivery_app/src/services/balance_service.dart';
import 'package:delivery_app/src/services/chat_service.dart';
import 'package:delivery_app/src/services/credit_service.dart';
import 'package:delivery_app/src/services/enrollment_service.dart';
import 'package:delivery_app/src/services/market_service.dart';
import 'package:delivery_app/src/services/payment_service.dart';
import 'package:delivery_app/src/services/petition_service.dart';
import 'package:delivery_app/src/services/request_service.dart';
import 'package:delivery_app/src/services/store_manager_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/support/fixtures.dart';
import '../test/support/tracking_fixtures.dart';

class _NativeHttp extends HttpOverrides {
  HttpClient realClient() => super.createHttpClient(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Process server;
  late Uri origin;
  late String token;
  IOClient? transport;
  final responses = <int>[];
  final errors = StringBuffer();
  final address = addresses.AddressModel(
    id: 1,
    alias: 'Casa',
    address: 'Calle 1',
    location: addresses.Location(x: -0.3, y: -78.6),
  );
  final product = ProductModel(
    id: 7,
    companyId: 2,
    companyName: 'Comercio',
    name: 'Producto',
    description: '',
    type: 1,
    price: 3.25,
    image: '',
    number: 2,
  );
  setUpAll(() async {
    final root = Directory('../../backend/james').absolute.path;
    final node = '$root/.tools/node-v24.22.1-win-x64/node.exe';
    server = await Process.start(node, ['test_backend/fixture.cjs']);
    server.stderr.transform(utf8.decoder).listen(errors.write);
    final line = await server.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .first
        .timeout(
          const Duration(seconds: 90),
          onTimeout: () => throw StateError('Fixture did not start: $errors'),
        );
    final configuration = jsonDecode(line);
    origin = Uri.parse('http://127.0.0.1:${configuration['port']}');
    token = configuration['token'];
    transport = IOClient(_NativeHttp().realClient());
  });
  tearDownAll(() async {
    transport?.close();
    server.stdin.writeln('quit');
    await server.exitCode.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        server.kill();
        return -1;
      },
    );
  });
  setUp(() async {
    // This opt-in test lives outside test/ so standalone verification needs no backend.
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({
      'uuid': testDeviceId,
      'token': token,
    });
    await PreferencesProvider().init();
    responses.clear();
  });
  Future<void> contract(Future<void> Function() run, List<int> expected) async {
    await http.runWithClient(
      run,
      () => MockClient((request) async {
        final local = origin.replace(
          path: request.url.path,
          query: request.url.query,
        );
        final forwarded = http.Request(request.method, local)
          ..headers.addAll(request.headers)
          ..bodyBytes = request.bodyBytes;
        final response = await http.Response.fromStream(
          await transport!.send(forwarded),
        );
        responses.add(response.statusCode);
        if (response.statusCode >= 400) {
          final failure =
              '${request.method} ${request.url.path}: ${response.body}';
          errors.writeln(failure);
          // Only fixture validation errors, never credentials or external traffic.
          print(failure);
        }
        return response;
      }),
    );
    expect(responses, expected, reason: errors.toString());
  }

  test('access and token update use real Nest DTOs and guards', () async {
    await contract(() async {
      expect(
        (await AuthService().login('client@example.test', 'Fixture123!'))!.id,
        7,
      );
      expect(
        await AuthService().updateTokenPush(
          'fixture-push-token'.padRight(140, 'x'),
        ),
        isTrue,
      );
    }, [201, 200]);
  });
  test(
    'catalog requests pass validation and accept backend response shapes',
    () async {
      await contract(() async {
        await MarketService().getCompanies(
          CategoryModel(id: 0),
          -0.2,
          -78.5,
          filter: 'Café & pan',
        );
        await MarketService().getCategories(-0.2, -78.5);
        final products = await MarketService().getProducts(2, 0);
        expect(products.products, isEmpty);
        final fees = await MarketService().deliveryCost('2', -0.3, -78.6);
        expect(fees.single.deliveryfee, 1.5);
        final orders = await MarketService().getOrders();
        expect(orders.single.start.x, -0.2);
        expect((await MarketService().getOrder(orders.single)).id, 9);
      }, [200, 200, 200, 200, 200, 200]);
    },
  );
  test(
    'order creation accepts the actual POST 201 and raw order acknowledgement',
    () async {
      await contract(() async {
        final cart = CartSummaryModel(
          products: [product],
          fee: FeeModel(
            name: 'Comercio',
            marker: '',
            image: '',
            storeId: 5,
            companyId: 2,
            deliveryfee: 1.5,
            fromlt: -0.2,
            fromlg: -78.5,
          ),
        );
        expect(await MarketService().buy(cart, address, 5001), isTrue);
      }, [201]);
    },
  );
  test('addresses and balance cross the authenticated API boundary', () async {
    await contract(() async {
      expect((await AddressService().getAdress()).single.id, 1);
      expect((await AddressService().create(address))!.id, 1);
      expect((await AddressService().update(address))!.id, 1);
      expect(await AddressService().remove(address), isTrue);
      expect((await AddressService().geocode('fixture-place'))!.x, -0.2);
      await AddressService().autocomplete('Calle', lt: -0.2, lg: -78.5);
      expect((await BalanceService().getBalance())!.money, 10);
    }, [200, 201, 200, 200, 200, 200, 200]);
  });
  test(
    'chat uses the Nest POST status and authenticated read acknowledgement',
    () async {
      await contract(() async {
        await ChatService().getChats(9);
        expect(
          await ChatService().send(
            'client',
            ChatMessageModel(
              message: 'Hola',
              createdAt: DateTime(2026),
              orderId: 9,
              toId: 8,
            ),
          ),
          isTrue,
        );
        expect(await ChatService().markAllRead('client', 9), isTrue);
      }, [200, 201, 200]);
    },
  );
  test(
    'manager and deliveryman endpoints accept the existing device contract',
    () async {
      await contract(() async {
        await StoreManagerService().getCompanies();
        await StoreManagerService().getProducts(2);
        await StoreManagerService().getHours(5);
        await RequestService().findNearRequests();
        await RequestService().history('2026-10-28');
        await PetitionService().findNearPetitions();
        await PetitionService().history('2026-10-28');
        expect(await PetitionService().activate(true, -0.2, -78.5), isTrue);
        await EnrollmentService().getCategories();
        expect(
          await EnrollmentService().enrollment(
            enrollments.EnrollmentModel(
              name: 'Comercio',
              address: 'Calle 1',
              contact: '0991234567',
              email: 'store@example.test',
              location: enrollments.Location(x: -0.2, y: -78.5),
            ),
            2,
          ),
          isNotNull,
        );
        expect(await CreditService().topUpBalance('0991234567', 10), isNotNull);
      }, [200, 200, 200, 200, 200, 200, 200, 200, 200, 201, 201]);
    },
  );
  test(
    'payment service calls Nest DTOs without connecting to Stripe',
    () async {
      await contract(() async {
        expect(
          (await PaymentService().payment([product], 10, 'usd'))!['id'],
          9,
        );
        expect(await PaymentService().confirm(9), isTrue);
        expect(await PaymentService().cancel(9), isTrue);
      }, [201, 200, 200]);
    },
  );
  test('client order receives courier coordinates from Nest without Maps or Firebase', () async {
    await HttpOverrides.runWithHttpOverrides(() async {
      final socket = SocketBloc.connection(endpoint: origin.toString());
      final controller = OrderController(
        trackingOrder(),
        socket: socket,
        mapsEnabled: false,
        notifications: const Stream.empty(),
        refreshInterval: null,
      );
      try {
        await Future<void>.delayed(Duration.zero);
        final connected = Completer<void>();
        if (socket.connected()) {
          connected.complete();
        } else {
          socket.socket!.on('connect', (_) {
            if (!connected.isCompleted) connected.complete();
          });
        }
        await connected.future.timeout(const Duration(seconds: 10));
        final received = Completer<void>();
        controller.addListener(() {
          if (controller.courierPosition != null && !received.isCompleted)
            received.complete();
        });
        socket.socket!.emit('l', {
          'id': 7,
          'p': [-4.024, -79.197],
        });
        await received.future.timeout(const Duration(seconds: 5));
        expect(controller.courierPosition, const LatLng(-4.024, -79.197));
        expect(
          controller.markers
              .singleWhere((m) => m.markerId.value == 'deliveryman')
              .position,
          const LatLng(-4.024, -79.197),
        );
      } finally {
        controller.dispose();
      }
    }, _NativeHttp());
  });

  test('Socket.IO 3 exchanges coordinates with the real Nest gateway and reconnects', () async {
    await HttpOverrides.runWithHttpOverrides(() async {
      final socket = SocketBloc.connection(endpoint: origin.toString());
      try {
        for (var connection = 0; connection < 2; connection++) {
          socket.connect(7);
          final connected = Completer<void>();
          socket.socket!.on('connect', (_) {
            if (!connected.isCompleted) connected.complete();
          });
          await connected.future.timeout(const Duration(seconds: 10));
          final location = socket.stream.first;
          socket.socket!.emit('l', {
            'id': 7,
            'p': [-0.2, -78.5],
          });
          expect(
            await location.timeout(const Duration(seconds: 5)),
            const LatLng(-0.2, -78.5),
          );
          socket.close();
        }
      } finally {
        socket.disposeStreams();
      }
    }, _NativeHttp());
  });
}
