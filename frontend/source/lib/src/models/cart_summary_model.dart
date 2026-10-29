import 'dart:convert';

import 'package:planck/constants/constants.dart';
import 'package:planck/src/models/address_model.dart';
import 'package:planck/src/models/fee_model.dart';
import 'package:planck/src/models/product_model.dart';

class CartSummaryModel {
  CartSummaryModel({required this.products, required this.fee});

  double get total {
    double total = 0.0;
    for (var product in products) {
      total += product.total;
    }
    return total + fee.deliveryfee;
  }

  List<ProductModel> products;
  FeeModel fee;

  Object toHttpBodyBuy(AddressModel address, int payment) => jsonEncode({
    "store": {"id": fee.storeId},
    "note": address.alias.trim(),
    "address": address.address.trim(),
    "products": List<dynamic>.from(products.map((x) => x.toJson())),
    "location": address.location.toJson(), //Destination
    "total": double.parse(total.toStringAsFixed(kCoinDecimals)),
    "deliveryFee": double.parse(fee.deliveryfee.toStringAsFixed(kCoinDecimals)),
    //Date in the client's time zone.
    "orderedAt": DateTime.now().toString().split(' ')[0],
    "payment": payment,
  });
}
