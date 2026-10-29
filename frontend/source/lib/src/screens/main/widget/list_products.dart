import 'package:flutter/material.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:delivery_app/src/widgets/catalog_product_tile.dart';

class ListProducts extends StatelessWidget {
  const ListProducts(this.products, {super.key});
  final List<ProductModel> products;
  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width * .43).clamp(148.0, 200.0);
    return SizedBox(
      height: CatalogProductTile.heightFor(context, width),
      child: ListView.separated(
        key: const PageStorageKey('catalog-dish-carousel'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) => SizedBox(
          width: width,
          child: CatalogProductTile(
            key: ValueKey(products[index].id),
            product: products[index],
          ),
        ),
      ),
    );
  }
}
