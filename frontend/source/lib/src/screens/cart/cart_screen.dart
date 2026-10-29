import 'package:flutter/material.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';
import 'package:delivery_app/src/screens/cart/cart_controller.dart';
import 'package:delivery_app/src/screens/cart/widget/cart_body.dart';
import 'package:delivery_app/src/screens/cart_summary/cart_summary_screen.dart';
import 'package:delivery_app/src/screens/login/login_screen.dart';
import 'package:delivery_app/src/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => CartController(),
    child: Consumer<CartController>(
      builder: (context, controller, _) {
        final s = S.of(context);
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(s.cartTitle)),
          body: controller.loading
              ? const Center(child: CircularProgressIndicator())
              : controller.products.isEmpty || controller.hasError
              ? SingleChildScrollView(
                  child: EmptyState(
                    icon: controller.hasError
                        ? Icons.error_outline_rounded
                        : Icons.shopping_bag_outlined,
                    title: controller.hasError
                        ? s.errUnknown
                        : s.cartEmptyTitle,
                    message: controller.hasError
                        ? s.catalogErrorMessage
                        : s.cartEmptyMessage,
                    actionLabel: controller.hasError ? s.retry : s.explore,
                    onAction: controller.hasError
                        ? controller.loadProducts
                        : () => Navigator.pop(context),
                  ),
                )
              : CartBody(products: controller.products),
          bottomNavigationBar:
              controller.loading ||
                  controller.products.isEmpty ||
                  controller.hasError
              ? null
              : SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(s.subtotal)),
                            Text(
                              '${controller.subtotal.toStringAsFixed(kCoinDecimals)} $kCoin',
                              key: const ValueKey('cart-subtotal'),
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.shippingAtCheckout,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          key: const ValueKey('review-order'),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if (PreferencesProvider().isAuth) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CartSummaryScreen(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            }
                          },
                          child: Text(s.reviewOrder),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    ),
  );
}
