import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/src/widgets/forms/form_fields.dart';

class AmountInput extends StatelessWidget {
  const AmountInput(this.amount, {super.key});
  final double amount;
  @override
  Widget build(BuildContext context) => FormReadOnlyValue(
    label: S.of(context).courierSettlement,
    value: amount.toStringAsFixed(kCoinDecimals) + ' ' + kCoin,
    helper: S.of(context).courierSettlementHint,
  );
}
