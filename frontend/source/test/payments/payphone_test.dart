import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:delivery_app/src/services/payment_coordinator.dart';
import 'package:delivery_app/src/services/payment_service.dart';
import 'package:delivery_app/src/screens/payments/payphone_checkout_screen.dart';

final fixture = <String, dynamic>{
  'id': 9,
  'provider': 'payphone',
  'status': 1,
  'money': 3.25,
  'response': {
    'checkoutUrl':
        'http://localhost:3000/api/client/payments/payphone/start/${'a' * 24}',
  },
};

class _Service extends PaymentService {
  _Service() : super(baseUrl: 'http://10.0.2.2:3000/api/');
  int state = 1, cancels = 0, requests = 0;
  @override
  Future<Map<String, dynamic>?> payment(
    List<ProductModel> products,
    double money,
    String currency,
  ) async => {...fixture};
  @override
  Future<Map<String, dynamic>?> status(int id) async {
    requests++;
    return {...fixture, 'status': state};
  }

  @override
  Future<bool> cancel(int id) async {
    cancels++;
    return true;
  }
}

class _Hosted implements HostedPaymentGateway {
  bool result = false;
  int calls = 0;
  @override
  Future<bool> present(
    BuildContext? context,
    Map<String, dynamic> payment,
    PaymentService service,
  ) async {
    calls++;
    return result;
  }
}

void main() {
  test('confirm and cancel honor JSON false even on HTTP 200', () async {
    final service = PaymentService(
      token: () => 'fixture',
      client: MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer fixture');
        return http.Response('false', 200);
      }),
    );
    expect(await service.confirm(9), false);
    expect(await service.cancel(9), false);
  });
  test(
    'HTTP errors and malformed status responses do not confirm a payment',
    () async {
      for (final response in [
        http.Response('true', 503),
        http.Response('invalid', 200),
      ]) {
        final service = PaymentService(
          token: () => '',
          client: MockClient((_) async => response),
        );
        expect(await service.confirm(9), false);
        expect(await service.status(9), null);
      }
    },
  );
  test('creates the checkout with cents precision and queries authenticated status', () async {
    final client = MockClient((request) async {
      if (request.method == 'POST')
        expect(jsonDecode(request.body)['money'], 3.25);
      return http.Response(
        jsonEncode(fixture),
        request.method == 'POST' ? 201 : 200,
      );
    });
    final service = PaymentService(client: client, token: () => 'fixture');
    expect((await service.payment([], 3.25, 'USD'))?['provider'], 'payphone');
    expect((await service.status(9))?['status'], 1);
  });
  test(
    'closing or completing PayPhone never calls Stripe or locally cancels',
    () async {
      final service = _Service(), hosted = _Hosted();
      final payments = PaymentCoordinator(service: service, hosted: hosted);
      expect(await payments.pay([], 3.25, 'USD'), false);
      hosted.result = true;
      expect(await payments.pay([], 3.25, 'USD'), true);
      expect(hosted.calls, 2);
      expect(service.cancels, 0);
    },
  );
  test('permits a local bridge through adb reverse and rejects foreign or direct provider URLs', () {
    const base = 'http://10.0.2.2:3000/api/';
    final link = (fixture['response'] as Map)['checkoutUrl'] as String;
    expect(payphoneBridgeUrl(link, base)?.host, 'localhost');
    expect(payphoneBridgeUrl(link.replaceFirst(':3000', ':4000'), base), null);
    expect(
      payphoneBridgeUrl(link.replaceFirst('localhost', 'evil.test'), base),
      null,
    );
    expect(payphoneBridgeUrl('javascript:alert(1)', base), null);
    expect(
      payphoneBridgeUrl(
        'https://pay.payphonetodoesposible.com/Anonymous/Index?paymentId=x',
        base,
      ),
      null,
    );
    expect(payphoneBridgeUrl(link, 'https://api.example.test/api/'), null);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'PayPhone is readable on small screens in $brightness and confirms only server success',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final service = _Service();
        final launched = <Uri>[];
        bool? completed;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            locale: const Locale('es'),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.4)),
              child: child!,
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  child: const Text('cart'),
                  onPressed: () async {
                    completed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => PayphoneCheckoutScreen(
                          payment: fixture,
                          service: service,
                          launcher: (url) async {
                            launched.add(url);
                            return true;
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('cart'));
        await tester.pumpAndSettle();
        expect(completed, null);
        expect(find.text('3.25 USD'), findsOneWidget);
        await tester.ensureVisible(find.text('Abrir PayPhone'));
        await tester.tap(find.text('Abrir PayPhone'));
        await tester.pump();
        expect(launched.single.host, 'localhost');
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(completed, null);
        service.state = 100;
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(completed, true);
        expect(service.cancels, 0);
        expect(tester.takeException(), null);
      },
    );
  }
  testWidgets('leaving a pending checkout does not cancel it', (tester) async {
    final service = _Service();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: PayphoneCheckoutScreen(payment: fixture, service: service),
      ),
    );
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    final count = service.requests;
    await tester.pump(const Duration(seconds: 9));
    expect(service.requests, count);
    await tester.pumpWidget(const SizedBox());
    expect(service.cancels, 0);
    expect(tester.takeException(), null);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });
}
