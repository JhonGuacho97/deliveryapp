import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/login/login_screen.dart';
import 'package:planck/src/screens/main/tab2_controller.dart';
import 'package:planck/src/screens/main/widget/list_order.dart';
import 'package:planck/src/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class Tab2Screen extends StatelessWidget {
  const Tab2Screen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<Tab2Controller>();
    final s = S.of(context);
    final guest = !PreferencesProvider().isAuth;
    return RefreshIndicator(
      onRefresh: controller.loadOrders,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (controller.inAsyncCall)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Text(
                s.sTOrders,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          if (guest || controller.orders.isEmpty || controller.hasError)
            SliverFillRemaining(
              hasScrollBody: false,
              child: controller.inAsyncCall
                  ? const Center(child: CircularProgressIndicator())
                  : EmptyState(
                      icon: controller.hasError
                          ? Icons.wifi_off_outlined
                          : Icons.receipt_long_outlined,
                      title: controller.hasError
                          ? s.ordersErrorTitle
                          : s.ordersEmptyTitle,
                      message: guest
                          ? s.ordersGuestMessage
                          : controller.hasError
                          ? s.ordersErrorMessage
                          : s.ordersEmptyMessage,
                      actionLabel: guest
                          ? s.bSignin
                          : controller.hasError
                          ? s.retry
                          : null,
                      onAction: guest
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            )
                          : controller.hasError
                          ? controller.loadOrders
                          : null,
                    ),
            )
          else
            SliverToBoxAdapter(child: ListOrder(controller.orders)),
          SliverToBoxAdapter(
            child: SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
          ),
        ],
      ),
    );
  }
}
