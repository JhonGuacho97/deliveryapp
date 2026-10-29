import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/login/access_controller.dart';
import 'package:planck/src/widgets/forms/form_fields.dart';

class PhoneInput extends StatelessWidget {
  const PhoneInput(this.accessController, {super.key});
  final AccessController accessController;
  @override
  Widget build(BuildContext context) => AppPhoneField(
    label: S.of(context).hPhone,
    initialValue: accessController.phone,
    onSaved: (value) => accessController.phone = value,
  );
}
