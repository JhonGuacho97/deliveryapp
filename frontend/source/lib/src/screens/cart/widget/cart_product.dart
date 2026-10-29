import 'package:flutter/material.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/models/product_model.dart';
import 'package:planck/src/screens/cart/cart_controller.dart';
import 'package:planck/src/screens/cart/widget/note_input.dart';
import 'package:planck/src/screens/main/tab1_controller.dart';
import 'package:planck/src/screens/store/store_controller.dart';
import 'package:planck/src/widgets/icon_cart/icon_cart_controller.dart';
import 'package:provider/provider.dart';

class CartProduct extends StatelessWidget {
  const CartProduct({super.key, required this.product});
  final ProductModel product;
  @override
  Widget build(BuildContext context) {
    final controller = context.read<CartController>();
    final theme = Theme.of(context);
    final s = S.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        product.companyName,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: s.removeProduct,
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () async {
                    final cart = context.read<IconCartController>();
                    final catalog = context.read<Tab1Controller>();
                    final store = context.read<StoreController>();
                    await controller.removeProduct(product);
                    await cart.count();
                    catalog.setProducts(product);
                    store.setProducts(product);
                  },
                ),
              ],
            ),
            if (product.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(product.description, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.outlined(
                      tooltip: s.decreaseQuantity,
                      icon: const Icon(Icons.remove_rounded),
                      onPressed: product.number <= 1
                          ? null
                          : () {
                              product.number--;
                              controller.updateProduct(product);
                            },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Semantics(
                        label: s.quantity,
                        child: Text(
                          '${product.number}',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ),
                    IconButton.outlined(
                      tooltip: s.increaseQuantity,
                      icon: const Icon(Icons.add_rounded),
                      onPressed: () {
                        product.number++;
                        controller.updateProduct(product);
                      },
                    ),
                  ],
                ),
                Text(
                  '${product.total.toStringAsFixed(kCoinDecimals)} $kCoin',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            NoteInput(product: product, cartController: controller),
          ],
        ),
      ),
    );
  }
}
