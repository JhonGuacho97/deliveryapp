import 'package:flutter/material.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/models/cart_summary_model.dart';

class DetailsProducts extends StatelessWidget {
  const DetailsProducts({super.key, required this.cartSummary});
  final CartSummaryModel cartSummary;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget amount(String label, double value, {bool total = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: total
                  ? theme.textTheme.titleSmall
                  : theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${value.toStringAsFixed(kCoinDecimals)} $kCoin',
            style: total
                ? theme.textTheme.titleSmall
                : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final product in cartSummary.products) ...[
          amount('${product.number} × ${product.name}', product.total),
          if (product.note.isNotEmpty)
            Text(product.note, style: theme.textTheme.bodySmall),
        ],
        const Divider(),
        amount(S.of(context).lDeliveryFee, cartSummary.fee.deliveryfee),
        amount(S.of(context).lTotal, cartSummary.total, total: true),
      ],
    );
  }
}
