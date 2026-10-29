import 'package:flutter/material.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/common/status_label.dart';
import 'package:planck/src/models/order_model.dart';
import 'package:planck/src/screens/order/order_screen.dart';

class ListOrder extends StatelessWidget {
  const ListOrder(this.orders, {super.key});
  final List<OrderModel> orders;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (final order in orders)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OrderScreen(order)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                order.store.name,
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (order.notificationsClient > 0)
                              Badge(
                                label: Text('${order.notificationsClient}'),
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 20,
                                ),
                              )
                            else
                              const Icon(Icons.chevron_right_rounded, size: 20),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          S.of(context).orderNumber(order.id),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusOrderLabel(
                              order.status,
                              order.store.company.type,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${order.total.toStringAsFixed(kCoinDecimals)} $kCoin',
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
