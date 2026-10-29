import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/src/widgets/forms/form_fields.dart';

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
