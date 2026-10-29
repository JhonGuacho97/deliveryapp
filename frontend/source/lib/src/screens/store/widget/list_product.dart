import 'package:flutter/material.dart';
import 'package:planck/src/models/product_model.dart';
import 'package:planck/src/widgets/catalog_product_tile.dart';

class ListProduct extends StatelessWidget {
  const ListProduct(this.products, {super.key});
  final List<ProductModel> products;
  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
    itemCount: products.length,
    separatorBuilder: (_, index) => const Divider(height: 1),
    itemBuilder: (_, index) => CatalogProductTile(
      key: ValueKey(products[index].id),
      product: products[index],
      inStore: true,
    ),
  );
}
