import 'package:delivery_app/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/common/validator.dart';
import 'package:delivery_app/src/screens/admin/credit/credit_controller.dart';

class AmountInput extends StatelessWidget {
  const AmountInput(this.creditController, {super.key});

  final CreditController creditController;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: S.of(context).lAmount,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textCapitalization: TextCapitalization.sentences,

      onSaved: (amount) {
        amount = amount!.trim();
        amount = amount.replaceFirst(',', '.');
        creditController.amount = double.parse(amount);
      },
      validator: (value) => validatePrice(context, value!),
    );
  }
}
