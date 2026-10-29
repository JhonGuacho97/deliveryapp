import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/main/tab1_controller.dart';
import 'package:delivery_app/src/screens/main/widget/filter_input.dart';
import 'package:delivery_app/src/screens/main/widget/list_category.dart';
import 'package:delivery_app/src/screens/main/widget/list_company.dart';
import 'package:delivery_app/src/screens/main/widget/list_products.dart';
import 'package:delivery_app/src/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class Tab1Screen extends StatelessWidget {
  const Tab1Screen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<Tab1Controller>();
    final s = S.of(context);
    final theme = Theme.of(context);
    Widget? empty;
    if (!controller.inAsyncCall) {
      if (controller.needsAddress) {
        empty = EmptyState(
          icon: Icons.location_on_outlined,
          title: s.chooseAddressTitle,
          message: s.chooseAddressMessage,
        );
      } else if (controller.hasError) {
        empty = EmptyState(
          icon: Icons.wifi_off_outlined,
          title: s.catalogErrorTitle,
          message: s.catalogErrorMessage,
          actionLabel: s.retry,
          onAction: controller.load,
        );
      } else if (controller.companies.isEmpty && controller.products.isEmpty) {
        empty = EmptyState(
          icon: controller.hasFilters
              ? Icons.search_off_outlined
              : Icons.storefront_outlined,
          title: controller.hasFilters ? s.noResultsTitle : s.noStoresTitle,
          message: controller.hasFilters
              ? s.noResultsMessage
              : s.noStoresMessage,
          actionLabel: controller.hasFilters ? s.clearSearch : s.retry,
          onAction: controller.hasFilters
              ? controller.clearFilters
              : controller.load,
        );
      }
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: CustomScrollView(
        key: const PageStorageKey('client-catalog'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (controller.inAsyncCall)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.homeGreeting, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(s.homeSubtitle, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 24),
                  FilterInput(tab1Controller: controller),
                  const SizedBox(height: 16),
                  ListCategory(controller.categories),
                ],
              ),
            ),
          ),
          if (empty != null)
            SliverFillRemaining(hasScrollBody: false, child: empty),
          if (empty == null && controller.products.isNotEmpty) ...[
            _heading(
              context,
              controller.query.isEmpty ? s.featuredProducts : s.matchingDishes,
            ),
            SliverToBoxAdapter(child: ListProducts(controller.products)),
          ],
          if (empty == null && controller.companies.isNotEmpty) ...[
            _heading(
              context,
              controller.query.isEmpty ? s.nearbyStores : s.matchingRestaurants,
            ),
            SliverToBoxAdapter(child: ListCompany(controller.companies)),
          ],
          SliverToBoxAdapter(
            child: SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
          ),
        ],
      ),
    );
  }

  Widget _heading(BuildContext context, String label) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
    sliver: SliverToBoxAdapter(
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    ),
  );
}
