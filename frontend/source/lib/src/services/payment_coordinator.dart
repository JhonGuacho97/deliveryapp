import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:delivery_app/src/services/payment_service.dart';
import 'package:delivery_app/src/screens/payments/payphone_checkout_screen.dart';

abstract interface class HostedPaymentGateway {
  Future<bool> present(
    BuildContext? context,
    Map<String, dynamic> payment,
    PaymentService service,
  );
}

class BrowserPaymentGateway implements HostedPaymentGateway {
  @override
  Future<bool> present(
    BuildContext? context,
    Map<String, dynamic> payment,
    PaymentService service,
  ) async {
    if (context == null || !context.mounted) return false;
    return await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) =>
                PayphoneCheckoutScreen(payment: payment, service: service),
          ),
        ) ==
        true;
  }
}

abstract interface class PaymentSheetGateway {
  Future<void> initialize(SetupPaymentSheetParameters parameters);
  Future<void> present();
}

enum PaymentAttemptStatus {
  notStarted,
  pending,
  confirmed,
  declined,
  cancelled,
}

class NativePaymentSheetGateway implements PaymentSheetGateway {
  @override
  Future<void> initialize(SetupPaymentSheetParameters parameters) async {
    await Stripe.instance.initPaymentSheet(paymentSheetParameters: parameters);
  }

  @override
  Future<void> present() async {
    await Stripe.instance.presentPaymentSheet();
  }
}

class PaymentCoordinator {
  PaymentCoordinator({
    PaymentService? service,
    PaymentSheetGateway? sheet,
    HostedPaymentGateway? hosted,
    this.stripeEnabled = kStripeEnabled,
  }) : service = service ?? PaymentService(),
       hosted = hosted ?? BrowserPaymentGateway(),
       sheet = sheet ?? NativePaymentSheetGateway();

  final PaymentService service;
  final PaymentSheetGateway sheet;
  final HostedPaymentGateway hosted;
  final bool stripeEnabled;
  PaymentAttemptStatus status = PaymentAttemptStatus.notStarted;

  Future<bool> pay(
    List<ProductModel> products,
    double money,
    String currency, {
    BuildContext? context,
  }) async {
    status = PaymentAttemptStatus.notStarted;
    if (!money.isFinite ||
        money < 1 ||
        money > 10000 ||
        currency.toUpperCase() != 'USD' ||
        (money * 100 - (money * 100).round()).abs() > .000001) {
      return false;
    }
    Map<String, dynamic>? intent;
    try {
      intent = await service.payment(products, money, currency);
    } catch (_) {
      return false;
    }
    if (intent == null || intent['id'] is! int) return false;
    final id = intent['id'] as int;
    if (intent['provider'] == 'payphone') {
      // Only the backend can confirm credit; dismissing a browser is not a cancellation.
      if (intent['status'] == 100) {
        status = PaymentAttemptStatus.confirmed;
        return true;
      }
      if (intent['status'] == 400) {
        status = PaymentAttemptStatus.declined;
        return false;
      }
      if (intent['status'] != 1) return false;
      final response = intent['response'];
      if (response is! Map ||
          response['checkoutUrl'] is! String ||
          (response['checkoutUrl'] as String).isEmpty)
        return false;
      status = PaymentAttemptStatus.pending;
      try {
        final paid = await hosted.present(context, intent, service);
        if (paid) status = PaymentAttemptStatus.confirmed;
        return paid;
      } catch (_) {
        return false;
      }
    }
    if (!stripeEnabled ||
        (intent['provider'] != null && intent['provider'] != 'stripe'))
      return false;
    var presented = false;
    try {
      final response = intent['response'];
      if (response is! Map ||
          response['client_secret'] is! String ||
          (response['client_secret'] as String).isEmpty) {
        throw const FormatException('Missing payment sheet configuration');
      }
      await sheet.initialize(
        SetupPaymentSheetParameters(
          merchantDisplayName: kNameApp,
          customerId: response['customer'] as String?,
          paymentIntentClientSecret: response['client_secret'] as String,
          customerEphemeralKeySecret: response['ephemeralKey'] as String?,
        ),
      );
      presented = true;
      status = PaymentAttemptStatus.pending;
      await sheet.present();
    } catch (_) {
      try {
        if (await service.cancel(id) && presented)
          status = PaymentAttemptStatus.cancelled;
      } catch (_) {}
      return false;
    }
    // A successful sheet may already have charged the customer. Failure to
    // acknowledge it must not be reported as a user cancellation.
    try {
      final paid = await service.confirm(id);
      if (paid) status = PaymentAttemptStatus.confirmed;
      return paid;
    } catch (_) {
      return false;
    }
  }
}
