import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/constants/status_constant.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/main/tab1_controller.dart';
import 'package:planck/src/screens/main/tab2_controller.dart';
import 'package:planck/src/screens/main/tab_main_controller.dart';
import 'package:planck/src/screens/order/order_controller.dart';
import 'package:planck/src/screens/order/widget/floating_head.dart';
import 'package:planck/src/screens/order/widget/floating_sheet_bottom.dart';
import 'package:planck/src/screens/order/widget/order_progress.dart';
import 'package:planck/src/screens/order/widget/info_product.dart';
import 'package:planck/src/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class ContentOrder extends StatefulWidget {
  const ContentOrder(this.orderController, {super.key});
  final OrderController orderController;

  @override
  State<ContentOrder> createState() => _ContentOrderState();
}

class _ContentOrderState extends State<ContentOrder>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        widget.orderController.refreshOrder();
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
    if (!widget.orderController.mapsEnabled) {
      final order = widget.orderController.order;
      final theme = Theme.of(context);
      return Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async => widget.orderController.refreshOrder(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  S.of(context).orderNumber(order.id),
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: OrderProgress(
                      status: order.status,
                      preparationStatus: order.preparationStatus,
                      preparationMinutes: order.preparationMinutes,
                      companyType: order.store.company.type,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.map_outlined),
                        const SizedBox(height: 8),
                        Text(S.of(context).trackingMapUnavailable),
                        if (widget.orderController.isTrackingDelivery) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.orderController.courierPosition == null
                                ? S.of(context).trackingWaitingLocation
                                : S.of(context).trackingLocationUpdated,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(S.of(context).lDeliveryAddress),
                  subtitle: Text(order.address),
                ),
                if (widget.orderController.isTrackingDelivery)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconChat(widget.orderController),
                  ),
                const Divider(),
                InfoProduct(order: order),
                const Divider(),
                Text(
                  '${S.of(context).lTotal} · ${order.total.toStringAsFixed(kCoinDecimals)} $kCoin',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          if (order.status == StatusOrder.delivered ||
              order.status == StatusOrder.cancelled)
            ScoreDialog(widget.orderController),
        ],
      );
    }
    return Stack(
      children: [
        GoogleMap(
          minMaxZoomPreference: const MinMaxZoomPreference(3, 16),
          markers: widget.orderController.markers,
          mapType: MapType.normal,
          buildingsEnabled: false,
          compassEnabled: true,
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
          initialCameraPosition: widget.orderController.initialCameraPosition,
          onMapCreated: widget.orderController.onMapCreated,
        ),
        if (widget.orderController.isTrackingDelivery)
          FloatingHead(orderController: widget.orderController),
        FloatingSheetBottom(orderController: widget.orderController),
        widget.orderController.order.status == StatusOrder.delivered ||
                widget.orderController.order.status == StatusOrder.cancelled
            ? ScoreDialog(widget.orderController)
            : Container(),
      ],
    );
  }
}

class ScoreDialog extends StatelessWidget {
  const ScoreDialog(this.orderController, {super.key});

  final OrderController orderController;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: Color.fromARGB(170, 0, 0, 0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              orderController.order.status == StatusOrder.cancelled
                  ? S.of(context).lStatusOrderCancelled
                  : S.of(context).lStatusOrderDelivered,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kDefaultPadding * 2),
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 5.0),
              itemSize: 50,
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (raiting) {
                orderController.order.scoreClient = raiting;
              },
            ),
            const SizedBox(height: kDefaultPadding * 2),
            PrimaryButton(
              text: S.of(context).bQualify,
              onPressed: () async {
                final tab2Controller = Provider.of<Tab2Controller>(
                  context,
                  listen: false,
                );
                Provider.of<Tab1Controller>(context, listen: false).load();
                Provider.of<TabManController>(
                  context,
                  listen: false,
                ).currentScreen = 0;
                Navigator.of(context).popUntil((route) => route.isFirst);
                await orderController.qualify();
                tab2Controller.loadOrders();
              },
            ),
          ],
        ),
      ),
    );
  }
}
