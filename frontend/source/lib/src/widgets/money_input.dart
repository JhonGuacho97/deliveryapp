import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/src/widgets/forms/form_fields.dart';

class MoneyInput extends StatelessWidget {
  const MoneyInput(this.money, {super.key});
  final double money;
  @override
  Widget build(BuildContext context) => FormReadOnlyValue(
    label: S.of(context).walletBalance,
    value: money.toStringAsFixed(kCoinDecimals) + ' ' + kCoin,
    helper: S.of(context).walletBalanceHint,
  );
}
