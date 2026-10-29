import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/cart/cart_screen.dart';
import 'package:delivery_app/src/widgets/icon_cart/icon_cart_controller.dart';
import 'package:provider/provider.dart';

class ClientCartBar extends StatelessWidget {
  const ClientCartBar({super.key});
  @override
  Widget build(BuildContext context) {
    final items = context.watch<IconCartController>().items;
    if (items == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: FilledButton(
        key: const ValueKey('client-cart-bar'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CartScreen()),
        ),
        child: Row(
          children: [
            const Icon(Icons.shopping_bag_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.of(context).viewCart),
                  Text(
                    S.of(context).cartItemCount(items),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
