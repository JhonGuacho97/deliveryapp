import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:planck/src/widgets/delivery_glass_scaffold.dart';
import 'package:planck/constants/code_error_constant.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/manager/company/company_controller.dart';
import 'package:planck/src/screens/manager/requests/requests_controller.dart';
import 'package:planck/src/screens/manager/requests/widget/content_requests.dart';
import 'package:planck/src/screens/manager/requests/widget/restaurant_business.dart';
import 'package:planck/src/screens/manager/products/products_screen.dart';
import 'package:planck/src/screens/profile/profile_screen.dart';
import 'package:planck/src/screens/welcome/welcome_screen.dart';
import 'package:planck/src/services/store_manager_service.dart';
import 'package:provider/provider.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key, this.storeService});
  final StoreManagerService? storeService;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => CompanyController(service: storeService),
    child: const _RestaurantShell(),
  );
}

class _RestaurantShell extends StatefulWidget {
  const _RestaurantShell();
  @override
  State<_RestaurantShell> createState() => _RestaurantShellState();
}

class _RestaurantShellState extends State<_RestaurantShell>
    with WidgetsBindingObserver {
  Timer? _refresh;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _validate();
        _startRefresh();
      }
    });
  }

  void _startRefresh() {
    _refresh?.cancel();
    _refresh = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) {
        final controller = context.read<RequestsController>();
        if (controller.currentScreen == 0 && !controller.inAsyncCall)
          controller.loadRequests(silent: true);
      }
    });
  }

  Future<void> _validate() async {
    final code = await context.read<RequestsController>().checkSession();
    if (!mounted) return;
    if (code == CodeError.unauthorized && !PreferencesProvider().isGuest) {
      await PreferencesProvider().clean();
      if (mounted)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (_) => false,
        );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _validate();
      context.read<RequestsController>().loadRequests(silent: true);
      _startRefresh();
    } else {
      _refresh?.cancel();
    }
  }

  @override
  void dispose() {
    _refresh?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RequestsController>();
    final s = S.of(context);
    return DeliveryGlassScaffold(
      appBar: AppBar(
        title: Text(
          controller.currentScreen == 0
              ? (controller.showHistory ? s.tRequestsHistory : s.kitchenTitle)
              : controller.currentScreen == 1
              ? s.restaurantMenu
              : s.restaurantBusiness,
        ),
        actions: [
          if (controller.currentScreen == 0)
            IconButton(
              tooltip: controller.showHistory
                  ? s.viewActiveOrders
                  : s.openHistory,
              onPressed: controller.toggleHistory,
              icon: Icon(
                controller.showHistory
                    ? Icons.restaurant_menu_rounded
                    : Icons.history_rounded,
              ),
            ),
          IconButton(
            tooltip: s.account,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen()),
            ),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: IndexedStack(
        index: controller.currentScreen,
        children: const [
          ContentRequests(),
          RestaurantMenu(),
          RestaurantBusiness(),
        ],
      ),
      selectedIndex: controller.currentScreen,
      onTabSelected: (index) {
        controller.currentScreen = index;
        if (index == 0)
          controller.loadRequests();
        else
          context.read<CompanyController>().load();
      },
      tabs: [
        GlassTab(
          icon: const Icon(Icons.receipt_long_outlined),
          activeIcon: const Icon(Icons.receipt_long_rounded),
          label: s.tRequests,
        ),
        GlassTab(
          icon: const Icon(Icons.restaurant_menu_outlined),
          activeIcon: const Icon(Icons.restaurant_menu_rounded),
          label: s.restaurantMenu,
        ),
        GlassTab(
          icon: const Icon(Icons.storefront_outlined),
          activeIcon: const Icon(Icons.storefront_rounded),
          label: s.restaurantBusiness,
        ),
      ],
    );
  }
}
