import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/common/status_label.dart';
import 'package:delivery_app/src/screens/order/order_controller.dart';
import 'package:delivery_app/src/widgets/avatar_image.dart';

class FloatingHead extends StatelessWidget {
  const FloatingHead({super.key, required this.orderController});

  final OrderController orderController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.all(20),
        constraints: const BoxConstraints(minHeight: 70),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(18)),
        ),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: orderController.centerMap,
              child: SizedBox(
                width: 48,
                height: 48,
                child: ClipOval(
                  child: AvatarImage(
                    image: orderController.order.deliveryman!.image,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${S.of(context).lOrderBy}: ${orderController.order.deliveryman!.fullName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    statusOrderLabel(
                      orderController.order.status,
                      orderController.order.store.company.type,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
