import 'package:planck/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/common/validator.dart';
import 'package:planck/src/screens/login/access_controller.dart';

class EmailInput extends StatelessWidget {
  const EmailInput(this.accessController, {super.key});
  final AccessController accessController;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: S.of(context).hEmail,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,

      initialValue: accessController.email,
      onSaved: (email) => accessController.email = email!,
      validator: (value) => validateEmail(context, value!),
    );
  }
}
