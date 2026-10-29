import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/admin/credit/credit_controller.dart';
import 'package:delivery_app/src/widgets/forms/form_fields.dart';

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
