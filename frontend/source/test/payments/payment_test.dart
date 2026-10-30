import 'dart:async';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:delivery_app/src/screens/cart_summary/cart_summary_controller.dart';
import 'package:delivery_app/src/services/payment_coordinator.dart';
import 'package:delivery_app/src/services/payment_service.dart';

class _Service extends Mock implements PaymentService {}

class _Sheet extends Mock implements PaymentSheetGateway {}

void main() {
  setUpAll(() => registerFallbackValue(const SetupPaymentSheetParameters()));
  late _Service service;
  late _Sheet sheet;
  late PaymentCoordinator payments;
  final products = <ProductModel>[];
  setUp(() {
    service = _Service();
    sheet = _Sheet();
    payments = PaymentCoordinator(
      service: service,
      sheet: sheet,
      stripeEnabled: true,
    );
    when(() => service.payment(products, 10, 'usd')).thenAnswer(
      (_) async => {
        'id': 9,
        'response': {
          'customer': 'cus_fixture',
          'client_secret': 'pi_fixture_secret',
          'ephemeralKey': 'ek_fixture',
        },
      },
    );
    when(() => service.confirm(9)).thenAnswer((_) async => true);
    when(() => service.cancel(9)).thenAnswer((_) async => true);
    when(() => sheet.initialize(any())).thenAnswer((_) async {});
    when(() => sheet.present()).thenAnswer((_) async {});
  });

  test(
    'confirms only after initializing and completing the payment sheet',
    () async {
      expect(await payments.pay(products, 10, 'usd'), isTrue);
      expect(payments.status, PaymentAttemptStatus.confirmed);
      verifyInOrder([
        () => sheet.initialize(any()),
        () => sheet.present(),
        () => service.confirm(9),
      ]);
      verifyNever(() => service.cancel(any()));
    },
  );
  test(
    'cancellation does not confirm and awaits backend cancellation',
    () async {
      when(() => sheet.present()).thenThrow(Exception('user canceled fixture'));
      expect(await payments.pay(products, 10, 'usd'), isFalse);
      expect(payments.status, PaymentAttemptStatus.cancelled);
      verifyNever(() => service.confirm(any()));
      verify(() => service.cancel(9)).called(1);
    },
  );
  test('initialization failure cancels without presenting the sheet', () async {
    when(() => sheet.initialize(any()))
        .thenThrow(Exception('fixture configuration'));
    expect(await payments.pay(products, 10, 'usd'), isFalse);
    expect(payments.status, PaymentAttemptStatus.notStarted);
    verifyNever(() => sheet.present());
    verify(() => service.cancel(9)).called(1);
  });
  test(
    'failed confirmation does not cancel an already completed payment',
    () async {
      when(() => service.confirm(9)).thenThrow(Exception('fixture offline'));
      expect(await payments.pay(products, 10, 'usd'), isFalse);
      expect(payments.status, PaymentAttemptStatus.pending);
      verifyNever(() => service.cancel(any()));
    },
  );
  test('rejects invalid amounts before contacting the API', () async {
    expect(await payments.pay(products, double.nan, 'usd'), isFalse);
    expect(await payments.pay(products, -1, 'usd'), isFalse);
    expect(await payments.pay(products, 10, ''), isFalse);
    verifyZeroInteractions(service);
  });
  test('Stripe stays disabled unless explicitly enabled', () async {
    final disabled = PaymentCoordinator(service: service, sheet: sheet);
    expect(await disabled.pay(products, 10, 'usd'), isFalse);
    verifyZeroInteractions(sheet);
    verifyNever(() => service.cancel(any()));
  });
  test('a provider initialization error is not a pending payment', () async {
    when(() => service.payment(products, 10, 'usd'))
        .thenThrow(Exception('provider unavailable'));
    expect(await payments.pay(products, 10, 'usd'), false);
    expect(payments.status, PaymentAttemptStatus.notStarted);
    verifyZeroInteractions(sheet);
    verifyNever(() => service.cancel(any()));
  });
  test('malformed or unavailable intents do not open a native sheet', () async {
    when(() => service.payment(products, 10, 'usd'))
        .thenAnswer((_) async => null);
    expect(await payments.pay(products, 10, 'usd'), isFalse);
    when(() => service.payment(products, 10, 'usd'))
        .thenAnswer((_) async => {'id': 9, 'response': {}});
    expect(await payments.pay(products, 10, 'usd'), isFalse);
    verifyZeroInteractions(sheet);
  });
  test(
    'the cart prevents duplicate taps and always restores its busy state',
    () async {
      final completion = Completer<void>();
      when(() => sheet.present()).thenAnswer((_) => completion.future);
      final controller = CartSummaryController(
        payments: payments,
        loadOnCreate: false,
      );
      final first = controller.makePayment(money: 10, currency: 'usd');
      expect(controller.inAsyncCall, isTrue);
      expect(await controller.makePayment(money: 10, currency: 'usd'), isFalse);
      completion.complete();
      expect(await first, isTrue);
      expect(controller.inAsyncCall, isFalse);
      verify(() => service.payment(products, 10, 'usd')).called(1);
      controller.dispose();
    },
  );
}
