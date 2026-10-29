import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/admin/credit/credit_controller.dart';
import 'package:planck/src/widgets/forms/form_fields.dart';

class PhoneInput extends StatelessWidget {
  const PhoneInput(this.creditController, {super.key});
  final CreditController creditController;
  @override
  Widget build(BuildContext context) => AppPhoneField(
    label: S.of(context).hPhone,
    initialValue: creditController.phone,
    onSaved: (value) => creditController.phone = value,
  );
}
