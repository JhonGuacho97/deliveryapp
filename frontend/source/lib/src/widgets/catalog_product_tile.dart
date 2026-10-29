import 'package:flutter/material.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/constants/types_constant.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:delivery_app/src/provider/db_provider.dart';
import 'package:delivery_app/src/screens/main/tab1_controller.dart';
import 'package:delivery_app/src/screens/store/store_controller.dart';
import 'package:delivery_app/src/widgets/catalog_image.dart';
import 'package:delivery_app/src/widgets/icon_cart/icon_cart_controller.dart';
import 'package:provider/provider.dart';

class CatalogProductTile extends StatefulWidget {
  const CatalogProductTile({
    super.key,
    required this.product,
    this.inStore = false,
    this.database,
  });
  final ProductModel product;
  final bool inStore;
  final DBProvider? database;

  static double heightFor(
    BuildContext context,
    double width, {
    bool inStore = false,
  }) {
    final scaler = MediaQuery.textScalerOf(context);
    return width * .88 +
        40 +
        scaler.scale(16) * 3.9 +
        (inStore ? 0 : scaler.scale(13) * 1.4 + 6);
  }

  @override
  State<CatalogProductTile> createState() => _CatalogProductTileState();
}

class _CatalogProductTileState extends State<CatalogProductTile> {
  bool _busy = false;
  String get _price =>
      '${widget.product.price.toStringAsFixed(kCoinDecimals)} $kCoin';

  Future<bool> _toggle() async {
    if (_busy) return false;
    final product = widget.product;
    final cart = context.read<IconCartController>();
    final catalog = context.read<Tab1Controller>();
    final store = widget.inStore ? context.read<StoreController>() : null;
    setState(() => _busy = true);
    try {
      if (product.isInCart) {
        await (widget.database ?? DBProvider.db).deleteProduct(product);
      } else {
        await (widget.database ?? DBProvider.db).createProduct(
          product,
          TypesCompany.store,
        );
      }
      product.isInCart = !product.isInCart;
      await cart.count();
      catalog.setProducts(product);
      store?.setProducts(product);
      return true;
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(S.of(context).errUnknown)));
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _details() async {
    var saving = false;
    final product = widget.product;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, update) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              20 + MediaQuery.paddingOf(sheetContext).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        S.of(context).dishDetails,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    CloseButton(onPressed: () => Navigator.pop(sheetContext)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: CatalogImage(image: product.image),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  product.companyName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(product.description),
                ],
                const SizedBox(height: 20),
                Text(_price, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                FilledButton.icon(
                  key: ValueKey('dish-detail-cart-${product.id}'),
                  onPressed: saving
                      ? null
                      : () async {
                          update(() => saving = true);
                          final saved = await _toggle();
                          if (!sheetContext.mounted) return;
                          if (saved)
                            Navigator.pop(sheetContext);
                          else
                            update(() => saving = false);
                        },
                  icon: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          product.isInCart
                              ? Icons.remove_shopping_cart_outlined
                              : Icons.add_shopping_cart_rounded,
                        ),
                  label: Text(
                    product.isInCart
                        ? S.of(context).removeFromCart
                        : S.of(context).addToCart,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product, theme = Theme.of(context), s = S.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('dish-detail-${p.id}'),
        onTap: _details,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1 / .88,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CatalogImage(image: p.image),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filled(
                      key: ValueKey('cart-product-${p.id}'),
                      tooltip: p.isInCart ? s.removeFromCart : s.addToCart,
                      onPressed: _busy ? null : _toggle,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        backgroundColor: p.isInCart
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.primary,
                        foregroundColor: p.isInCart
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onPrimary,
                        side: BorderSide(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      icon: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              p.isInCart
                                  ? Icons.check_rounded
                                  : Icons.add_rounded,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  if (!widget.inStore) ...[
                    const SizedBox(height: 6),
                    Text(
                      p.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
