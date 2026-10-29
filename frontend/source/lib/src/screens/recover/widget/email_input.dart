import 'package:planck/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/common/validator.dart';
import 'package:planck/src/screens/recover/recover_controller.dart';

class EmailInput extends StatelessWidget {
  const EmailInput(this.recoverController, {super.key});
  final RecoverController recoverController;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: S.of(context).hEmail,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,

      onSaved: (email) => recoverController.email = email!,
      validator: (value) => validateEmail(context, value!),
    );
  }
}
