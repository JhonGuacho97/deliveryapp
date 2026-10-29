import 'package:flutter/material.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:delivery_app/src/screens/cart/widget/cart_product.dart';

class CartBody extends StatelessWidget {
  final List<ProductModel> products;

  const CartBody({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      itemCount: products.length,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.all(kDefaultPadding * 0.3),
        child: CartProduct(
          key: ValueKey(products[index].id),
          product: products[index],
        ),
      ),
    );
  }
}
