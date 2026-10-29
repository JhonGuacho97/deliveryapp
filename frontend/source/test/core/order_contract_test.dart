import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:planck/src/models/address_model.dart';
import 'package:planck/src/models/cart_summary_model.dart';
import 'package:planck/src/models/fee_model.dart';
import 'package:planck/src/models/product_model.dart';

void main() {
  ProductModel product({int quantity = 2, double price = 3.25}) => ProductModel(
    id: 7,
    companyId: 2,
    companyName: 'Comercio',
    name: 'Producto',
    description: 'Descripción',
    type: 1,
    price: price,
    image: '',
    number: quantity,
  );
  FeeModel fee() => FeeModel(
    name: 'Comercio',
    marker: '',
    image: '',
    storeId: 5,
    companyId: 2,
    deliveryfee: 1.5,
    fromlt: -0.2,
    fromlg: -78.5,
  );

  test('cart total includes quantities and the delivery fee', () {
    final summary = CartSummaryModel(products: [product()], fee: fee());
    expect(summary.total, 8);
    expect(product().total, 6.5);
  });

  test('order payload preserves the NestJS API contract and coordinates', () {
    final summary = CartSummaryModel(
      products: [product(price: 3.333)],
      fee: fee(),
    );
    final address = AddressModel(
      id: 1,
      alias: ' Casa ',
      address: ' Calle 1 ',
      location: Location(x: -0.3, y: -78.6),
    );
    final body = jsonDecode(
      summary.toHttpBodyBuy(address, 5001) as String,
    ) as Map<String, dynamic>;
    expect(body['store'], {'id': 5});
    expect(body['address'], 'Calle 1');
    expect(body['note'], 'Casa');
    expect(body['payment'], 5001);
    expect(body['total'], 8.17);
    expect(body.containsKey('start'), isFalse); // Not accepted by OrderMarketDto.
    expect(body['location'], {'x': -0.3, 'y': -78.6});
    expect((body['products'] as List).single['total'], 6.67);
    expect(body['orderedAt'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
  });

  test('catalog products accept integer prices and default cart fields', () {
    final parsed = ProductModel.fromJson({
      'id': 1,
      'companyId': 2,
      'companyName': 'Comercio',
      'name': 'Producto',
      'description': '',
      'type': 1,
      'price': 4,
      'image': '',
    });
    expect(parsed.price, 4.0);
    expect(parsed.number, 1);
    expect(parsed.note, '');
    expect(parsed.toJson()['total'], 4.0);
  });
}
