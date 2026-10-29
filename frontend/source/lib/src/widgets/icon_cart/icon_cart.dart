import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/cart/cart_screen.dart';
import 'package:delivery_app/src/widgets/icon_cart/icon_cart_controller.dart';
import 'package:provider/provider.dart';

class IconCart extends StatelessWidget {
  const IconCart({super.key});

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<IconCartController>(context).items;
    return IconButton(
      tooltip: S.of(context).viewCart,
      icon: Badge(
        isLabelVisible: items > 0,
        label: Text('$items'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.shopping_bag_outlined),
      ),
      onPressed: () => _goToCartScreen(context),
    );
  }

  _goToCartScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartScreen()),
    );
  }
}
