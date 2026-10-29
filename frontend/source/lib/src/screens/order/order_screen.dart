import 'package:flutter/material.dart';
import 'package:delivery_app/src/models/order_model.dart';
import 'package:delivery_app/src/screens/order/order_controller.dart';
import 'package:delivery_app/src/screens/order/widget/content_order.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatelessWidget {
  final OrderModel order;

  const OrderScreen(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OrderController>(
      create: (_) => OrderController(order),
      child: Scaffold(
        appBar: AppBar(title: Text(order.store.name)),
        body: Consumer<OrderController>(
          builder: (context, orderController, child) =>
              ContentOrder(orderController),
        ),
      ),
    );
  }
}
