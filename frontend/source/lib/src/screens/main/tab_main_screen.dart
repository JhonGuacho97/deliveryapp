import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:planck/constants/code_error_constant.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/main/tab1_controller.dart';
import 'package:planck/src/screens/main/account_screen.dart';
import 'package:planck/src/screens/main/tab1_screen.dart';
import 'package:planck/src/screens/main/tab2_controller.dart';
import 'package:planck/src/screens/main/tab2_screen.dart';
import 'package:planck/src/screens/main/tab_main_controller.dart';
import 'package:planck/src/screens/welcome/welcome_screen.dart';
import 'package:planck/src/widgets/address_dropdown/address_dropdown_controller.dart';
import 'package:planck/src/widgets/address_dropdown/address_dropdown.dart';
import 'package:planck/src/widgets/client_cart_bar.dart';
import 'package:planck/src/widgets/delivery_glass_scaffold.dart';
import 'package:planck/src/widgets/icon_cart/icon_cart.dart';
import 'package:provider/provider.dart';

class TabMainScreen extends StatelessWidget {
  const TabMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tabManController = Provider.of<TabManController>(context);
    return DeliveryGlassScaffold(
      appBar: AppBar(
        toolbarHeight: tabManController.currentScreen == 0 ? 72 : null,
        titleSpacing: 20,
        title: tabManController.currentScreen == 0
            ? const AddressDropdown(isScreenMain: true)
            : Text(
                tabManController.currentScreen == 1
                    ? S.of(context).tAppBarOrders
                    : S.of(context).account,
              ),
        actions: const [IconCart()],
      ),
      body: _Screens(tabManController),
      bottomAccessory: const ClientCartBar(),
      selectedIndex: tabManController.currentScreen,
      tabs: [
        GlassTab(
          icon: const Icon(Icons.explore_outlined),
          activeIcon: const Icon(Icons.explore_rounded),
          label: S.of(context).explore,
        ),
        GlassTab(
          icon: const Icon(Icons.receipt_long_outlined),
          activeIcon: const Icon(Icons.receipt_long_rounded),
          label: S.of(context).tab2,
        ),
        GlassTab(
          icon: const Icon(Icons.person_outline_rounded),
          activeIcon: const Icon(Icons.person_rounded),
          label: S.of(context).account,
        ),
      ],
      onTabSelected: (i) {
        tabManController.currentScreen = i;
        if (i == 1) {
          Provider.of<Tab2Controller>(context, listen: false).loadOrders();
        } else if (i == 0) {
          Provider.of<Tab1Controller>(context, listen: false).load();
        }
      },
    );
  }
}

class _Screens extends StatefulWidget {
  const _Screens(this.tabManController);

  final TabManController tabManController;

  @override
  State<_Screens> createState() => _ScreensState();
}

class _ScreensState extends State<_Screens> with WidgetsBindingObserver {
  final pref = PreferencesProvider();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => validateSession());
  }

  validateSession() async {
    Provider.of<AddressDropdownController>(
      context,
      listen: false,
    ).loadAddress();
    final navigator = Navigator.of(context);
    final codeError = await widget.tabManController.checkSession();
    if (!mounted) return;
    if (codeError == CodeError.unauthorized && !pref.isGuest) {
      await PreferencesProvider().clean();
      if (!mounted) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (Route<dynamic> route) {
          return false;
        },
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        validateSession();
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.tabManController.currentScreen,
      children: const [Tab1Screen(), Tab2Screen(), AccountScreen()],
    );
  }
}
