import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/src/widgets/forms/form_fields.dart';

class BalanceInput extends StatelessWidget {
  const BalanceInput(this.balance, {super.key});
  final double balance;
  @override
  Widget build(BuildContext context) => FormReadOnlyValue(
    label: S.of(context).courierCredit,
    value: balance.toStringAsFixed(kCoinDecimals) + ' ' + kCoin,
    helper: S.of(context).courierCreditHint,
  );
}
