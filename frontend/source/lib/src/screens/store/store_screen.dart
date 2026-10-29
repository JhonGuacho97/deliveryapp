import 'package:flutter/material.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/models/company_model.dart';
import 'package:delivery_app/src/screens/store/store_controller.dart';
import 'package:delivery_app/src/widgets/catalog_image.dart';
import 'package:delivery_app/src/widgets/catalog_product_tile.dart';
import 'package:delivery_app/src/widgets/client_cart_bar.dart';
import 'package:delivery_app/src/widgets/empty_state.dart';
import 'package:delivery_app/src/widgets/icon_cart/icon_cart.dart';
import 'package:provider/provider.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen(this.company, {super.key});
  final CompanyModel company;
  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _search = TextEditingController();
  final _focus = FocusNode();
  final _searchKey = GlobalKey();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final c = context.read<StoreController>();
      if (!c.hasCompany ||
          c.company.id != widget.company.id ||
          c.company.storeId != widget.company.storeId)
        c.company = widget.company;
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _findDish() async {
    if (_searchKey.currentContext == null && _scroll.hasClients) {
      await _scroll.animateTo(
        (_scroll.offset + MediaQuery.sizeOf(context).height * .7).clamp(
          0,
          _scroll.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    if (!mounted) return;
    final fieldContext = _searchKey.currentContext;
    if (fieldContext != null)
      await Scrollable.ensureVisible(
        fieldContext,
        duration: const Duration(milliseconds: 250),
        alignment: .1,
      );
    if (mounted) _focus.requestFocus();
  }

  void _information() {
    final company = widget.company, s = S.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.restaurantInformation,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const CloseButton(),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  company.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                if (company.address.isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(company.address),
                  ),
                if (company.contact.isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.phone_outlined),
                    title: SelectableText(company.contact),
                  ),
                if (company.open.length >= 5 && company.close.length >= 5)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule_outlined),
                    title: Text(
                      '${company.open.substring(0, 5)} – ${company.close.substring(0, 5)}',
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
    final c = context.watch<StoreController>();
    final company = widget.company,
        theme = Theme.of(context),
        s = S.of(context);
    final products = c.visibleProducts;
    if (_search.text.trim() != c.query)
      _search.value = TextEditingValue(
        text: c.query,
        selection: TextSelection.collapsed(offset: c.query.length),
      );
    final scale = (MediaQuery.textScalerOf(context).scale(16) / 16 - 1).clamp(
      0.0,
      2.0,
    );
    final cover = company.image.isNotEmpty
        ? company.image
        : c.products.isNotEmpty
        ? c.products.first.image
        : '';
    return Scaffold(
      bottomNavigationBar: const SafeArea(top: false, child: ClientCartBar()),
      body: RefreshIndicator(
        onRefresh: () => c.openCompany(company),
        child: CustomScrollView(
          controller: _scroll,
          key: ValueKey('restaurant-menu-${company.storeId}'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppBar(
              expandedHeight: 224,
              pinned: true,
              titleSpacing: 8,
              leading: Padding(
                padding: const EdgeInsets.all(4),
                child: IconButton.filledTonal(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
              actions: [
                IconButton.filledTonal(
                  tooltip: s.searchMenu,
                  onPressed: _findDish,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                  ),
                  icon: const Icon(Icons.search_rounded),
                ),
                const SizedBox(width: 4),
                IconButtonTheme(
                  data: IconButtonThemeData(
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
                    ),
                  ),
                  child: const IconCart(),
                ),
                const SizedBox(width: 12),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final collapsed =
                      constraints.maxHeight <=
                      kToolbarHeight + MediaQuery.paddingOf(context).top + 4;
                  return FlexibleSpaceBar(
                    titlePadding: const EdgeInsetsDirectional.only(
                      start: 64,
                      end: 120,
                      bottom: 16,
                    ),
                    title: collapsed
                        ? Text(
                            company.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          )
                        : null,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CatalogImage(image: cover, restaurant: true),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x30000000), Colors.transparent],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            company.name,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                        IconButton(
                          tooltip: s.restaurantInformation,
                          onPressed: _information,
                          icon: const Icon(Icons.info_outline_rounded),
                        ),
                      ],
                    ),
                    if (company.address.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(company.address, style: theme.textTheme.bodySmall),
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InformationChip(
                          icon: Icons.circle,
                          text: company.isOpen ? s.openStore : s.lClosed,
                          active: company.isOpen,
                        ),
                        _InformationChip(
                          icon: Icons.delivery_dining_rounded,
                          text: c.hasDeliveryFee
                              ? '${s.lDeliveryFee} · ${c.deliveryFee.toStringAsFixed(kCoinDecimals)} $kCoin'
                              : s.shippingAtCheckout,
                        ),
                        if (company.open.length >= 5 &&
                            company.close.length >= 5)
                          _InformationChip(
                            icon: Icons.schedule_rounded,
                            text:
                                '${company.open.substring(0, 5)} – ${company.close.substring(0, 5)}',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _MenuHeader(
                height: 128 + scale * 30,
                child: Material(
                  color: theme.scaffoldBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 56 + scale * 14,
                          child: TextField(
                            key: _searchKey,
                            controller: _search,
                            focusNode: _focus,
                            maxLength: 120,
                            textInputAction: TextInputAction.search,
                            onChanged: c.search,
                            onTapOutside: (_) => _focus.unfocus(),
                            decoration: InputDecoration(
                              hintText: s.searchMenu,
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: c.query.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: s.clearSearch,
                                      icon: const Icon(Icons.close_rounded),
                                      onPressed: () {
                                        _search.clear();
                                        c.search('');
                                      },
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 48 + scale * 16,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (final entry in {
                                MenuPriceFilter.all: s.fullMenu,
                                MenuPriceFilter.upToFive: s.menuUpTo(
                                  '5 $kCoin',
                                ),
                                MenuPriceFilter.aboveFive: s.menuAbove(
                                  '5 $kCoin',
                                ),
                              }.entries)
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    end: 8,
                                  ),
                                  child: ChoiceChip(
                                    label: Text(entry.value),
                                    selected: c.priceFilter == entry.key,
                                    showCheckmark: false,
                                    onSelected: (_) =>
                                        c.priceFilter = entry.key,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (c.inAsyncCall)
              const SliverToBoxAdapter(
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (c.hasError && products.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.wifi_off_outlined,
                      color: theme.colorScheme.error,
                    ),
                    title: Text(s.catalogErrorTitle),
                    trailing: IconButton(
                      tooltip: s.retry,
                      onPressed: c.loadProducts,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ),
                ),
              ),
            if (products.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.restaurantMenu,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        products.length == 1
                            ? s.menuSingleItem
                            : s.menuItems(products.length),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  final available = constraints.crossAxisExtent - 40;
                  final columns = scale >= .6 && available < 360
                      ? 1
                      : available >= 900
                      ? 4
                      : available >= 650
                      ? 3
                      : 2;
                  final width = (available - (columns - 1) * 12) / columns;
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 14,
                        mainAxisExtent: CatalogProductTile.heightFor(
                          context,
                          width,
                          inStore: true,
                        ),
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, index) => CatalogProductTile(
                        key: ValueKey(products[index].id),
                        product: products[index],
                        inStore: true,
                      ),
                    ),
                  );
                },
              ),
            ] else if (!c.inAsyncCall)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: c.hasError
                      ? Icons.wifi_off_outlined
                      : Icons.search_off_rounded,
                  title: c.hasError
                      ? s.catalogErrorTitle
                      : c.products.isEmpty
                      ? s.storeEmptyTitle
                      : s.noResultsTitle,
                  message: c.hasError
                      ? s.catalogErrorMessage
                      : c.products.isEmpty
                      ? s.storeEmptyMessage
                      : s.noResultsMessage,
                  actionLabel: c.hasError
                      ? s.retry
                      : c.products.isNotEmpty
                      ? s.clearSearch
                      : null,
                  onAction: c.hasError ? c.loadProducts : c.clearFilters,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}

class _InformationChip extends StatelessWidget {
  const _InformationChip({
    required this.icon,
    required this.text,
    this.active = false,
  });
  final IconData icon;
  final String text;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: icon == Icons.circle ? 8 : 16,
            color: active
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: active ? theme.colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuHeader extends SliverPersistentHeaderDelegate {
  _MenuHeader({required this.height, required this.child});
  final double height;
  final Widget child;
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;
  @override
  bool shouldRebuild(covariant _MenuHeader oldDelegate) => true;
}
