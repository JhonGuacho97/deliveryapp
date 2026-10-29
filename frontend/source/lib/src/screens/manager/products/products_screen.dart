import 'package:flutter/material.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/models/company_product_model.dart';
import 'package:delivery_app/src/models/store_company_model.dart';
import 'package:delivery_app/src/screens/manager/company/company_controller.dart';
import 'package:delivery_app/src/screens/manager/product/product_screen.dart';
import 'package:delivery_app/src/screens/manager/products/products_controller.dart';
import 'package:delivery_app/src/screens/manager/requests/widget/restaurant_business.dart';
import 'package:delivery_app/src/services/store_manager_service.dart';
import 'package:delivery_app/src/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class RestaurantMenu extends StatelessWidget {
  const RestaurantMenu({super.key});
  @override
  Widget build(BuildContext context) {
    final company = context.watch<CompanyController>();
    final store = company.selected;
    if (store == null || company.hasError) return const RestaurantStoresState();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: RestaurantStorePicker(),
        ),
        Expanded(
          child: ChangeNotifierProvider(
            key: ValueKey(store.id),
            create: (_) => ProductsController(store, service: company.service),
            child: const ProductsPanel(),
          ),
        ),
      ],
    );
  }
}

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key, required this.storeCompany, this.service});
  final StoreCompanyModel storeCompany;
  final StoreManagerService? service;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => ProductsController(storeCompany, service: service),
    child: Scaffold(
      appBar: AppBar(title: Text(storeCompany.name)),
      body: const ProductsPanel(),
    ),
  );
}

class ProductsPanel extends StatelessWidget {
  const ProductsPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductsController>();
    final s = S.of(context);
    final theme = Theme.of(context);
    void edit(CompanyProductModel product) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductScreen(controller, product: product),
      ),
    );
    return Column(
      children: [
        if (controller.inAsyncCall) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.load,
            child: controller.hasError || controller.products.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      EmptyState(
                        icon: controller.hasError
                            ? Icons.wifi_off_outlined
                            : Icons.restaurant_menu_rounded,
                        title: controller.hasError
                            ? s.catalogErrorTitle
                            : s.menuEmptyTitle,
                        message: controller.hasError
                            ? s.catalogErrorMessage
                            : s.menuEmptyMessage,
                        actionLabel: controller.hasError ? s.retry : null,
                        onAction: controller.hasError ? controller.load : null,
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.products.length,
                    separatorBuilder: (_, index) => const Divider(),
                    itemBuilder: (_, index) {
                      final product = controller.products[index];
                      return ListTile(
                        key: ValueKey('menu-product-${product.id}'),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        title: Text(
                          product.name,
                          style: theme.textTheme.titleSmall,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${product.price.toStringAsFixed(kCoinDecimals)} $kCoin',
                                style: theme.textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.edit_outlined),
                        onTap: () => edit(product),
                      );
                    },
                  ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const ValueKey('new-menu-product'),
                onPressed: () => edit(CompanyProductModel(id: 0)),
                icon: const Icon(Icons.add_rounded),
                label: Text(s.bNewProduct),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
