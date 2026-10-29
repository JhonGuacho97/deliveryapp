import 'package:delivery_app/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/common/validator.dart';
import 'package:delivery_app/src/screens/login/access_controller.dart';

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
