import 'package:flutter/material.dart';
import 'package:delivery_app/constants/types_constant.dart';
import 'package:delivery_app/src/models/address_model.dart';
import 'package:delivery_app/src/models/balance_model.dart';
import 'package:delivery_app/src/models/cart_summary_model.dart';
import 'package:delivery_app/src/models/fee_model.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:delivery_app/src/provider/db_provider.dart';
import 'package:delivery_app/src/services/balance_service.dart';
import 'package:delivery_app/src/services/market_service.dart';
import 'package:delivery_app/src/services/payment_coordinator.dart';

class CartSummaryController extends ChangeNotifier {
  final MarketService marketService;
  final DBProvider _database;
  final BalanceService balanceService;

  final List<CartSummaryModel> _summaries = [];

  double _money = 0.0;

  double get money => _money;

  set money(double money) {
    _money = money;
    notifyListeners();
  }

  bool _inAsyncCall = false;

  bool _isSumaryTaxi = false;

  CartSummaryController({
    bool isSumaryTaxi = false,
    PaymentCoordinator? payments,
    MarketService? market,
    DBProvider? database,
    BalanceService? balance,
    bool loadOnCreate = true,
  }) : _payments = payments ?? PaymentCoordinator(),
       marketService = market ?? MarketService(),
       _database = database ?? DBProvider.db,
       balanceService = balance ?? BalanceService() {
    _isSumaryTaxi = isSumaryTaxi;
    if (loadOnCreate) load();
  }

  List<CartSummaryModel> get summaries => _summaries;

  bool get inAsyncCall => _inAsyncCall;

  bool get isSumaryTaxi => _isSumaryTaxi;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  load() async {
    inAsyncCall = true;
    await loadDeliveryFee();
    await loadBalance();
    inAsyncCall = false;
  }

  List<ProductModel> _products = [];

  List<ProductModel> get products => _products;

  loadDeliveryFee() async {
    _products = await _database.loadProducts(
      _isSumaryTaxi ? TypesCompany.taxi : TypesCompany.store,
    );

    if (_products.isEmpty) return;

    double fromLgTaxi = 0.0, fromLtTaxi = 0.0;
    if (_isSumaryTaxi) {
      fromLtTaxi = _products[0].lt;
      fromLgTaxi = _products[0].lg;
    }

    var companyIds = [];
    for (ProductModel product in products) {
      if (!companyIds.contains(product.companyId)) {
        companyIds.add(product.companyId);
      }
    }
    _address = await _database.loadAddress();
    if (_address == null) {
      _summaries.clear();
      return;
    }
    List<FeeModel> fees = await marketService.deliveryCost(
      companyIds.join(','),
      _address!.location.x,
      _address!.location.y,
      isSumaryTaxi: _isSumaryTaxi,
      fromLtTaxi: fromLtTaxi,
      fromLgTaxi: fromLgTaxi,
    );
    _summaries.clear();
    for (FeeModel fee in fees) {
      _summaries.add(
        CartSummaryModel(
          fee: fee,
          products: products
              .where((pr) => pr.companyId == fee.companyId)
              .toList(),
        ),
      );
    }
  }

  AddressModel? _address;

  Future<bool> buy(int typePayment) async {
    if (_address == null || _summaries.isEmpty || inAsyncCall) return false;
    inAsyncCall = true;
    try {
      for (final summary in List<CartSummaryModel>.of(_summaries)) {
        if (!await marketService.buy(summary, _address!, typePayment))
          return false;
        await _database.deleteProductByCompany(summary.fee.companyId);
        _products.removeWhere(
          (product) => product.companyId == summary.fee.companyId,
        );
        _summaries.remove(summary);
      }
      return true;
    } finally {
      inAsyncCall = false;
    }
  }

  double get total {
    double total = 0.0;
    for (CartSummaryModel summary in summaries) {
      total += summary.total;
    }
    return total;
  }

  Future<bool> loadBalance() async {
    BalanceModel? balance = await balanceService.getBalance();
    if (balance == null) return false;
    money = balance.money;
    return true;
  }

  final PaymentCoordinator _payments;

  Future<bool> makePayment({
    required double money,
    required String currency,
    BuildContext? context,
  }) async {
    if (inAsyncCall) return false;
    inAsyncCall = true;
    try {
      return await _payments.pay(products, money, currency, context: context);
    } finally {
      inAsyncCall = false;
    }
  }
}
