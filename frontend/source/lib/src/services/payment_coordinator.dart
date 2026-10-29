import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/src/models/product_model.dart';
import 'package:planck/src/services/payment_service.dart';

abstract interface class PaymentSheetGateway {
  Future<void> initialize(SetupPaymentSheetParameters parameters);
  Future<void> present();
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
  PaymentCoordinator({PaymentService? service, PaymentSheetGateway? sheet})
    : service = service ?? PaymentService(),
      sheet = sheet ?? NativePaymentSheetGateway();

  final PaymentService service;
  final PaymentSheetGateway sheet;

  Future<bool> pay(
    List<ProductModel> products,
    double money,
    String currency,
  ) async {
    if (!money.isFinite ||
        money <= 0 ||
        !RegExp(r'^[a-zA-Z]{3}$').hasMatch(currency)) {
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
      await sheet.present();
    } catch (_) {
      try {
        await service.cancel(id);
      } catch (_) {}
      return false;
    }
    // A successful sheet may already have charged the customer. Failure to
    // acknowledge it must not be reported as a user cancellation.
    try {
      return await service.confirm(id);
    } catch (_) {
      return false;
    }
  }
}
