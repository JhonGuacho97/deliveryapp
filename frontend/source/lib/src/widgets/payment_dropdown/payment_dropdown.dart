import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/widgets/payment_dropdown/payment_dropdown_controller.dart';
import 'package:planck/src/widgets/forms/form_options.dart';
import 'package:provider/provider.dart';

class PaymentDropdown extends StatelessWidget {
  const PaymentDropdown({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.watch<PaymentDropdownController>(), s = S.of(context);
    return FormOptionControl(
      label: s.lPaymentMethods,
      value: c.dropdown.name,
      error: c.isPaymentSelected ? null : s.selectOption,
      onTap: () => showFormOptions(
        context,
        title: s.lPaymentMethods,
        items: c.paymentItems,
        onSelected: c.setDropdown,
      ),
    );
  }
}
