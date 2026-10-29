import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/src/widgets/forms/form_fields.dart';

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
